import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/course.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';

/// 07 · My courses — the student's enrolled courses as large cards.
class MyCoursesView extends ConsumerWidget {
  const MyCoursesView({super.key, required this.onExplore, this.query = ''});

  /// Switches the Courses tab to Explore.
  final VoidCallback onExplore;

  /// Search text from the Courses header.
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(remoteMyCoursesProvider);
    final q = query.trim().toLowerCase();

    return RefreshIndicator(
      onRefresh: () => ref.refresh(remoteMyCoursesProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
        children: [
          ...async.when(
            loading: () => const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => const [
              EmptyState(
                icon: LucideIcons.wifiOff,
                title: 'Could not load your courses',
                body: 'Check your connection and pull down to try again.',
              ),
            ],
            data: (courses) {
              final shown = courses
                  .where((c) => q.isEmpty || c.title.toLowerCase().contains(q))
                  .toList();
              if (shown.isEmpty) {
                return [
                  EmptyState(
                    icon: LucideIcons.bookOpen,
                    title: q.isEmpty ? 'No courses yet' : 'No matches',
                    body: q.isEmpty
                        ? 'Pick a crash course for your class to get started.'
                        : 'Nothing in your courses matches “$query”.',
                  ),
                  const SizedBox(height: 16),
                ];
              }
              return [
                for (final course in shown) ...[
                  MyCourseCard(course: course),
                  const SizedBox(height: 22),
                ],
              ];
            },
          ),
          SoftCard(
            onTap: onExplore,
            child: Row(
              children: [
                const TintIcon(
                  icon: LucideIcons.compass,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Explore more crash courses',
                    style: AppText.tabular(16, FontWeight.w600),
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textSubtle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Large enrolled-course card: artwork header with the title, teacher, the
/// chapter / lecture / notes counts and a Continue button.
class MyCourseCard extends ConsumerWidget {
  const MyCourseCard({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(courseStatsProvider(course.id)).value;
    final teacher = course.teachers.isEmpty
        ? 'Faculty Team'
        : course.teachers.first.displayName;
    final subject = course.subjects.length == 1
        ? course.subjects.first
        : '${course.subjects.length} subjects';
    void open() => context.push(Routes.curriculum, extra: course.id);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14122046),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 176,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (course.thumbnailUrl == null)
                      const DecoratedBox(
                        decoration: BoxDecoration(gradient: AppGradients.brand),
                      )
                    else
                      CourseThumbnail(
                        url: course.thumbnailUrl,
                        hue: course.thumbnailHue,
                      ),
                    // Decorative circle, as on the gradient headers.
                    Positioned(
                      right: -40,
                      top: -30,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Tag('CLASS ${course.classLevel}'),
                              const Spacer(),
                              _Tag(course.priceInr == 0 ? 'FREE' : 'PRO'),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.tabular(
                              24,
                              FontWeight.w700,
                              color: Colors.white,
                            ).copyWith(letterSpacing: -0.5, height: 1.15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTint,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            teacher.characters.first,
                            style: AppText.tabular(
                              16,
                              FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            teacher,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.tabular(16, FontWeight.w500),
                          ),
                        ),
                        Text(
                          '  ·  $subject',
                          style: AppText.tabular(
                            15,
                            FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          _Stat('${stats?.chapters ?? '–'}', 'Chapters'),
                          const _StatDivider(),
                          _Stat('${stats?.lectures ?? '–'}', 'Lectures'),
                          const _StatDivider(),
                          _Stat('${stats?.notes ?? '–'}', 'Notes'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: FilledButton(
                              onPressed: open,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.ink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: AppText.tabular(
                                      17,
                                      FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    LucideIcons.arrowRight,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () =>
                                context.push(Routes.courseDetails(course.id)),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: AppColors.background,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.info,
                              color: AppColors.textBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppText.tabular(13, FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppText.tabular(22, FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppText.tabular(
              13,
              FontWeight.w400,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.border);
}
