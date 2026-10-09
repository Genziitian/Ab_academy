import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(courseFilterProvider);
    final courses = ref.watch(filteredCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Courses', style: AppText.h3),
                      SquareIconButton(
                        icon: LucideIcons.search,
                        onPressed: () => showDemoSnack(context, 'Course search coming soon'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final label in ['All', 'In Progress', 'Completed']) ...[
                        if (label != 'All') const SizedBox(width: 8),
                        FilterChipPill(
                          label: label,
                          selected: filter == label,
                          onTap: () => ref.read(courseFilterProvider.notifier).select(label),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: courses.isEmpty
                  ? const _EmptyCourses()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      itemCount: courses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _CourseCard(course: courses[index], primary: index == 0),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.primary});

  final Course course;

  /// First card gets the filled CTA, the rest an outlined one — as designed.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final isAllSubjects = course.subjects.length > 1;
    final palette = SubjectPalette.fromName(course.subjects.first);
    final bannerColor = isAllSubjects ? const Color(0xFFE8EAF7) : palette.tint;
    final bannerInk = isAllSubjects ? AppColors.primary : palette.ink;
    final badgeLabel = isAllSubjects
        ? 'CLASS ${course.classLevel}'
        : course.subjects.first.toUpperCase();

    return AppCard(
      borderRadius: AppRadius.lg,
      shadow: AppShadow.cardRaised,
      clip: true,
      onTap: () => context.push(Routes.courseDetails(course.id)),
      child: Column(
        children: [
          SizedBox(
            height: 132,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: bannerColor,
                  alignment: Alignment.center,
                  child: Icon(
                    isAllSubjects ? LucideIcons.bookOpen : LucideIcons.alignLeft,
                    size: 42,
                    color: bannerInk.withValues(alpha: 0.42),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      badgeLabel,
                      style: AppText.eyebrow(color: bannerInk, size: 10, letterSpacing: 0.8),
                    ),
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
                Text(course.title, style: AppText.cardTitleLg),
                const SizedBox(height: 6),
                Text(course.subtitle, style: AppText.metaSm.copyWith(fontSize: 12.5)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${course.progressPercent}% completed',
                      style: AppText.tabular(12, FontWeight.w500, color: AppColors.textMuted),
                    ),
                    Text(
                      course.chaptersShortLabel,
                      style: AppText.tabular(12, FontWeight.w500, color: AppColors.textSubtle),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(value: course.progress),
                if (course.nextUpLabel != null && primary) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: AppRadius.xs,
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 15, color: AppColors.primary),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            course.nextUpLabel!,
                            style: AppText.tabular(
                              12.5,
                              FontWeight.w500,
                              color: AppColors.textBodyAlt,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (primary)
                  PrimaryButton(
                    label: 'Continue Learning',
                    height: 48,
                    onPressed: () => context.push(Routes.courseDetails(course.id)),
                  )
                else
                  SecondaryButton(
                    label: 'Continue Learning',
                    height: 48,
                    foreground: AppColors.primary,
                    borderColor: const Color(0xFFD9DCE8),
                    onPressed: () => context.push(Routes.courseDetails(course.id)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderInput, style: BorderStyle.solid),
            borderRadius: AppRadius.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.bookOpen, size: 30, color: AppColors.textDisabled),
              const SizedBox(height: 10),
              Text('No courses here yet', style: AppText.tabular(13.5, FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Try a different filter to see your other batches.',
                textAlign: TextAlign.center,
                style: AppText.meta.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
