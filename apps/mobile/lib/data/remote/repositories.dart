import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionException, HttpMethod, PostgrestException;

import '../models/banner.dart';
import '../models/course.dart';
import '../models/popup.dart';
import '../models/ticket.dart';
import '../models/user.dart';
import 'mappers.dart';
import 'supabase_client.dart';

/// Reads and writes against Supabase. Every method assumes `Api.isReady`;
/// the providers in `data/providers/` decide between this and `MockData`.
abstract final class Repo {
  // ----------------------------------------------------------- profile

  static Future<Student?> currentStudent() async {
    final id = Api.currentUserId;
    if (id == null) return null;

    final profile = await Api.client
        .from('profiles')
        .select('full_name, phone, email, student_code')
        .eq('id', id)
        .maybeSingle();
    if (profile == null) return null;

    final studentProfile = await Api.client
        .from('student_profiles')
        .select('class_level, board, medium, stream, school')
        .eq('user_id', id)
        .maybeSingle();

    return studentFromRows(profile, studentProfile);
  }

  static Future<void> saveSetup({
    int? classLevel,
    String? stream,
    String? medium,
  }) async {
    final id = Api.currentUserId;
    if (id == null) return;

    await Api.client.from('student_profiles').upsert({
      'user_id': id,
      if (classLevel != null) 'class_level': classLevel,
      if (stream != null) 'stream': stream,
      if (medium != null) 'medium': medium,
    });
  }

  // ----------------------------------------------------------- courses

  static const _courseFields = '''
    id, slug, title, description, board, class_level, language, price_inr,
    original_price_inr, rating, lessons_count, highlights, subjects, thumbnail_hue,
    is_published,
    course_teachers ( is_primary, teachers ( display_name, subjects ) ),
    course_batches ( id, name )
  ''';

  /// Ids of the courses this student has active access to.
  static Future<Set<String>> enrolledCourseIds() async {
    final id = Api.currentUserId;
    if (id == null) return {};

    final rows = await Api.client
        .from('enrollments')
        .select('course_id')
        .eq('student_id', id)
        .eq('status', 'active');

    return rows.map((r) => r['course_id'] as String).toSet();
  }

  static Future<List<Course>> catalog({int? classLevel}) async {
    var query = Api.client
        .from('courses')
        .select(_courseFields)
        .eq('is_published', true);

    if (classLevel != null) query = query.eq('class_level', classLevel);

    final rows = await query.order('class_level').order('title');
    final enrolled = await enrolledCourseIds();

    return rows
        .map((r) => courseFromRow(r, isEnrolled: enrolled.contains(r['id'])))
        .toList();
  }

  static Future<List<Course>> myCourses() async {
    final enrolled = await enrolledCourseIds();
    if (enrolled.isEmpty) return [];

    final rows = await Api.client
        .from('courses')
        .select(_courseFields)
        .inFilter('id', enrolled.toList());

    return rows.map((r) => courseFromRow(r, isEnrolled: true)).toList();
  }

  static Future<Course?> course(String id) async {
    final row = await Api.client
        .from('courses')
        .select(_courseFields)
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;

    final enrolled = await enrolledCourseIds();
    return courseFromRow(row, isEnrolled: enrolled.contains(id));
  }

  // ------------------------------------------------- lessons and notes

  static Future<List<Chapter>> curriculum(String courseId) async {
    final rows = await Api.client
        .from('lessons')
        .select('''
          id, title, lesson_type, sort_order, duration_seconds, is_demo,
          is_published, video_provider,
          chapters!inner (
            id, title, sort_order,
            subjects!inner ( name, course_batches!inner ( course_id ) )
          )
        ''')
        .eq('is_published', true)
        .eq('chapters.subjects.course_batches.course_id', courseId)
        .order('sort_order');

    final enrolled = await enrolledCourseIds();
    return chaptersFromLessons(
      rows.cast<Json>(),
      hasAccess: enrolled.contains(courseId),
    );
  }

  /// The YouTube id for one lesson, asked for only when it is about to play.
  ///
  /// `lesson_playback` returns it only to staff, for published demo lessons,
  /// or to a student with an active enrolment; students cannot select
  /// `video_ref` any other way (migration 6). Null when the lesson is not a
  /// YouTube lesson; throws [PlaybackDenied] when the student has no access.
  static Future<String?> lessonYoutubeId(String lessonId) async {
    try {
      final rows = await Api.client.rpc(
        'lesson_playback',
        params: {'p_lesson_id': lessonId},
      );
      final list = (rows as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) return null;
      final row = list.first;
      if (row['provider'] != 'youtube') return null;
      return row['video_ref'] as String?;
    } on PostgrestException catch (e) {
      if (e.code == '42501') throw const PlaybackDenied();
      rethrow;
    }
  }

  /// Notes attached to a lesson. No location comes back — students cannot
  /// select storage paths or Drive ids (migration 7); [noteBytes] fetches
  /// the file itself.
  static Future<List<({String id, String title, String meta})>> lessonNotes(
    String lessonId,
  ) async {
    final rows = await Api.client
        .from('lesson_resources')
        .select('id, title, size_bytes, source')
        .eq('lesson_id', lessonId)
        .order('created_at');

    return [
      for (final r in rows)
        (
          id: r['id'] as String,
          title: (r['title'] as String?) ?? 'Class notes',
          meta: r['source'] == 'gdrive'
              ? 'PDF'
              : 'PDF · ${sizeLabel(r['size_bytes'] as int?)}',
        ),
    ];
  }

  /// Every note the student can read, newest first, with its subject — the
  /// Academics → Notes list. RLS limits rows to enrolled courses and demos.
  static Future<List<Map<String, dynamic>>> notesLibrary() async {
    final rows = await Api.client
        .from('lesson_resources')
        .select(
          'id, title, size_bytes, source, created_at, '
          'lessons ( chapters ( subjects ( name ) ) )',
        )
        .order('created_at', ascending: false)
        .limit(200);
    return rows.cast<Map<String, dynamic>>();
  }

  /// The PDF bytes of one note, streamed by the `notes` Edge Function after
  /// it checks the student's access. The file's real location — the private
  /// bucket or Google Drive — never reaches the app.
  static Future<Uint8List> noteBytes(String resourceId) async {
    try {
      final response = await Api.client.functions.invoke(
        'notes',
        method: HttpMethod.get,
        queryParameters: {'id': resourceId},
      );
      final data = response.data;
      if (data is Uint8List) return data;
      throw const NoteUnavailable('These notes could not be opened.');
    } on FunctionException catch (e) {
      final details = e.details;
      throw NoteUnavailable(
        details is Map && details['error'] != null
            ? details['error'].toString()
            : 'These notes could not be opened.',
        denied: e.status == 403,
      );
    }
  }

  // ------------------------------------------------- doubts under a lesson

  static Future<
    List<
      ({
        String id,
        String author,
        String initials,
        String body,
        String time,
        bool isStaff,
      })
    >
  >
  lessonComments(String lessonId) async {
    final rows = await Api.client
        .from('lesson_comments')
        .select(
          'id, body, created_at, author_id, profiles:author_id ( full_name, role )',
        )
        .eq('lesson_id', lessonId)
        .isFilter('parent_id', null)
        .order('created_at');

    return rows.map((r) {
      final author = r['profiles'] as Json?;
      final name = (author?['full_name'] as String?) ?? 'Student';
      return (
        id: r['id'] as String,
        author: name,
        initials: initialsOf(name),
        body: (r['body'] as String?) ?? '',
        time: relativeLabel(parseTs(r['created_at'])),
        isStaff: ((author?['role'] as String?) ?? 'student') != 'student',
      );
    }).toList();
  }

  /// Posts a question under a lecture. `isDoubt` puts it in the admin queue.
  static Future<void> postComment(
    String lessonId,
    String body, {
    bool isDoubt = true,
  }) async {
    final id = Api.currentUserId;
    if (id == null) return;

    await Api.client.from('lesson_comments').insert({
      'lesson_id': lessonId,
      'author_id': id,
      'body': body,
      'is_doubt': isDoubt,
    });
  }

  static Future<void> rateLesson(
    String lessonId,
    int rating,
    String? comment,
  ) async {
    final id = Api.currentUserId;
    if (id == null) return;

    await Api.client.from('lesson_feedback').upsert({
      'lesson_id': lessonId,
      'student_id': id,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'lesson_id,student_id');
  }

  // ----------------------------------------------------------- tickets

  static const _ticketFields = '''
    id, reference, subject, category, status, created_at,
    ticket_messages ( id, body, from_support, created_at, profiles:author_id ( full_name ) )
  ''';

  static Future<List<Ticket>> tickets() async {
    final id = Api.currentUserId;
    if (id == null) return [];

    final rows = await Api.client
        .from('tickets')
        .select(_ticketFields)
        .eq('student_id', id)
        .order('created_at', ascending: false);

    return rows.map(ticketFromRow).toList();
  }

  static Future<Ticket?> ticket(String ticketId) async {
    final row = await Api.client
        .from('tickets')
        .select(_ticketFields)
        .eq('id', ticketId)
        .maybeSingle();
    return row == null ? null : ticketFromRow(row);
  }

  static Future<String?> createTicket({
    required String subject,
    required TicketCategory category,
    required String body,
  }) async {
    final id = Api.currentUserId;
    if (id == null) return null;

    // The reference is human-facing; the id stays a uuid.
    final reference = 'ABA-T-${DateTime.now().millisecondsSinceEpoch % 100000}';

    final row = await Api.client
        .from('tickets')
        .insert({
          'student_id': id,
          'reference': reference,
          'subject': subject,
          'category': ticketCategoryTo(category),
        })
        .select('id')
        .single();

    final ticketId = row['id'] as String;
    await replyToTicket(ticketId, body);
    return ticketId;
  }

  static Future<void> replyToTicket(String ticketId, String body) async {
    final id = Api.currentUserId;
    if (id == null) return;

    await Api.client.from('ticket_messages').insert({
      'ticket_id': ticketId,
      'author_id': id,
      'body': body,
      'from_support': false,
    });
  }

  // ----------------------------------------------------- notifications

  static Future<
    List<
      ({String id, String title, String body, String time, String? deepLink})
    >
  >
  notifications() async {
    final rows = await Api.client
        .from('notifications')
        .select('id, title, body, sent_at, deep_link')
        .order('sent_at', ascending: false)
        .limit(50);

    return rows
        .map(
          (r) => (
            id: r['id'] as String,
            title: (r['title'] as String?) ?? '',
            body: (r['body'] as String?) ?? '',
            time: relativeLabel(parseTs(r['sent_at'])),
            deepLink: r['deep_link'] as String?,
          ),
        )
        .toList();
  }

  static Future<void> markNotificationRead(String notificationId) async {
    final id = Api.currentUserId;
    if (id == null) return;

    await Api.client.from('notification_reads').upsert({
      'notification_id': notificationId,
      'student_id': id,
    });
  }

  /// RLS already filters this to notifications aimed at the signed-in student.
  static Stream<List<Json>> notificationStream() {
    return Api.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('sent_at', ascending: false)
        .limit(20);
  }

  // ------------------------------------------------------------ popups

  /// Popups the student is eligible for, already filtered by the RLS policy to
  /// those active, in-window and matching their class or enrolments.
  static Future<List<AppPopup>> popups(PopupPlacement placement) async {
    final slug = switch (placement) {
      PopupPlacement.home => 'home',
      PopupPlacement.course => 'course',
      PopupPlacement.appLaunch => 'app_launch',
    };

    final rows = await Api.client
        .from('popups')
        .select(
          'id, title, body, image_path, cta_label, cta_url, placement, max_views_per_student',
        )
        .eq('placement', slug)
        .order('priority', ascending: false);

    final base =
        '${Api.client.storage.url.replaceAll(RegExp(r'/storage/v1$'), '')}'
        '/storage/v1/object/public/popup-images/';

    final all = rows.map((r) => AppPopup.fromRow(r, publicBase: base)).toList();
    if (all.isEmpty) return [];

    // Drop any the student has already seen often enough.
    final seen = await _popupViewCounts(all.map((p) => p.id).toList());
    return all.where((p) {
      if (p.maxViewsPerStudent == 0) return true;
      return (seen[p.id] ?? 0) < p.maxViewsPerStudent;
    }).toList();
  }

  static Future<Map<String, int>> _popupViewCounts(List<String> ids) async {
    final me = Api.currentUserId;
    if (me == null || ids.isEmpty) return {};

    final rows = await Api.client
        .from('popup_views')
        .select('popup_id, view_count')
        .eq('student_id', me)
        .inFilter('popup_id', ids);

    return {
      for (final r in rows)
        r['popup_id'] as String: (r['view_count'] as int?) ?? 0,
    };
  }

  /// Counts an impression. Called when the popup is actually shown.
  static Future<void> recordPopupView(String popupId) async {
    final me = Api.currentUserId;
    if (me == null) return;

    final existing = await Api.client
        .from('popup_views')
        .select('view_count')
        .eq('popup_id', popupId)
        .eq('student_id', me)
        .maybeSingle();

    await Api.client.from('popup_views').upsert({
      'popup_id': popupId,
      'student_id': me,
      'view_count': ((existing?['view_count'] as int?) ?? 0) + 1,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'popup_id,student_id');
  }

  static Future<void> recordPopupClick(String popupId) async {
    final me = Api.currentUserId;
    if (me == null) return;

    await Api.client
        .from('popup_views')
        .update({'clicked_at': DateTime.now().toUtc().toIso8601String()})
        .eq('popup_id', popupId)
        .eq('student_id', me);
  }

  static Future<void> dismissPopup(String popupId) async {
    final me = Api.currentUserId;
    if (me == null) return;

    await Api.client
        .from('popup_views')
        .update({'dismissed_at': DateTime.now().toUtc().toIso8601String()})
        .eq('popup_id', popupId)
        .eq('student_id', me);
  }

  // ----------------------------------------------------------- banners

  /// Live slides for the course slider, in admin order. RLS already hides
  /// inactive and out-of-window slides from students.
  static Future<List<CourseBanner>> banners() async {
    final rows = await Api.client
        .from('course_banners')
        .select('id, title, subtitle, image_path, course_id, cta_label, hue')
        .order('sort_order')
        .order('created_at');

    final base =
        '${Api.client.storage.url.replaceAll(RegExp(r'/storage/v1$'), '')}'
        '/storage/v1/object/public/banner-images/';

    return rows.map((r) => CourseBanner.fromRow(r, publicBase: base)).toList();
  }

  // ---------------------------------------------------------- checkout

  /// Calls the `checkout` Edge Function. Orders, payments and enrolments are
  /// written there with the service role; students cannot write them.
  static Future<Map<String, dynamic>> checkout(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await Api.client.functions.invoke(
        'checkout',
        body: body,
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map && details['error'] != null
          ? details['error'].toString()
          : 'Checkout failed (${e.status}).';
      throw CheckoutException(message);
    }
  }
}

/// A checkout step the server refused, with a message fit to show the student.
class CheckoutException implements Exception {
  const CheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The student is not enrolled in the course this lesson belongs to.
class PlaybackDenied implements Exception {
  const PlaybackDenied();

  @override
  String toString() => 'Enroll in this course to watch the lecture.';
}

/// A note the server would not hand over, with a message for the student.
class NoteUnavailable implements Exception {
  const NoteUnavailable(this.message, {this.denied = false});

  final String message;

  /// True when the student is not enrolled, rather than a fetch failure.
  final bool denied;

  @override
  String toString() => message;
}
