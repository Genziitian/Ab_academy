import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// 24 · Course page — what the crash course includes, with price and enrol.
class CourseDetailsScreen extends ConsumerWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(remoteCourseProvider(courseId));

    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => _Missing(message: 'Could not load this course.'),
      data: (course) => course == null
          ? const _Missing(message: 'This course is not available.')
          : _Body(course),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.course);

  final Course course;

  @override
  Widget build(BuildContext context) {
    final bilingual =
        course.language.contains('Hindi') &&
        course.language.contains('English');
    final stats = [
      ('${course.lessonsCount}+', 'Lectures'),
      ('${MockData.planDays}', 'Days'),
      if (course.questionsCount != null)
        (
          '${NumberFormat.decimalPattern('en_IN').format(course.questionsCount)}+',
          'Questions',
        ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primaryDeep,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _HeaderChip(
                                  '${MockData.planDays}-day crash course',
                                  background: AppColors.primary,
                                ),
                                _HeaderChip(
                                  bilingual
                                      ? 'Hindi + English'
                                      : course.language,
                                  background: Colors.white.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              course.title,
                              style: AppText.h3.copyWith(
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text.rich(
                              TextSpan(
                                style: AppText.tabular(
                                  13,
                                  FontWeight.w400,
                                  color: AppColors.textOnDark,
                                ),
                                children: [
                                  if (course.rating != null) ...[
                                    TextSpan(
                                      text: '★ ${course.rating}',
                                      style: AppText.tabular(
                                        13,
                                        FontWeight.w700,
                                        color: const Color(0xFFFFC56B),
                                      ),
                                    ),
                                    if (course.reviewCount != null)
                                      TextSpan(
                                        text:
                                            ' (${NumberFormat.decimalPattern('en_IN').format(course.reviewCount)})',
                                      ),
                                    const TextSpan(text: ' · '),
                                  ],
                                  TextSpan(
                                    text: course.teachers.isEmpty
                                        ? 'Faculty Team'
                                        : course.teachers
                                              .map((t) => t.displayName)
                                              .join(', '),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          for (var i = 0; i < stats.length; i++) ...[
                            if (i > 0)
                              const VerticalDivider(
                                width: 1,
                                color: AppColors.divider,
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      stats[i].$1,
                                      style: AppText.tabular(
                                        17,
                                        FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      stats[i].$2,
                                      style: AppText.tabular(
                                        11,
                                        FontWeight.w400,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (course.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(course.description, style: AppText.body),
                  ],
                  const SizedBox(height: 14),
                  Text('What you get', style: AppText.sectionTitle),
                  const SizedBox(height: 14),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Column(
                      children: [
                        for (final (i, item) in course.highlights.indexed)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: i < course.highlights.length - 1
                                  ? const Border(
                                      bottom: BorderSide(
                                        color: AppColors.divider,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '✓',
                                  style: AppText.tabular(
                                    14,
                                    FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: AppText.tabular(14, FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (course.validityNote != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      course.validityNote!,
                      style: AppText.meta.copyWith(height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
            _BottomBar(course: course),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(this.label, {required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.badge,
      ),
      child: Text(
        label,
        style: AppText.tabular(11, FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: SafeArea(
        top: false,
        child: course.isEnrolled
            ? PrimaryButton(
                label: 'Go to course',
                onPressed: () =>
                    context.push(Routes.curriculum, extra: course.id),
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatRupees(course.priceInr),
                          style: AppText.tabular(20, FontWeight.w700),
                        ),
                        if (course.discountPercent > 0)
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: formatRupees(course.originalPriceInr),
                                  style:
                                      AppText.tabular(
                                        12,
                                        FontWeight.w400,
                                        color: AppColors.textMuted,
                                      ).copyWith(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                ),
                                TextSpan(
                                  text: '  ${course.discountPercent}% OFF',
                                  style: AppText.tabular(
                                    12,
                                    FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  PrimaryButton(
                    label: 'Enroll now',
                    height: 50,
                    expand: false,
                    onPressed: () => context.push(Routes.checkout(course.id)),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Course'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: EmptyState(
          icon: LucideIcons.bookX,
          title: message,
          body: 'Go back and pick another crash course.',
        ),
      ),
    );
  }
}
