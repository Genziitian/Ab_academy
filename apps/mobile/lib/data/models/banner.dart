/// Mirrors `public.course_banners` — one slide in the course slider, managed
/// from the admin console's "App slider" page.
class CourseBanner {
  const CourseBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.courseId,
    this.ctaLabel = 'View course',
    this.hue = 214,
  });

  final String id;
  final String title;
  final String? subtitle;

  /// Public URL of the uploaded artwork; null draws a gradient in [hue].
  final String? imageUrl;

  /// Course the slide opens; null makes it informational only.
  final String? courseId;
  final String ctaLabel;
  final int hue;

  factory CourseBanner.fromRow(
    Map<String, dynamic> row, {
    required String publicBase,
  }) {
    final path = row['image_path'] as String?;
    return CourseBanner(
      id: row['id'] as String,
      title: (row['title'] as String?) ?? '',
      subtitle: row['subtitle'] as String?,
      imageUrl: path == null ? null : '$publicBase$path',
      courseId: row['course_id'] as String?,
      ctaLabel: (row['cta_label'] as String?) ?? 'View course',
      hue: (row['hue'] as int?) ?? 214,
    );
  }
}
