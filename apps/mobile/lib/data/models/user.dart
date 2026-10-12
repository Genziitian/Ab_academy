/// Mirrors `public.profiles` + `public.student_profiles`.
class Student {
  const Student({
    required this.fullName,
    required this.phone,
    required this.classLevel,
    required this.board,
    required this.medium,
    this.stream,
    this.studentCode,
  });

  final String fullName;
  final String phone;
  final int classLevel;
  final String board;
  final String medium;
  final String? stream;

  /// Permanent random id from `profiles.student_code`, e.g. ABA-S-4MZT8KQ2.
  /// Students quote it to support; it never changes.
  final String? studentCode;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters2;
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// "Class 10 • Bihar Board • Hindi Medium"
  String get summary => 'Class $classLevel • $board • $medium Medium';

  Student copyWith({int? classLevel, String? medium, String? stream}) => Student(
    fullName: fullName,
    phone: phone,
    classLevel: classLevel ?? this.classLevel,
    board: board,
    medium: medium ?? this.medium,
    stream: stream ?? this.stream,
    studentCode: studentCode,
  );
}

/// Mirrors `public.teachers`.
class Teacher {
  const Teacher({required this.displayName, required this.subject, required this.yearsExperience});

  final String displayName;
  final String subject;
  final int yearsExperience;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters2;
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// "Mathematics • 11 years"
  String get credential => '$subject • $yearsExperience years';
}

extension on String {
  String get characters2 => length >= 2 ? substring(0, 2).toUpperCase() : toUpperCase();
}
