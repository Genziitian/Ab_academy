import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/content.dart';
import '../models/course.dart';
import '../models/user.dart';
import '../remote/auth_repository.dart';
import '../remote/push_service.dart';
import '../remote/repositories.dart';

// ---------------------------------------------------------------- session

class SessionNotifier extends Notifier<Student?> {
  @override
  Student? build() {
    // A session restored from disk means the student is already signed in;
    // load their real profile in the background.
    if (AuthRepo.isSignedIn) {
      Future.microtask(refreshFromBackend);
    }
    return null;
  }

  /// Signs in. Without a backend this is the mock student, as before; with one
  /// it loads `profiles` + `student_profiles` for the authenticated user.
  Future<void> signIn() async {
    if (!AuthRepo.enabled) {
      state = MockData.student;
      return;
    }
    await refreshFromBackend();
    // Attach this device's push token to the student who just signed in.
    await PushService.claimTokenForCurrentUser();
  }

  /// Re-reads the profile from Supabase, falling back to the mock student so a
  /// transient failure never leaves the app with no user to render.
  Future<void> refreshFromBackend() async {
    if (!AuthRepo.enabled) return;
    try {
      state = await Repo.currentStudent() ?? MockData.student;
    } catch (_) {
      state = MockData.student;
    }
  }

  Future<void> applySetup({
    int? classLevel,
    String? stream,
    String? medium,
  }) async {
    state = (state ?? MockData.student).copyWith(
      classLevel: classLevel,
      stream: stream,
      medium: medium,
    );

    if (AuthRepo.enabled) {
      await Repo.saveSetup(
        classLevel: classLevel,
        stream: stream,
        medium: medium,
      );
    }
  }

  Future<void> signOut() async {
    state = null;
    await PushService.releaseToken();
    await AuthRepo.signOut();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Student?>(
  SessionNotifier.new,
);

/// The mock user, whether or not they've "signed in" — screens always have data to render.
final studentProvider = Provider<Student>(
  (ref) => ref.watch(sessionProvider) ?? MockData.student,
);

// ------------------------------------------------------------- onboarding

class OnboardingState {
  const OnboardingState({
    this.phone = '',
    this.otp = '',
    this.classLevel = 12,
    this.stream = 'Science',
    this.medium = 'Hindi',
  });

  final String phone;
  final String otp;
  final int classLevel;
  final String stream;
  final String medium;

  bool get otpComplete => otp.length == 6;

  OnboardingState copyWith({
    String? phone,
    String? otp,
    int? classLevel,
    String? stream,
    String? medium,
  }) {
    return OnboardingState(
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
      classLevel: classLevel ?? this.classLevel,
      stream: stream ?? this.stream,
      medium: medium ?? this.medium,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setPhone(String phone) => state = state.copyWith(phone: phone);

  void pressKey(String digit) {
    if (state.otp.length >= 6) return;
    state = state.copyWith(otp: state.otp + digit);
  }

  void backspace() {
    if (state.otp.isEmpty) return;
    state = state.copyWith(otp: state.otp.substring(0, state.otp.length - 1));
  }

  void clearOtp() => state = state.copyWith(otp: '');

  /// Replaces the whole code, e.g. from the system keyboard or an SMS autofill.
  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(
      otp: digits.length > 6 ? digits.substring(0, 6) : digits,
    );
  }

  void setClassLevel(int value) => state = state.copyWith(classLevel: value);

  void setStream(String value) => state = state.copyWith(stream: value);

  void setMedium(String value) => state = state.copyWith(medium: value);
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

// ---------------------------------------------------------------- catalog

final coursesProvider = Provider<List<Course>>((ref) => MockData.courses);

final courseByIdProvider = Provider.family<Course, String>((ref, id) {
  return MockData.catalog.firstWhere(
    (c) => c.id == id,
    orElse: () => MockData.scienceCrash,
  );
});

/// "All" | "In Progress" | "Completed" chips on My Courses.
/// "Enrolled" | "Completed" segmented control on My Courses.
final courseFilterProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('Enrolled'),
);

/// Class and stream chips on the Explore screen.
final exploreFilterProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('All'),
);

/// Overview / Classes / Notes / Tests tabs on Course details.
final courseDetailTabProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('Overview'),
);

/// Subject chips on the Curriculum screen.
final curriculumSubjectProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('Physics'),
);

/// Chat / Questions / Notes tabs in the live classroom panel.
final liveTabProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('Chat'),
);

/// Which chapter accordion is expanded (chapter 1 by design default, null = all closed).
class ExpandedChapterNotifier extends Notifier<int?> {
  @override
  int? build() => 1;

  void toggle(int number) => state = state == number ? null : number;
}

final expandedChapterProvider = NotifierProvider<ExpandedChapterNotifier, int?>(
  ExpandedChapterNotifier.new,
);

// -------------------------------------------------------- study materials

final materialsFilterProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('All'),
);

// --------------------------------------------------------------- calendar

final calendarFilterProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('All'),
);

/// Selected calendar date (midnight, local time). Defaults to today.
class CalendarDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime day) => state = DateTime(day.year, day.month, day.day);
}

final calendarDayProvider = NotifierProvider<CalendarDayNotifier, DateTime>(
  CalendarDayNotifier.new,
);

/// First day of the month the calendar grid is showing.
class CalendarMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final calendarMonthProvider = NotifierProvider<CalendarMonthNotifier, DateTime>(
  CalendarMonthNotifier.new,
);

// ---------------------------------------------------------- notifications

/// Announcements and notifications. With a backend this is the student's
/// `notifications` feed (RLS limits it to everyone / their class / their
/// courses / them) with read state from `notification_reads`; without one,
/// the sample list.
class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    if (!AuthRepo.enabled) return MockData.notifications;
    // Reload when the student signs in or out.
    ref.watch(sessionProvider);
    Future.microtask(refresh);
    return const [];
  }

  Future<void> refresh() async {
    if (!AuthRepo.enabled) return;
    if (!AuthRepo.isSignedIn) {
      state = const [];
      return;
    }
    try {
      final rows = await Repo.notificationFeed();
      final read = await Repo.readNotificationIds();
      state = [for (final r in rows) _fromRow(r, read)];
    } catch (_) {
      // Keep what is on screen; the next refresh tries again.
    }
  }

  static AppNotification _fromRow(Map<String, dynamic> r, Set<String> read) {
    final sent =
        DateTime.tryParse(r['sent_at']?.toString() ?? '')?.toLocal() ??
        DateTime.now();
    final now = DateTime.now();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(sent.year, sent.month, sent.day)).inDays;
    final title = (r['title'] as String?) ?? '';
    final lower = title.toLowerCase();
    final kind = lower.contains('support') || lower.contains('ticket')
        ? NotificationKind.support
        : lower.contains('live') || lower.contains('class')
        ? NotificationKind.live
        : lower.contains('test') || lower.contains('quiz')
        ? NotificationKind.test
        : lower.contains('record')
        ? NotificationKind.recording
        : lower.contains('note')
        ? NotificationKind.notes
        : NotificationKind.announcement;
    final diff = now.difference(sent);
    return AppNotification(
      id: r['id'] as String,
      title: title,
      body: (r['body'] as String?) ?? '',
      kind: kind,
      group: days <= 0
          ? NotificationGroup.today
          : days == 1
          ? NotificationGroup.yesterday
          : NotificationGroup.earlier,
      timeAgo: diff.inMinutes < 1
          ? 'now'
          : diff.inMinutes < 60
          ? '${diff.inMinutes}m ago'
          : diff.inHours < 24
          ? '${diff.inHours}h ago'
          : '${diff.inDays}d ago',
      isUnread: !read.contains(r['id']),
      deepLink: r['deep_link'] as String?,
    );
  }

  /// Newest first — how an admin-sent notification arrives.
  void push(AppNotification notification) {
    if (state.any((n) => n.id == notification.id)) return;
    state = [notification, ...state];
  }

  Future<void> markRead(String id) async {
    if (!state.any((n) => n.id == id && n.isUnread)) return;
    state = [
      for (final n in state) n.id == id ? n.copyWith(isUnread: false) : n,
    ];
    if (AuthRepo.enabled) {
      try {
        await Repo.markNotificationsRead([id]);
      } catch (_) {}
    }
  }

  Future<void> markAllRead() async {
    final ids = [
      for (final n in state)
        if (n.isUnread) n.id,
    ];
    state = [for (final n in state) n.copyWith(isUnread: false)];
    if (AuthRepo.enabled) {
      try {
        await Repo.markNotificationsRead(ids);
      } catch (_) {}
    }
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => n.isUnread).length,
);

// -------------------------------------------------------------- downloads

class DownloadsNotifier extends Notifier<List<DownloadItem>> {
  @override
  List<DownloadItem> build() => MockData.downloads;

  void remove(String id) => state = state.where((d) => d.id != id).toList();
}

final downloadsProvider =
    NotifierProvider<DownloadsNotifier, List<DownloadItem>>(
      DownloadsNotifier.new,
    );

// --------------------------------------------------------------- checkout

final paymentMethodProvider = NotifierProvider<SelectionNotifier, String>(
  () => SelectionNotifier('UPI'),
);

// ----------------------------------------------------------------- profile

class PushToggleNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final pushEnabledProvider = NotifierProvider<PushToggleNotifier, bool>(
  PushToggleNotifier.new,
);

// ------------------------------------------------------------------ utils

/// Shared single-select notifier backing every chip/tab row in the app.
class SelectionNotifier extends Notifier<String> {
  SelectionNotifier(this._initial);

  final String _initial;

  @override
  String build() => _initial;

  void select(String value) => state = value;
}
