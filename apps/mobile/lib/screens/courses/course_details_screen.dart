import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/models/user.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class CourseDetailsScreen extends ConsumerWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseByIdProvider(courseId));
    final tab = ref.watch(courseDetailTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 52,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SquareIconButton(icon: LucideIcons.chevronLeft, onPressed: () => context.pop()),
                  SquareIconButton(
                    icon: LucideIcons.moreVertical,
                    onPressed: () => showDemoSnack(context, 'Course options coming soon'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _CourseHeader(course: course)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      // Five tabs do not fit a 390pt width, so the row scrolls.
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(bottom: BorderSide(color: AppColors.divider)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: UnderlineTabs(
                            tabs: const ['Overview', 'Curriculum', 'Videos', 'Notes', 'Tests'],
                            selected: tab,
                            gap: 18,
                            onSelected: (value) =>
                                ref.read(courseDetailTabProvider.notifier).select(value),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: switch (tab) {
                        'Curriculum' => const _CurriculumTab(),
                        'Videos' => const _VideosTab(),
                        'Notes' => const _NotesTab(),
                        'Tests' => const _TestsTab(),
                        _ => _OverviewTab(course: course),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.batchLabel, style: AppText.eyebrow(color: AppColors.primary)),
          const SizedBox(height: 7),
          Text(course.title, style: AppText.h2.copyWith(fontSize: 25)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your progress',
                style: AppText.labelStrong.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                '${course.progressPercent}%',
                style: AppText.tabular(18, FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ProgressBar(value: course.progress, height: 7),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.trackMuted),
              borderRadius: AppRadius.md,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _StatCell(value: course.lessonsCount, label: 'Lessons'),
                  const VerticalDivider(width: 1, color: AppColors.trackMuted),
                  _StatCell(value: course.notesCount, label: 'Notes'),
                  const VerticalDivider(width: 1, color: AppColors.trackMuted),
                  _StatCell(value: course.liveClassesCount, label: 'Live classes'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text('$value', style: AppText.tabular(18, FontWeight.w800)),
            const SizedBox(height: 3),
            Text(label, style: AppText.tabular(11, FontWeight.w500, color: AppColors.textSubtle)),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this batch', style: AppText.cardTitle),
        const SizedBox(height: 8),
        Text(course.description, style: AppText.body),
        const SizedBox(height: 18),
        Text('Subjects', style: AppText.cardTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final subject in course.subjects) SubjectTag(subject: subject)],
        ),
        const SizedBox(height: 18),
        Text('Your teachers', style: AppText.cardTitle),
        const SizedBox(height: 10),
        for (final teacher in course.teachers) ...[
          _TeacherRow(teacher: teacher),
          if (teacher != course.teachers.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TeacherRow extends StatelessWidget {
  const _TeacherRow({required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(teacher.subject);
    return Row(
      children: [
        InitialsAvatar(
          initials: teacher.initials,
          size: 42,
          fontSize: 13,
          background: palette.tint,
          foreground: palette.ink,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teacher.displayName, style: AppText.cardTitleSm),
            const SizedBox(height: 3),
            Text(teacher.credential, style: AppText.meta),
          ],
        ),
      ],
    );
  }
}

/// Chapter-by-chapter progress; the full accordion lives on the Curriculum screen.
class _CurriculumTab extends StatelessWidget {
  const _CurriculumTab();

  @override
  Widget build(BuildContext context) {
    final chapters = MockData.chapters;
    return Column(
      children: [
        for (final chapter in chapters) ...[
          AppCard(
            borderRadius: AppRadius.md,
            padding: const EdgeInsets.all(15),
            shadow: null,
            onTap: chapter.isLocked ? null : () => context.push(Routes.curriculum),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${chapter.number.toString().padLeft(2, '0')} · ${chapter.title}',
                        style: AppText.rowTitle.copyWith(
                          color: chapter.isLocked ? AppColors.textSubtle : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (chapter.isLocked)
                        Text(chapter.unlockLabel ?? 'Locked', style: AppText.meta)
                      else ...[
                        Row(
                          children: [
                            ProgressBar(
                              value: chapter.progress,
                              width: 74,
                              height: 5,
                              color: chapter.progress >= 0.75
                                  ? AppColors.science
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(chapter.progressLabel, style: AppText.metaSm),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  chapter.isLocked ? LucideIcons.lock : LucideIcons.chevronRight,
                  size: 16,
                  color: chapter.isLocked ? AppColors.textFaint : AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextActionButton(
            label: 'Open full curriculum →',
            onPressed: () => context.push(Routes.curriculum),
          ),
        ),
      ],
    );
  }
}

/// The recorded library — every video in the course, flat, newest first.
class _VideosTab extends StatelessWidget {
  const _VideosTab();

  @override
  Widget build(BuildContext context) {
    final videos = [
      for (final chapter in MockData.chapters)
        for (final lesson in chapter.lessons)
          if (lesson.kind == LessonKind.recorded) (chapter, lesson),
    ];

    if (videos.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.video,
        title: 'No recordings yet',
        body: 'Videos appear here as each class is recorded.',
      );
    }

    return Column(
      children: [
        for (final (chapter, lesson) in videos) ...[
          AppCard(
            borderRadius: AppRadius.md,
            padding: const EdgeInsets.all(12),
            shadow: null,
            onTap: () => context.push(Routes.lesson(lesson.id)),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.mathsTint,
                    borderRadius: AppRadius.xs,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, size: 22, color: AppColors.maths),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chapter.label, style: AppText.eyebrow(letterSpacing: 0.7, size: 10)),
                      const SizedBox(height: 5),
                      Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.tabular(13.5, FontWeight.w700).copyWith(height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text(lesson.durationLabel ?? '', style: AppText.metaSm),
                    ],
                  ),
                ),
                if (lesson.state == LessonState.completed)
                  const Icon(LucideIcons.check, size: 16, color: AppColors.science),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context) {
    final notes = MockData.materials.take(2).toList();
    return Column(
      children: [
        for (final note in notes) ...[
          AppCard(
            borderRadius: AppRadius.md,
            padding: const EdgeInsets.all(15),
            shadow: null,
            onTap: () => showDemoSnack(context, 'Opening ${note.title}'),
            child: Row(
              children: [
                IconTile(
                  background: AppColors.pdfTint,
                  label: note.badge,
                  labelStyle: AppText.badge(
                    color: const Color(0xFFC43B3B),
                    size: 9.5,
                  ).copyWith(letterSpacing: 0),
                  size: 40,
                  radius: 11,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.title, style: AppText.cardTitleSm),
                      const SizedBox(height: 3),
                      Text(note.sizeLabel, style: AppText.metaSm),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (note != notes.last) const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextActionButton(
            label: 'All study materials →',
            onPressed: () => context.push(Routes.materials),
          ),
        ),
      ],
    );
  }
}

class _TestsTab extends StatelessWidget {
  const _TestsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          borderRadius: AppRadius.md,
          padding: const EdgeInsets.all(15),
          color: AppColors.warningTint,
          borderColor: AppColors.warningBorder,
          shadow: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Science Test — Chapter 1–4', style: AppText.rowTitle),
              const SizedBox(height: 6),
              Text(
                'Sunday, 20 Sept • 20 questions • 40 min',
                style: AppText.tabular(12, FontWeight.w400, color: AppColors.warningText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          borderRadius: AppRadius.md,
          padding: const EdgeInsets.all(15),
          shadow: null,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maths Weekly Test 06', style: AppText.rowTitle),
                    const SizedBox(height: 4),
                    Text('Submitted • 17 / 20', style: AppText.meta),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColors.scienceTint,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  '85%',
                  style: AppText.tabular(11, FontWeight.w700, color: AppColors.scienceInk),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Keeps the tab bar pinned under the scrolling course header.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.child});

  static const _height = 49.0;

  final Widget child;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  // Sized explicitly: a child shorter than the declared extent makes the sliver
  // geometry invalid (layoutExtent > paintExtent).
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox(height: _height, child: child);

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => oldDelegate.child != child;
}
