import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// 07 · My courses — enrolled crash courses with progress.
class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(courseFilterProvider);
    final async = ref.watch(remoteMyCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(remoteMyCoursesProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              Text('My courses', style: AppText.h2),
              const SizedBox(height: 16),
              ...async.when(
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (error, _) => [
                  EmptyState(
                    icon: LucideIcons.wifiOff,
                    title: 'Could not load your courses',
                    body: 'Check your connection and pull down to try again.',
                  ),
                ],
                data: (courses) {
                  final enrolled = courses
                      .where((c) => c.progressPercent < 100)
                      .toList();
                  final completed = courses
                      .where((c) => c.progressPercent >= 100)
                      .toList();
                  final shown = filter == 'Completed' ? completed : enrolled;
                  return [
                    SegmentedTabs(
                      tabs: ['Enrolled (${enrolled.length})', 'Completed'],
                      selected: filter == 'Completed'
                          ? 'Completed'
                          : 'Enrolled (${enrolled.length})',
                      onSelected: (tab) => ref
                          .read(courseFilterProvider.notifier)
                          .select(
                            tab.startsWith('Enrolled')
                                ? 'Enrolled'
                                : 'Completed',
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (shown.isEmpty)
                      EmptyState(
                        icon: LucideIcons.bookOpen,
                        title: filter == 'Completed'
                            ? 'Nothing completed yet'
                            : 'No crash courses yet',
                        body: filter == 'Completed'
                            ? 'Courses you finish will show up here.'
                            : 'Pick a crash course for your class to start the 90-day plan.',
                      ),
                    for (var i = 0; i < shown.length; i++) ...[
                      if (i == 0 && filter != 'Completed')
                        _FeaturedCourseCard(course: shown[i])
                      else
                        _CompactCourseCard(course: shown[i]),
                      const SizedBox(height: 16),
                    ],
                  ];
                },
              ),
              _ExploreBanner(onTap: () => context.push(Routes.explore)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The current crash course: gradient header with the plan day, then stats.
class _FeaturedCourseCard extends StatelessWidget {
  const _FeaturedCourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      clip: true,
      borderRadius: AppRadius.md,
      onTap: () => context.push(Routes.curriculum, extra: course.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 96,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: courseGradient(course.thumbnailHue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: AppRadius.badge,
                  ),
                  child: Text(
                    '${MockData.planDays}-DAY CRASH COURSE',
                    style: AppText.badge(color: Colors.white),
                  ),
                ),
                if (course.planDay != null)
                  Text(
                    'Day ${course.planDay} of ${MockData.planDays}',
                    style: AppText.tabular(
                      12,
                      FontWeight.w400,
                      color: const Color(0xFFDBE6FF),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppText.tabular(16, FontWeight.w600)),
                if (course.nextUpLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    course.nextUpLabel!.replaceAll('•', '·'),
                    style: AppText.tabular(
                      13,
                      FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: ProgressBar(value: course.progress)),
                    const SizedBox(width: 10),
                    Text(
                      '${course.progressPercent}%',
                      style: AppText.tabular(
                        14,
                        FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final (value, label) in [
                      (course.lessonsCount, 'Lessons'),
                      (course.notesCount, 'Notes'),
                      (course.liveClassesCount, 'Live'),
                    ]) ...[
                      if (label != 'Lessons') const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(value: '$value', label: label),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.xs,
      ),
      child: Column(
        children: [
          Text(value, style: AppText.tabular(15, FontWeight.w700)),
          Text(
            label,
            style: AppText.tabular(
              10,
              FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactCourseCard extends StatelessWidget {
  const _CompactCourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: AppRadius.md,
      onTap: () => context.push(Routes.curriculum, extra: course.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.batchLabel.replaceAll('•', '·'),
                      style: AppText.eyebrow(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.title,
                      style: AppText.tabular(16, FontWeight.w600),
                    ),
                    if (course.nextUpLabel != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        course.nextUpLabel!.replaceAll('•', '·'),
                        style: AppText.tabular(
                          13,
                          FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${course.progressPercent}%',
                style: AppText.tabular(
                  18,
                  FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(value: course.progress),
        ],
      ),
    );
  }
}

class _ExploreBanner extends StatelessWidget {
  const _ExploreBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: AppRadius.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Explore more crash courses', style: AppText.rowTitle),
            const Icon(LucideIcons.arrowRight, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
