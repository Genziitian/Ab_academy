import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../models/banner.dart';
import '../models/content.dart';
import '../models/course.dart';
import '../models/popup.dart';
import '../models/ticket.dart';
import '../models/user.dart';
import '../mock/mock_data.dart';
import '../remote/auth_repository.dart';
import '../remote/mappers.dart' show sizeLabel;
import '../remote/repositories.dart';
import '../remote/supabase_client.dart';

/// True when a Supabase project is configured for this build. Screens use it
/// to decide whether an action is real or should show the "coming soon"
/// snackbar it showed before.
final hasBackendProvider = Provider<bool>(
  (ref) => Env.hasBackend && Api.isReady,
);

// --------------------------------------------------------------- session

/// The signed-in student from `profiles` + `student_profiles`, or the mock
/// student when there is no backend.
final remoteStudentProvider = FutureProvider<Student>((ref) async {
  if (!ref.watch(hasBackendProvider)) return MockData.student;
  return await Repo.currentStudent() ?? MockData.student;
});

/// Emits on every sign-in and sign-out so dependent providers refetch.
final authStateProvider = StreamProvider((ref) {
  if (!ref.watch(hasBackendProvider)) return const Stream.empty();
  return AuthRepo.changes;
});

// --------------------------------------------------------------- courses

final remoteCatalogProvider = FutureProvider.family<List<Course>, int?>((
  ref,
  classLevel,
) async {
  if (!ref.watch(hasBackendProvider)) {
    return classLevel == null
        ? MockData.catalog
        : MockData.catalog.where((c) => c.classLevel == classLevel).toList();
  }
  return Repo.catalog(classLevel: classLevel);
});

final remoteMyCoursesProvider = FutureProvider<List<Course>>((ref) async {
  if (!ref.watch(hasBackendProvider)) return MockData.courses;
  return Repo.myCourses();
});

final remoteCourseProvider = FutureProvider.family<Course?, String>((
  ref,
  id,
) async {
  if (!ref.watch(hasBackendProvider)) {
    return MockData.catalog.where((c) => c.id == id).firstOrNull;
  }
  return Repo.course(id);
});

final remoteCurriculumProvider = FutureProvider.family<List<Chapter>, String>((
  ref,
  courseId,
) async {
  if (!ref.watch(hasBackendProvider)) return MockData.chapters;
  return Repo.curriculum(courseId);
});

// ----------------------------------------------------- lessons and notes

/// YouTube id for a lesson, fetched at play time through `lesson_playback`.
/// Never cached to disk, never put in a route or a log line.
final lessonYoutubeIdProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, lessonId) async {
      if (!ref.watch(hasBackendProvider)) return MockData.demoYoutubeId;
      return Repo.lessonYoutubeId(lessonId);
    });

typedef LessonNote = ({String id, String title, String meta});

/// Notes attached to a lecture. Mock attachments without a backend.
final remoteLessonNotesProvider =
    FutureProvider.family<List<LessonNote>, String>((ref, lessonId) async {
      if (!ref.watch(hasBackendProvider)) {
        return [
          for (final a in MockData.lessonAttachments)
            (id: a.id, title: a.title, meta: a.sizeLabel.replaceAll('•', '·')),
        ];
      }
      return Repo.lessonNotes(lessonId);
    });

/// Academics → Notes: every note the student can open.
final notesLibraryProvider = FutureProvider<List<StudyMaterial>>((ref) async {
  if (!ref.watch(hasBackendProvider)) return MockData.materials;
  final rows = await Repo.notesLibrary();
  return [
    for (final r in rows)
      StudyMaterial(
        id: r['id'] as String,
        title: (r['title'] as String?) ?? 'Class notes',
        subject:
            ((((r['lessons'] as Map?)?['chapters'] as Map?)?['subjects']
                    as Map?)?['name']
                as String?) ??
            'General',
        kind: MaterialKind.pdf,
        sizeLabel: r['source'] == 'gdrive'
            ? 'PDF'
            : 'PDF • ${sizeLabel(r['size_bytes'] as int?)}',
      ),
  ];
});

/// One note's PDF bytes. Kept only in memory while the viewer is open —
/// never written to disk, so notes cannot be copied out of app storage.
final noteBytesProvider = FutureProvider.autoDispose.family<Uint8List, String>((
  ref,
  noteId,
) async {
  if (!ref.watch(hasBackendProvider)) {
    final data = await rootBundle.load('assets/sample-notes.pdf');
    return data.buffer.asUint8List();
  }
  return Repo.noteBytes(noteId);
});

// ---------------------------------------------------------------- doubts

typedef RemoteComment = ({
  String id,
  String author,
  String initials,
  String body,
  String time,
  bool isStaff,
});

final remoteLessonCommentsProvider =
    FutureProvider.family<List<RemoteComment>, String>((ref, lessonId) async {
      if (!ref.watch(hasBackendProvider)) return const [];
      return Repo.lessonComments(lessonId);
    });

// --------------------------------------------------------------- tickets

final remoteTicketsProvider = FutureProvider<List<Ticket>>((ref) async {
  if (!ref.watch(hasBackendProvider)) return MockData.tickets;
  return Repo.tickets();
});

final remoteTicketProvider = FutureProvider.family<Ticket?, String>((
  ref,
  id,
) async {
  if (!ref.watch(hasBackendProvider)) {
    return MockData.tickets.where((t) => t.id == id).firstOrNull;
  }
  return Repo.ticket(id);
});

// --------------------------------------------------------- notifications

typedef RemoteNotification = ({
  String id,
  String title,
  String body,
  String time,
  String? deepLink,
});

final remoteNotificationsProvider = FutureProvider<List<RemoteNotification>>((
  ref,
) async {
  if (!ref.watch(hasBackendProvider)) return const [];
  return Repo.notifications();
});

/// Realtime notification stream — replaces the simulated timer the home
/// screen used on mock data.
final notificationStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  if (!ref.watch(hasBackendProvider)) return const Stream.empty();
  return Repo.notificationStream();
});

// ---------------------------------------------------------------- popups

/// Popups the student is eligible for at a given placement. Returns empty
/// without a backend, so nothing shows in mock mode.
final popupsProvider = FutureProvider.family<List<AppPopup>, PopupPlacement>((
  ref,
  placement,
) async {
  if (!ref.watch(hasBackendProvider)) return const [];
  try {
    return await Repo.popups(placement);
  } catch (_) {
    // A popup failing to load must never block the screen behind it.
    return const [];
  }
});

// --------------------------------------------------------------- slider

/// Slides for the course slider on Home and the Courses store. Mock slides
/// without a backend; an empty list (slider hidden) if the query fails.
final bannersProvider = FutureProvider<List<CourseBanner>>((ref) async {
  if (!ref.watch(hasBackendProvider)) return MockData.banners;
  try {
    return await Repo.banners();
  } catch (_) {
    return const [];
  }
});
