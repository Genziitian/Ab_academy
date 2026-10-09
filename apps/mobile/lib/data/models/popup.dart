/// Mirrors `public.popups` — an interstitial card the admin console schedules.
enum PopupPlacement { appLaunch, home, course }

class AppPopup {
  const AppPopup({
    required this.id,
    required this.title,
    required this.body,
    required this.placement,
    required this.maxViewsPerStudent,
    this.imageUrl,
    this.ctaLabel,
    this.ctaUrl,
  });

  final String id;
  final String title;
  final String body;
  final PopupPlacement placement;

  /// 0 means show on every launch; otherwise stop after this many views.
  final int maxViewsPerStudent;
  final String? imageUrl;
  final String? ctaLabel;
  final String? ctaUrl;

  bool get hasCta => ctaLabel != null && ctaUrl != null;

  static PopupPlacement placementFrom(String? value) => switch (value) {
    'home' => PopupPlacement.home,
    'course' => PopupPlacement.course,
    _ => PopupPlacement.appLaunch,
  };

  factory AppPopup.fromRow(Map<String, dynamic> row, {String? publicBase}) {
    final path = row['image_path'] as String?;
    return AppPopup(
      id: row['id'] as String,
      title: (row['title'] as String?) ?? '',
      body: (row['body'] as String?) ?? '',
      placement: placementFrom(row['placement'] as String?),
      maxViewsPerStudent: (row['max_views_per_student'] as int?) ?? 1,
      imageUrl: (path != null && publicBase != null) ? '$publicBase$path' : null,
      ctaLabel: row['cta_label'] as String?,
      ctaUrl: row['cta_url'] as String?,
    );
  }
}
