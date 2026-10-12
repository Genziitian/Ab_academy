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

/// 08 · Course & curriculum — subject tabs over expandable chapters.
class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key, this.courseId});

  /// Falls back to the student's first course when opened without one.
  final String? courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = courseId ?? MockData.scienceCrash.id;
    final course = ref.watch(remoteCourseProvider(id)).value;
    final chaptersAsync = ref.watch(remoteCurriculumProvider(id));
    final subjects = (course?.subjects.isNotEmpty ?? false)
        ? course!.subjects
        : MockData.scienceSubjects;
    final selected = ref.watch(curriculumSubjectProvider);
    final subject = subjects.contains(selected) ? selected : subjects.first;
    final expanded = ref.watch(expandedChapterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Curriculum',
        subtitle: course?.title ?? 'My course',
        bottom: subjects.length > 1
            ? UnderlineTabs(
                tabs: subjects.map(_short).toList(),
                selected: _short(subject),
                gap: 18,
                onSelected: (label) => ref
                    .read(curriculumSubjectProvider.notifier)
                    .select(subjects.firstWhere((s) => _short(s) == label)),
              )
            : null,
      ),
      body: chaptersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: EmptyState(
            icon: LucideIcons.wifiOff,
            title: 'Could not load the curriculum',
            body: 'Check your connection and try again.',
          ),
        ),
        data: (all) {
          // Mock chapters and single-subject courses show everything.
          final chapters = all.any((c) => c.subject == subject)
              ? all.where((c) => c.subject == subject).toList()
              : subjects.length == 1
              ? all
              : <Chapter>[];
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: chapters.isEmpty ? 1 : chapters.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (chapters.isEmpty) {
                return EmptyState(
                  icon: LucideIcons.bookOpen,
                  title: 'Chapters coming soon',
                  body: 'Teachers are still adding $subject lessons.',
                );
              }
              final chapter = chapters[index];
              return _ChapterCard(
                chapter: chapter,
                displayNumber: index + 1,
                expanded: !chapter.isLocked && expanded == chapter.number,
                onToggle: chapter.isLocked
                    ? null
                    : () => ref
                          .read(expandedChapterProvider.notifier)
                          .toggle(chapter.number),
              );
            },
          );
        },
      ),
    );
  }

  static String _short(String subject) =>
      subject == 'Mathematics' ? 'Maths' : subject;
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.displayNumber,
    required this.expanded,
    required this.onToggle,
  });

  final Chapter chapter;
  final int displayNumber;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final locked = chapter.isLocked;
    return Opacity(
      opacity: locked ? 0.6 : 1,
      child: AppCard(
        padding: EdgeInsets.zero,
        clip: true,
        borderColor: expanded ? AppColors.primaryTintBorder : AppColors.border,
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: locked
                            ? AppColors.fillMuted
                            : AppColors.primaryTint,
                        borderRadius: AppRadius.xs,
                      ),
                      child: Text(
                        displayNumber.toString().padLeft(2, '0'),
                        style: AppText.tabular(
                          12,
                          FontWeight.w600,
                          color: locked
                              ? AppColors.textSubtle
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chapter.title, style: AppText.cardTitle),
                          const SizedBox(height: 1),
                          Text(
                            locked
                                ? (chapter.unlockLabel ?? 'Locked')
                                : chapter.progressLabel,
                            style: AppText.meta,
                          ),
                        ],
                      ),
                    ),
                    if (locked)
                      Text(
                        'Locked',
                        style: AppText.tabular(
                          12,
                          FontWeight.w400,
                          color: AppColors.textSubtle,
                        ),
                      )
                    else
                      Text(
                        expanded ? '−' : '+',
                        style: AppText.tabular(
                          16,
                          FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (expanded && chapter.lessons.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    for (final lesson in chapter.lessons) ...[
                      LessonRow(lesson: lesson),
                      if (lesson != chapter.lessons.last)
                        const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One lesson in a chapter: status tile, title and meta line.
class LessonRow extends StatelessWidget {
  const LessonRow({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final current = lesson.state == LessonState.current;
    final onTap = switch (lesson.state) {
      LessonState.current ||
      LessonState.completed => () => context.push(Routes.lesson(lesson.id)),
      LessonState.live => () => context.push(Routes.liveLobby),
      LessonState.notes => () => context.push(
        Routes.pdf(lesson.id, lesson: true),
        extra: lesson.title,
      ),
      LessonState.locked => null,
    };

    final meta = switch (lesson.state) {
      LessonState.current => lesson.resumeLabel ?? lesson.durationLabel ?? '',
      LessonState.live => lesson.scheduleLabel ?? '',
      LessonState.notes => lesson.sizeLabel ?? '',
      _ => lesson.durationLabel ?? '',
    }.replaceAll('•', '·');

    final metaColor = switch (lesson.state) {
      LessonState.current => AppColors.primary,
      LessonState.live => AppColors.liveInk,
      _ => AppColors.textMuted,
    };

    return Material(
      color: current ? AppColors.primarySoft : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.xs,
        side: current
            ? const BorderSide(color: AppColors.primaryTintBorder)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xs,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              _StatusTile(state: lesson.state),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AppText.tabular(13, FontWeight.w600),
                    ),
                    Text(
                      meta,
                      style: AppText.tabular(
                        11,
                        FontWeight.w400,
                        color: metaColor,
                      ),
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

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, size) = switch (state) {
      LessonState.completed => (
        AppColors.successTint,
        AppColors.success,
        '✓',
        11.0,
      ),
      LessonState.current => (AppColors.primary, Colors.white, '▶', 10.0),
      LessonState.live => (AppColors.liveTint, AppColors.liveInk, '●', 10.0),
      LessonState.notes => (AppColors.pdfTint, AppColors.liveInk, 'PDF', 8.0),
      LessonState.locked => (
        AppColors.fillMuted,
        AppColors.textSubtle,
        '🔒',
        10.0,
      ),
    };
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Text(
        label,
        style: AppText.tabular(size, FontWeight.w700, color: fg),
      ),
    );
  }
}
