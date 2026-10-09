/// Mirrors `public.live_status` for the subset the app renders.
enum SessionKind { live, recorded, test }

/// A row in "Today's schedule" (home) and the calendar day agenda.
class ScheduleItem {
  const ScheduleItem({
    required this.timeLabel,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.subject,
    this.isNow = false,
    this.joinable = false,
  });

  /// "6:00 PM"
  final String timeLabel;
  final String title;

  /// "Quadratic Equations • Amit Sir"
  final String subtitle;
  final SessionKind kind;
  final String subject;

  /// Highlights the time label — the class happening next.
  final bool isNow;
  final bool joinable;
}

/// Mirrors `public.live_status`, narrowed to what the Live screen groups by.
enum LiveStatus { liveNow, upcoming, ended }

/// Mirrors `public.live_sessions`.
class LiveSession {
  const LiveSession({
    required this.id,
    required this.subject,
    required this.title,
    required this.teacherName,
    required this.teacherInitials,
    required this.scheduleLabel,
    required this.studentsEnrolled,
    required this.startsInSeconds,
    this.status = LiveStatus.upcoming,
    this.chapterLabel,
    this.durationLabel,
  });

  final String id;
  final String subject;
  final String title;
  final String teacherName;
  final String teacherInitials;

  /// "Today • 6:00 PM"
  final String scheduleLabel;
  final int studentsEnrolled;
  final int startsInSeconds;
  final LiveStatus status;

  /// "Chapter 04 · Quadratic Equations"
  final String? chapterLabel;

  /// Set once the class has ended and a recording exists.
  final String? durationLabel;

  bool get hasRecording => status == LiveStatus.ended && durationLabel != null;
}

/// A day cell in the month grid, with its event dot.
class CalendarDay {
  const CalendarDay({required this.day, this.markColor});

  final int day;

  /// Event-type dot under the date, null when nothing is scheduled.
  final int? markColor;
}

/// A chat/question/note entry inside the live classroom panel.
class LiveMessage {
  const LiveMessage({
    required this.author,
    required this.initials,
    required this.body,
    this.isTeacher = false,
    this.meta,
  });

  final String author;
  final String initials;
  final String body;
  final bool isTeacher;

  /// "Asked by Priya • 12 upvotes" / "Answered"
  final String? meta;
}
