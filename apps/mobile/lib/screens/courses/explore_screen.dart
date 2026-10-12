import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

const _filters = ['Class 12', 'Class 11', 'Science', 'Commerce', 'Arts'];

bool _matches(Course c, String filter) => switch (filter) {
  'Class 12' => c.classLevel == 12,
  'Class 11' => c.classLevel == 11,
  'Science' => c.subjects.any(
    (s) => const ['Physics', 'Chemistry', 'Biology'].contains(s),
  ),
  'Commerce' => c.subjects.contains('Accountancy'),
  'Arts' => c.subjects.contains('History'),
  _ => true,
};

/// 23 · Explore crash courses — the catalog, filtered by class or stream.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(exploreFilterProvider);
    final async = ref.watch(remoteCatalogProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crash courses', style: AppText.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Bihar Board · 90-day plans',
                    style: AppText.bodyCompact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ChipRow(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final f in _filters)
                  FilterChipPill(
                    label: f,
                    selected: filter == f,
                    onTap: () =>
                        ref.read(exploreFilterProvider.notifier).select(f),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...async.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EmptyState(
                    icon: LucideIcons.wifiOff,
                    title: 'Could not load courses',
                    body: 'Check your connection and try again.',
                  ),
                ),
              ],
              data: (catalog) {
                final shown = catalog.where((c) => _matches(c, filter)).toList()
                  ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
                final featured = shown.take(2).toList();
                final rest = shown.skip(2).toList();
                return [
                  if (shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EmptyState(
                        icon: LucideIcons.bookOpen,
                        title: 'Coming soon',
                        body: 'No $filter crash courses are open yet.',
                      ),
                    ),
                  if (featured.isNotEmpty)
                    // Sized by its cards, so larger system text never clips.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (i, c) in featured.indexed) ...[
                            if (i > 0) const SizedBox(width: 12),
                            _FeaturedCard(course: c),
                          ],
                        ],
                      ),
                    ),
                  if (rest.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('All $filter', style: AppText.sectionTitle),
                          const SizedBox(height: 10),
                          ListCard(
                            children: [
                              for (final c in rest) _CourseRow(course: c),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: AppCard(
        clip: true,
        borderRadius: AppRadius.md,
        onTap: () => context.push(Routes.courseDetails(course.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 110,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: courseGradient(course.thumbnailHue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (course.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDeep.withValues(alpha: 0.7),
                        borderRadius: AppRadius.badge,
                      ),
                      child: Text(
                        course.badge!.toUpperCase(),
                        style: AppText.badge(color: Colors.white),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    course.stream ?? course.subjects.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tabular(
                      18,
                      FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (course.lessonsCount > 0)
                        '${course.lessonsCount}+ lectures',
                      if (course.rating != null) '★ ${course.rating}',
                    ].join(' · '),
                    style: AppText.meta,
                  ),
                  const SizedBox(height: 10),
                  _Price(course: course),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: formatRupees(course.priceInr),
            style: AppText.tabular(18, FontWeight.w700),
          ),
          if (course.discountPercent > 0) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: formatRupees(course.originalPriceInr),
              style: AppText.tabular(
                12,
                FontWeight.w400,
                color: AppColors.textMuted,
              ).copyWith(decoration: TextDecoration.lineThrough),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: '${course.discountPercent}% OFF',
              style: AppText.tabular(
                12,
                FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(Routes.courseDetails(course.id)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: courseGradient(course.thumbnailHue),
                borderRadius: AppRadius.sm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: AppText.rowTitle),
                  const SizedBox(height: 1),
                  Text(
                    course.tagline ?? course.subjects.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.meta,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatRupees(course.priceInr),
              style: AppText.tabular(14, FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
