import 'user.dart';

/// Mirrors `public.lesson_type` + the lesson row states in the design's component sheet.
enum LessonState { completed, current, live, locked, notes }

enum LessonKind { recorded, live, notes, test }

/// Mirrors `public.lessons`.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.kind,
    required this.state,
    this.durationLabel,
    this.resumeLabel,
    this.scheduleLabel,
    this.sizeLabel,
  });

  final String id;
  final String title;
  final LessonKind kind;
  final LessonState state;

  /// "Recorded • 32 min"
  final String? durationLabel;

  /// "Resume at 38:14"
  final String? resumeLabel;

  /// "LIVE • Today 6:00 PM"
  final String? scheduleLabel;

  /// "PDF • 2.4 MB"
  final String? sizeLabel;

  String get subtitle => [
    if (durationLabel != null) durationLabel!,
    if (resumeLabel != null) resumeLabel!,
  ].join(' · ');
}

/// Mirrors `public.chapters`.
class Chapter {
  const Chapter({
    required this.number,
    required this.title,
    required this.lessonsCompleted,
    required this.lessonsTotal,
    this.lessons = const [],
    this.isLocked = false,
    this.unlockLabel,
    this.trailingNote,
    this.subject = 'Physics',
  });

  final int number;

  /// Subject the chapter belongs to — drives the Curriculum subject tabs.
  final String subject;
  final String title;
  final int lessonsCompleted;
  final int lessonsTotal;
  final List<Lesson> lessons;
  final bool isLocked;

  /// "Unlocks 22 Sept"
  final String? unlockLabel;

  /// Overrides the default "n / m lessons", e.g. "0 / 5 lessons · live today".
  final String? trailingNote;

  /// "CHAPTER 01"
  String get label => 'CHAPTER ${number.toString().padLeft(2, '0')}';

  String get progressLabel =>
      trailingNote ?? '$lessonsCompleted / $lessonsTotal lessons';

  double get progress =>
      lessonsTotal == 0 ? 0 : lessonsCompleted / lessonsTotal;
}

/// Mirrors `public.courses` + `public.course_batches`.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.board,
    required this.classLevel,
    required this.batchLabel,
    required this.progressPercent,
    required this.chaptersCompleted,
    required this.chaptersTotal,
    required this.subjects,
    required this.teachers,
    required this.priceInr,
    required this.originalPriceInr,
    this.description = '',
    this.nextUpLabel,
    this.isEnrolled = true,
    this.lessonsCount = 0,
    this.notesCount = 0,
    this.liveClassesCount = 0,
    this.highlights = const [],
    this.validityNote,
    this.stream,
    this.tagline,
    this.badge,
    this.language = 'Hindi + English',
    this.rating,
    this.reviewCount,
    this.questionsCount,
    this.thumbnailHue = 214,
    this.thumbnailUrl,
    this.planDay,
  });

  final String id;
  final String title;

  /// "All subjects • Amit Sir, Neha Ma'am +4"
  final String subtitle;
  final String board;
  final int classLevel;

  /// "BIHAR BOARD • 2027 BATCH"
  final String batchLabel;
  final int progressPercent;
  final int chaptersCompleted;
  final int chaptersTotal;
  final List<String> subjects;
  final List<Teacher> teachers;
  final int priceInr;
  final int originalPriceInr;
  final String description;

  /// "Next: Mathematics • Quadratic Equations"
  final String? nextUpLabel;
  final bool isEnrolled;
  final int lessonsCount;
  final int notesCount;
  final int liveClassesCount;
  final List<String> highlights;
  final String? validityNote;

  /// Short stream label for thumbnails, e.g. "Science · PCM + PCB".
  final String? stream;

  /// "Physics · Chemistry · Maths · Biology"
  final String? tagline;

  /// "Bestseller", "Top rated", "New"
  final String? badge;
  final String language;
  final double? rating;
  final int? reviewCount;
  final int? questionsCount;

  /// Hue for the course thumbnail gradient — matches `thumbnail_hue` in the DB.
  final int thumbnailHue;

  /// Uploaded course artwork (`courses.thumbnail_url`); null shows the
  /// gradient in [thumbnailHue].
  final String? thumbnailUrl;

  /// Day of the 90-day plan the student is on, for enrolled crash courses.
  final int? planDay;

  int get discountPercent =>
      originalPriceInr <= priceInr || originalPriceInr == 0
      ? 0
      : (((originalPriceInr - priceInr) / originalPriceInr) * 100).round();

  double get progress => progressPercent / 100;

  /// "12 of 28 chapters completed"
  String get chaptersLabel =>
      '$chaptersCompleted of $chaptersTotal chapters completed';

  /// "12 / 28 chapters"
  String get chaptersShortLabel =>
      '$chaptersCompleted / $chaptersTotal chapters';
}
