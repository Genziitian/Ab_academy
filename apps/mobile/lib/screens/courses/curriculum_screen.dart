import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(curriculumSubjectProvider);
    final expanded = ref.watch(expandedChapterProvider);

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
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          SquareIconButton(
                            icon: LucideIcons.chevronLeft,
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 12),
                          Text('Classes', style: AppText.tabular(16, FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ChipRow(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        for (final name in MockData.allSubjects)
                          FilterChipPill(
                            label: name,
                            selected: subject == name,
                            onTap: () => ref.read(curriculumSubjectProvider.notifier).select(name),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: MockData.chapters.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chapter = MockData.chapters[index];
                  if (chapter.isLocked) return _LockedChapterCard(chapter: chapter);
                  return _ChapterCard(
                    chapter: chapter,
                    expanded: expanded == chapter.number,
                    onToggle: () =>
                        ref.read(expandedChapterProvider.notifier).toggle(chapter.number),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.chapter, required this.expanded, required this.onToggle});

  final Chapter chapter;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final complete = chapter.lessonsCompleted == chapter.lessonsTotal;
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chapter.label, style: AppText.eyebrow(letterSpacing: 0.8)),
                        const SizedBox(height: 5),
                        Text(chapter.title, style: AppText.tabular(15.5, FontWeight.w700)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            ProgressBar(
                              value: chapter.progress,
                              width: 74,
                              height: 5,
                              color: complete || chapter.progress >= 0.75
                                  ? AppColors.science
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              chapter.progressLabel,
                              style: AppText.tabular(
                                11.5,
                                FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.dividerSoft)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  if (chapter.lessons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                      child: Text(
                        'Lessons for this chapter unlock as the batch progresses.',
                        style: AppText.metaSm.copyWith(height: 1.5),
                      ),
                    )
                  else
                    for (final lesson in chapter.lessons) LessonRow(lesson: lesson),
                ],
              ),
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

/// One lesson inside an expanded chapter — five visual states from the design.
class LessonRow extends StatelessWidget {
  const LessonRow({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final isCurrent = lesson.state == LessonState.current;

    return InkWell(
      onTap: switch (lesson.state) {
        LessonState.current ||
        LessonState.completed => () => context.push(Routes.lesson(lesson.id)),
        LessonState.live => () => context.push(Routes.liveLobby),
        LessonState.notes => () => showDemoSnack(context, 'Downloading ${lesson.title}'),
        LessonState.locked => null,
      },
      child: Container(
        color: isCurrent ? const Color(0xFFF7F8FC) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            _LessonStateIcon(state: lesson.state),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppText.tabular(
                      13.5,
                      switch (lesson.state) {
                        LessonState.current || LessonState.live => FontWeight.w700,
                        _ => FontWeight.w500,
                      },
                      color: switch (lesson.state) {
                        LessonState.completed => AppColors.textMuted,
                        LessonState.locked => AppColors.textFaint,
                        _ => AppColors.ink,
                      },
                    ).copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    switch (lesson.state) {
                      LessonState.live => lesson.scheduleLabel ?? '',
                      LessonState.notes => lesson.sizeLabel ?? '',
                      _ => lesson.subtitle,
                    },
                    style: AppText.tabular(
                      11.5,
                      FontWeight.w400,
                      color: lesson.state == LessonState.live
                          ? AppColors.live
                          : (lesson.state == LessonState.current
                                ? AppColors.textSubtle
                                : AppColors.textFaint),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _LessonTrailing(lesson: lesson),
          ],
        ),
      ),
    );
  }
}

class _LessonStateIcon extends StatelessWidget {
  const _LessonStateIcon({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (state) {
          LessonState.completed => AppColors.scienceTint,
          LessonState.current => AppColors.primaryTint,
          LessonState.live => AppColors.liveTint,
          LessonState.notes => AppColors.fillMuted,
          LessonState.locked => AppColors.fillMuted,
        },
      ),
      child: switch (state) {
        LessonState.completed => const Icon(LucideIcons.check, size: 15, color: AppColors.science),
        LessonState.current => const Icon(
          Icons.play_arrow_rounded,
          size: 17,
          color: AppColors.primary,
        ),
        LessonState.live => const LiveDot(size: 8),
        LessonState.notes => const Icon(LucideIcons.fileText, size: 14, color: Color(0xFFC43B3B)),
        LessonState.locked => const Icon(LucideIcons.lock, size: 13, color: AppColors.textFaint),
      },
    );
  }
}

class _LessonTrailing extends StatelessWidget {
  const _LessonTrailing({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return switch (lesson.state) {
      LessonState.current => const Icon(
        LucideIcons.chevronRight,
        size: 16,
        color: AppColors.primary,
      ),
      LessonState.live => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        child: Text('Join', style: AppText.tabular(11.5, FontWeight.w700, color: Colors.white)),
      ),
      LessonState.notes => const Icon(LucideIcons.download, size: 17, color: AppColors.textMuted),
      _ => const SizedBox.shrink(),
    };
  }
}

class _LockedChapterCard extends StatelessWidget {
  const _LockedChapterCard({required this.chapter});

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return DottedBorderBox(
      child: Row(
        children: [
          const Icon(LucideIcons.lock, size: 18, color: AppColors.textFaint),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${chapter.label.replaceAll('CHAPTER', 'Chapter')} · ${chapter.title}',
                style: AppText.cardTitleSm.copyWith(color: AppColors.textSubtle),
              ),
              const SizedBox(height: 3),
              Text(
                chapter.unlockLabel ?? '',
                style: AppText.metaSm.copyWith(color: AppColors.textFaint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dashed hairline container used for locked and empty states.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        padding: padding,
        decoration: const BoxDecoration(
          color: AppColors.surfaceHover,
          borderRadius: AppRadius.card,
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderInput
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18));
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
