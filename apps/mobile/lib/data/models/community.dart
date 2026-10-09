/// Mirrors `public.communities` — exactly one per course, created by trigger.
class Community {
  const Community({
    required this.id,
    required this.courseId,
    required this.name,
    required this.subject,
    required this.memberCount,
    required this.messages,
  });

  final String id;
  final String courseId;
  final String name;

  /// Drives the accent colour, same as everywhere else in the app.
  final String subject;
  final int memberCount;
  final List<CommunityMessage> messages;

  CommunityMessage? get latest => messages.isEmpty ? null : messages.last;

  /// Announcements float to the top of the feed.
  List<CommunityMessage> get ordered => [
    ...messages.where((m) => m.pinned),
    ...messages.where((m) => !m.pinned),
  ];
}

/// Mirrors `public.community_messages`.
class CommunityMessage {
  const CommunityMessage({
    required this.id,
    required this.author,
    required this.initials,
    required this.body,
    required this.timeLabel,
    this.pinned = false,
    this.isTeacher = false,
    this.isMe = false,
  });

  final String id;
  final String author;
  final String initials;
  final String body;

  /// "2h ago", "Yesterday"
  final String timeLabel;

  /// Pinned messages render as announcements.
  final bool pinned;
  final bool isTeacher;
  final bool isMe;
}
