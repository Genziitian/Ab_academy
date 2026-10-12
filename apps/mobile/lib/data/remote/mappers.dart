import '../models/course.dart';
import '../models/ticket.dart';
import '../models/user.dart';

typedef Json = Map<String, dynamic>;

/// "2h ago" / "Yesterday" / "12 Sept" — the label shape the widgets expect.
String relativeLabel(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${when.day} ${months[when.month - 1]}';
}

DateTime parseTs(Object? value) =>
    DateTime.tryParse(value?.toString() ?? '')?.toLocal() ?? DateTime.now();

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final one = parts.first;
    return (one.length >= 2 ? one.substring(0, 2) : one).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _durationLabel(int? seconds) {
  if (seconds == null || seconds == 0) return '';
  final m = (seconds / 60).round();
  return m < 60 ? '$m min' : '${m ~/ 60}h ${m % 60}m';
}

String sizeLabel(int? bytes) {
  if (bytes == null || bytes == 0) return 'PDF';
  final mb = bytes / 1048576;
  return mb >= 1
      ? 'PDF • ${mb.toStringAsFixed(1)} MB'
      : 'PDF • ${(bytes / 1024).round()} KB';
}

// ------------------------------------------------------------------ student

Student studentFromRows(Json profile, Json? studentProfile) {
  return Student(
    fullName: (profile['full_name'] as String?)?.trim().isNotEmpty == true
        ? profile['full_name'] as String
        : 'Student',
    phone: (profile['phone'] as String?) ?? (profile['email'] as String?) ?? '',
    classLevel: (studentProfile?['class_level'] as int?) ?? 10,
    board: (studentProfile?['board'] as String?) ?? 'Bihar Board',
    medium: (studentProfile?['medium'] as String?) ?? 'Hindi',
    stream: studentProfile?['stream'] as String?,
    studentCode: profile['student_code'] as String?,
  );
}

// ------------------------------------------------------------------- course

Course courseFromRow(Json row, {required bool isEnrolled}) {
  final teacherRows = (row['course_teachers'] as List?) ?? const [];
  final teachers = teacherRows
      .map((e) => (e as Json)['teachers'] as Json?)
      .where((t) => t != null)
      .map(
        (t) => Teacher(
          displayName: (t!['display_name'] as String?) ?? 'Faculty',
          subject:
              ((t['subjects'] as List?)?.firstOrNull as String?) ?? 'Faculty',
          yearsExperience: 0,
        ),
      )
      .toList();

  final subjects = ((row['subjects'] as List?) ?? const []).cast<String>();
  final batches = (row['course_batches'] as List?) ?? const [];
  final batchName = batches.isEmpty
      ? 'Current Batch'
      : ((batches.first as Json)['name'] as String? ?? 'Current Batch');

  final teacherNames = teachers.map((t) => t.displayName).toList();
  final subtitleTeachers = teacherNames.length <= 2
      ? teacherNames.join(', ')
      : '${teacherNames.take(2).join(', ')} +${teacherNames.length - 2}';

  return Course(
    id: row['id'] as String,
    title: (row['title'] as String?) ?? 'Course',
    subtitle: [
      subjects.isEmpty ? 'All subjects' : '${subjects.length} subjects',
      if (subtitleTeachers.isNotEmpty) subtitleTeachers,
    ].join(' • '),
    board: (row['board'] as String?) ?? 'Bihar Board',
    classLevel: (row['class_level'] as int?) ?? 10,
    batchLabel:
        '${((row['board'] as String?) ?? 'Bihar Board').toUpperCase()} • '
        '${batchName.toUpperCase()}',
    // Progress needs lesson_progress, which is not modelled yet; show 0 rather
    // than inventing a number.
    progressPercent: 0,
    chaptersCompleted: 0,
    chaptersTotal: 0,
    subjects: subjects,
    teachers: teachers,
    priceInr: (row['price_inr'] as int?) ?? 0,
    originalPriceInr: (row['original_price_inr'] as int?) ?? 0,
    description: (row['description'] as String?) ?? '',
    isEnrolled: isEnrolled,
    lessonsCount: (row['lessons_count'] as int?) ?? 0,
    highlights: ((row['highlights'] as List?) ?? const []).cast<String>(),
    rating: (row['rating'] as num?)?.toDouble(),
    thumbnailHue: (row['thumbnail_hue'] as int?) ?? 214,
    language: (row['language'] as String?) ?? 'Hindi + English',
  );
}

// ------------------------------------------------------------------ lessons

LessonKind _kindOf(String? type) => switch (type) {
  'LIVE' => LessonKind.live,
  'PDF' => LessonKind.notes,
  'TEST' => LessonKind.test,
  _ => LessonKind.recorded,
};

Lesson lessonFromRow(Json row, {required bool hasAccess}) {
  final type = row['lesson_type'] as String?;
  final isDemo = (row['is_demo'] as bool?) ?? false;
  final locked = !hasAccess && !isDemo;

  return Lesson(
    id: row['id'] as String,
    title: (row['title'] as String?) ?? 'Lesson',
    kind: _kindOf(type),
    state: locked ? LessonState.locked : LessonState.current,
    durationLabel: switch (_kindOf(type)) {
      LessonKind.recorded => [
        'Recorded',
        _durationLabel(row['duration_seconds'] as int?),
      ].where((s) => s.isNotEmpty).join(' • '),
      LessonKind.live => 'Live class',
      LessonKind.notes => 'Notes',
      LessonKind.test => 'Test',
    },
  );
}

/// Groups flat lesson rows by chapter, in the shape the curriculum accordion wants.
List<Chapter> chaptersFromLessons(List<Json> rows, {required bool hasAccess}) {
  final byChapter = <String, List<Json>>{};
  final titles = <String, String>{};
  final subjects = <String, String>{};

  for (final row in rows) {
    final chapter = row['chapters'] as Json?;
    final id = (chapter?['id'] as String?) ?? 'unknown';
    titles[id] = (chapter?['title'] as String?) ?? 'Chapter';
    subjects[id] =
        ((chapter?['subjects'] as Json?)?['name'] as String?) ?? 'General';
    (byChapter[id] ??= []).add(row);
  }

  var number = 0;
  return byChapter.entries.map((entry) {
    number++;
    final lessons = entry.value
        .map((r) => lessonFromRow(r, hasAccess: hasAccess))
        .toList();
    return Chapter(
      number: number,
      title: titles[entry.key] ?? 'Chapter',
      subject: subjects[entry.key] ?? 'General',
      lessonsCompleted: 0,
      lessonsTotal: lessons.length,
      lessons: lessons,
      isLocked:
          !hasAccess && lessons.every((l) => l.state == LessonState.locked),
    );
  }).toList();
}

// ------------------------------------------------------------------ tickets

TicketStatus ticketStatusFrom(String? value) => switch (value) {
  'in_progress' => TicketStatus.inProgress,
  'resolved' => TicketStatus.resolved,
  'closed' => TicketStatus.closed,
  _ => TicketStatus.open,
};

String ticketStatusTo(TicketStatus status) => switch (status) {
  TicketStatus.inProgress => 'in_progress',
  TicketStatus.resolved => 'resolved',
  TicketStatus.closed => 'closed',
  TicketStatus.open => 'open',
};

TicketCategory ticketCategoryFrom(String? value) => switch (value) {
  'payment' => TicketCategory.payment,
  'content' => TicketCategory.content,
  'technical' => TicketCategory.technical,
  'account' => TicketCategory.account,
  _ => TicketCategory.other,
};

String ticketCategoryTo(TicketCategory category) => switch (category) {
  TicketCategory.payment => 'payment',
  TicketCategory.content => 'content',
  TicketCategory.technical => 'technical',
  TicketCategory.account => 'account',
  TicketCategory.other => 'other',
};

Ticket ticketFromRow(Json row) {
  final messageRows =
      ((row['ticket_messages'] as List?) ?? const []).cast<Json>().toList()
        ..sort(
          (a, b) =>
              parseTs(a['created_at']).compareTo(parseTs(b['created_at'])),
        );

  return Ticket(
    id: row['id'] as String,
    reference: (row['reference'] as String?) ?? '—',
    subject: (row['subject'] as String?) ?? '',
    category: ticketCategoryFrom(row['category'] as String?),
    status: ticketStatusFrom(row['status'] as String?),
    openedLabel: 'Opened ${relativeLabel(parseTs(row['created_at']))}',
    messages: messageRows.map((m) {
      final fromSupport = (m['from_support'] as bool?) ?? false;
      return TicketMessage(
        id: m['id'] as String,
        body: (m['body'] as String?) ?? '',
        timeLabel: relativeLabel(parseTs(m['created_at'])),
        fromSupport: fromSupport,
        authorName: fromSupport
            ? ((m['profiles'] as Json?)?['full_name'] as String?) ?? 'Support'
            : null,
      );
    }).toList(),
  );
}
