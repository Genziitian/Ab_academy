import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/models/user.dart';
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
    final language = bilingual ? 'Hindi + English' : course.language;
    final teachers = course.teachers.isEmpty
        ? const [
            Teacher(
              displayName: 'Faculty Team',
              subject: '',
              yearsExperience: 0,
            ),
          ]
        : course.teachers;
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
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 1 · Thumbnail, full width below the status bar, with the
                  // back button on it.
                  Container(
                    color: AppColors.primaryDeep,
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top,
                    ),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CourseThumbnail(
                            url: course.thumbnailUrl,
                            hue: course.thumbnailHue,
                            shade: false,
                            padding: const EdgeInsets.all(20),
                            child: course.thumbnailUrl == null
                                ? Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      course.stream ??
                                          course.subjects.join(' · '),
                                      style: AppText.tabular(
                                        22,
                                        FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Tag(
                              '${MockData.planDays}-day crash course',
                              color: AppColors.primary,
                              background: AppColors.primaryTint,
                            ),
                            _Tag(
                              'Class ${course.classLevel} · ${course.board}',
                              color: AppColors.textBody,
                              background: AppColors.fillMuted,
                            ),
                            if (course.badge != null)
                              _Tag(
                                course.badge!,
                                color: Colors.white,
                                background: AppColors.warning,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(course.title, style: AppText.h3),
                        if (course.rating != null) ...[
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '★ ${course.rating}',
                                  style: AppText.tabular(
                                    13,
                                    FontWeight.w700,
                                    color: const Color(0xFFE0A33A),
                                  ),
                                ),
                                if (course.reviewCount != null)
                                  TextSpan(
                                    text:
                                        '  (${NumberFormat.decimalPattern('en_IN').format(course.reviewCount)} ratings)',
                                    style: AppText.meta,
                                  ),
                              ],
                            ),
                          ),
                        ],

                        // 2 · Teacher.
                        const SizedBox(height: 16),
                        for (final teacher in teachers.take(3)) ...[
                          Row(
                            children: [
                              InitialsAvatar(
                                initials: teacher.initials,
                                size: 40,
                                fontSize: 14,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      teacher.displayName,
                                      style: AppText.tabular(
                                        15,
                                        FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      course.subjects.length == 1 &&
                                              teacher.subject ==
                                                  course.subjects.first
                                          ? '${teacher.subject} teacher'
                                          : 'Course teacher',
                                      style: AppText.meta,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],

                        // 3 · Language and duration.
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 18,
                          runSpacing: 8,
                          children: [
                            _Fact(icon: LucideIcons.languages, text: language),
                            _Fact(
                              icon: LucideIcons.calendarDays,
                              text: '${MockData.planDays} days',
                            ),
                            if (course.lessonsCount > 0)
                              _Fact(
                                icon: LucideIcons.playCircle,
                                text: '${course.lessonsCount}+ lectures',
                              ),
                          ],
                        ),

                        // 4 · What you get.
                        if (course.highlights.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text('What you get', style: AppText.sectionTitle),
                          const SizedBox(height: 12),
                          AppCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            child: Column(
                              children: [
                                for (final (i, item)
                                    in course.highlights.indexed)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            style: AppText.tabular(
                                              14,
                                              FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],

                        if (course.description.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text(
                            'About this course',
                            style: AppText.sectionTitle,
                          ),
                          const SizedBox(height: 8),
                          Text(course.description, style: AppText.body),
                        ],
                        const SizedBox(height: 18),
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

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.color, required this.background});

  final String label;
  final Color color;
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
        style: AppText.tabular(11, FontWeight.w600, color: color),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppText.tabular(13, FontWeight.w500, color: AppColors.ink),
        ),
      ],
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
