/// Mirrors `public.lesson_comments` — the discussion under a lecture.
class LessonComment {
  const LessonComment({
    required this.id,
    required this.author,
    required this.initials,
    required this.body,
    required this.timeLabel,
    this.isTeacher = false,
    this.isMe = false,
    this.replies = const [],
  });

  final String id;
  final String author;
  final String initials;
  final String body;
  final String timeLabel;
  final bool isTeacher;
  final bool isMe;
  final List<LessonComment> replies;
}

/// Mirrors `public.lesson_feedback` — one rating per student per lesson.
class LessonFeedback {
  const LessonFeedback({
    required this.averageRating,
    required this.ratingCount,
    this.myRating,
    this.myComment,
  });

  final double averageRating;
  final int ratingCount;

  /// Null until the student rates the lesson.
  final int? myRating;
  final String? myComment;

  bool get hasRated => myRating != null;

  LessonFeedback copyWith({int? myRating, String? myComment}) => LessonFeedback(
    // A new rating shifts the average; recomputed so the UI reacts immediately.
    averageRating: myRating == null
        ? averageRating
        : ((averageRating * ratingCount) + myRating) / (ratingCount + 1),
    ratingCount: myRating == null || hasRated ? ratingCount : ratingCount + 1,
    myRating: myRating ?? this.myRating,
    myComment: myComment ?? this.myComment,
  );
}

/// A PDF attached to a lecture, opened by the in-app viewer.
class LessonAttachment {
  const LessonAttachment({
    required this.id,
    required this.title,
    required this.sizeLabel,
    required this.assetPath,
  });

  final String id;
  final String title;
  final String sizeLabel;

  /// Bundled asset for now; becomes a Supabase storage path later.
  final String assetPath;
}
