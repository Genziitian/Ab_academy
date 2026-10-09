import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../models/community.dart';
import '../models/course.dart';
import '../models/popup.dart';
import '../models/ticket.dart';
import '../models/user.dart';
import '../mock/mock_data.dart';
import '../remote/auth_repository.dart';
import '../remote/repositories.dart';
import '../remote/supabase_client.dart';

/// True when a Supabase project is configured for this build. Screens use it
/// to decide whether an action is real or should show the "coming soon"
/// snackbar it showed before.
final hasBackendProvider = Provider<bool>((ref) => Env.hasBackend && Api.isReady);

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
  if (!ref.watch(hasBackendProvider)) return MockData.courses;
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
    return MockData.courses.where((c) => c.id == id).firstOrNull;
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

typedef LessonVideo = ({String? youtubeId, String? signedUrl});

final remoteLessonVideoProvider = FutureProvider.family<LessonVideo, String>((
  ref,
  lessonId,
) async {
  if (!ref.watch(hasBackendProvider)) {
    return (youtubeId: null, signedUrl: null);
  }
  return Repo.lessonVideo(lessonId);
});

typedef LessonNote = ({String id, String title, String meta, String? url});

final remoteLessonNotesProvider =
    FutureProvider.family<List<LessonNote>, String>((ref, lessonId) async {
      if (!ref.watch(hasBackendProvider)) return const [];
      return Repo.lessonNotes(lessonId);
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

// ----------------------------------------------------------- communities

final remoteCommunitiesProvider = FutureProvider<List<Community>>((ref) async {
  if (!ref.watch(hasBackendProvider)) return MockData.communities;
  return Repo.communities();
});

/// Live message feed for one community, over the realtime publication.
final communityFeedProvider =
    StreamProvider.family<List<CommunityMessage>, String>((ref, communityId) {
      if (!ref.watch(hasBackendProvider)) return const Stream.empty();
      return Repo.communityStream(communityId);
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

final remoteNotificationsProvider =
    FutureProvider<List<RemoteNotification>>((ref) async {
      if (!ref.watch(hasBackendProvider)) return const [];
      return Repo.notifications();
    });

/// Realtime notification stream — replaces the simulated timer the home
/// screen used on mock data.
final notificationStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
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
