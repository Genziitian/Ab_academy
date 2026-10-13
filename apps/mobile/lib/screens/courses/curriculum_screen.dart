import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';

const _tabs = ['Curriculum', 'Notes', 'Overview'];

/// 08 · An enrolled course: gradient header card, then Curriculum (chapters
/// that open into lesson tiles), Notes and Overview.
class CurriculumScreen extends ConsumerStatefulWidget {
  const CurriculumScreen({super.key, this.courseId});

  /// Falls back to the first sample course when opened without one.
  final String? courseId;

  @override
  ConsumerState<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends ConsumerState<CurriculumScreen> {
  String _tab = _tabs.first;
  String? _subject;
  int? _open;

  @override
  Widget build(BuildContext context) {
    final id = widget.courseId ?? MockData.scienceCrash.id;
    final course = ref.watch(remoteCourseProvider(id)).value;
    final chaptersAsync = ref.watch(remoteCurriculumProvider(id));
    final all = chaptersAsync.value ?? const <Chapter>[];

    // Only subjects that actually have chapters get a chip.
    final subjects = [
      for (final s in course?.subjects ?? const <String>[])
        if (all.any((c) => c.subject == s)) s,
    ];
    final subject = subjects.contains(_subject)
        ? _subject
        : (subjects.isEmpty ? null : subjects.first);
    final chapters = subject == null
        ? all
        : all.where((c) => c.subject == subject).toList();
    final openIndex = _open ?? (chapters.isEmpty ? null : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _Header(course: course, subject: subject),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: UnderlineTabs(
                tabs: _tabs,
                selected: _tab,
                gap: 26,
                onSelected: (t) => setState(() => _tab = t),
              ),
            ),
            Expanded(
              child: chaptersAsync.isLoading && all.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : switch (_tab) {
                      'Notes' => _NotesTab(courseId: id, chapters: all),
                      'Overview' => _OverviewTab(course: course),
                      _ => ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: [
                          if (subjects.length > 1) ...[
                            SizedBox(
                              height: 38,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: subjects.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (_, i) => ChoiceChip(
                                  label: Text(subjects[i]),
                                  selected: subjects[i] == subject,
                                  onSelected: (_) => setState(() {
                                    _subject = subjects[i];
                                    _open = 0;
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (chapters.isEmpty)
                            const EmptyState(
                              icon: LucideIcons.bookOpen,
                              title: 'Chapters coming soon',
                              body: 'Teachers are still adding lessons.',
                            ),
                          for (var i = 0; i < chapters.length; i++) ...[
                            _ChapterCard(
                              chapter: chapters[i],
                              number: i + 1,
                              expanded: openIndex == i,
                              onToggle: () => setState(
                                () => _open = openIndex == i ? -1 : i,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.course, required this.subject});

  final Course? course;
  final String? subject;

  @override
  Widget build(BuildContext context) {
    final eyebrow = (subject ?? course?.subjects.firstOrNull ?? 'Course')
        .toUpperCase();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -40,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: CircleBorder(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => context.pop(),
                        child: const SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(
                            LucideIcons.chevronLeft,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        '${course?.priceInr == 0 ? 'FREE' : 'PRO'} · CLASS ${course?.classLevel ?? ''}',
                        style: AppText.tabular(
                          13,
                          FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  eyebrow,
                  style: AppText.tabular(
                    15,
                    FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  course?.title ?? 'My course',
                  style: AppText.tabular(
                    26,
                    FontWeight.w700,
                    color: Colors.white,
                  ).copyWith(letterSpacing: -0.6, height: 1.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.number,
    required this.expanded,
    required this.onToggle,
  });

  final Chapter chapter;
  final int number;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final lectures = chapter.lessons
        .where(
          (l) => l.kind != LessonKind.notes && l.state != LessonState.notes,
        )
        .length;
    final notes = chapter.lessons.length - lectures;
    final meta = [
      '$lectures lecture${lectures == 1 ? '' : 's'}',
      if (notes > 0) '$notes note${notes == 1 ? '' : 's'}',
    ].join('  ·  ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: expanded ? const Color(0xFFC9D6F5) : const Color(0xFFE7EBF3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHAPTER ${number.toString().padLeft(2, '0')}',
                          style: AppText.tabular(
                            11,
                            FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chapter.title,
                          style: AppText.tabular(
                            17,
                            FontWeight.w700,
                            letterSpacing: -0.3,
                          ).copyWith(height: 1.25),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta,
                          style: AppText.tabular(
                            13,
                            FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      LucideIcons.chevronDown,
                      size: 22,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded && chapter.lessons.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFEFF2F7)),
            for (final (i, l) in chapter.lessons.indexed) ...[
              if (i > 0)
                const Divider(height: 1, indent: 70, color: Color(0xFFF1F3F8)),
              LessonRow(lesson: l),
            ],
          ],
        ],
      ),
    );
  }
}

/// One lesson in a chapter, as a row: a video lecture or a set of notes.
class LessonRow extends StatelessWidget {
  const LessonRow({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    // Notes are notes by type, whatever their access state.
    final isNotes =
        lesson.kind == LessonKind.notes || lesson.state == LessonState.notes;
    final state = isNotes && lesson.state != LessonState.locked
        ? LessonState.notes
        : lesson.state;
    final VoidCallback? onTap = switch (state) {
      LessonState.current ||
      LessonState.completed => () => context.push(Routes.lesson(lesson.id)),
      LessonState.live => () => context.push(Routes.liveLobby),
      LessonState.notes => () => context.push(
        Routes.pdf(lesson.id, lesson: true),
        extra: lesson.title,
      ),
      LessonState.locked => null,
    };
    final (IconData icon, Color color, String kind) = switch (state) {
      LessonState.notes => (
        LucideIcons.fileText,
        const Color(0xFFD9480F),
        'Notes',
      ),
      LessonState.live => (LucideIcons.radio, AppColors.liveDot, 'Live class'),
      LessonState.locked => (LucideIcons.lock, AppColors.textSubtle, 'Lecture'),
      _ => (LucideIcons.play, AppColors.primary, 'Lecture'),
    };
    final detail = switch (state) {
      LessonState.notes => 'PDF',
      LessonState.live => lesson.scheduleLabel ?? '',
      LessonState.locked => 'Enrol to unlock',
      _ => lesson.durationLabel ?? 'Recorded',
    }.replaceAll('•', '·').replaceAll('Recorded · ', '');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: isNotes ? 18 : 17, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tabular(
                      15,
                      FontWeight.w600,
                      color: state == LessonState.locked
                          ? AppColors.textMuted
                          : AppColors.ink,
                    ).copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: kind,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (detail.isNotEmpty) TextSpan(text: '  ·  $detail'),
                      ],
                    ),
                    style: AppText.tabular(
                      12,
                      FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Color(0xFFB4BCCB),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.courseId, required this.chapters});

  final String courseId;
  final List<Chapter> chapters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live: every PDF attached to the course's lessons. Sample data: the
    // curriculum's notes lessons.
    final remote = ref.watch(courseNotesProvider(courseId)).value;
    final notes = <({String title, String chapter, VoidCallback open})>[
      if (remote != null && remote.isNotEmpty)
        for (final n in remote)
          (
            title: n.title,
            chapter: n.chapter,
            open: () => context.push(Routes.pdf(n.id), extra: n.title),
          )
      else
        for (final c in chapters)
          for (final l in c.lessons)
            if (l.state == LessonState.notes)
              (
                title: l.title,
                chapter: c.title,
                open: () => context.push(
                  Routes.pdf(l.id, lesson: true),
                  extra: l.title,
                ),
              ),
    ];
    if (notes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          EmptyState(
            icon: LucideIcons.fileText,
            title: 'No notes yet',
            body: 'Chapter notes appear here as teachers add them.',
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final note = notes[i];
        return SoftCard(
          radius: 20,
          padding: const EdgeInsets.all(14),
          onTap: note.open,
          child: Row(
            children: [
              const TintIcon(
                icon: LucideIcons.fileText,
                color: AppColors.liveInk,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: AppText.tabular(15, FontWeight.w600),
                    ),
                    Text(note.chapter, style: AppText.meta),
                  ],
                ),
              ),
              Text(
                'Open',
                style: AppText.tabular(
                  14,
                  FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.course});

  final Course? course;

  @override
  Widget build(BuildContext context) {
    final c = course;
    if (c == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
      children: [
        if (c.description.isNotEmpty) ...[
          Text('About this course', style: AppText.sectionTitle),
          const SizedBox(height: 8),
          Text(c.description, style: AppText.body),
          const SizedBox(height: 22),
        ],
        if (c.highlights.isNotEmpty) ...[
          Text('What you get', style: AppText.sectionTitle),
          const SizedBox(height: 10),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (final h in c.highlights)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.checkCircle2,
                          size: 18,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            h,
                            style: AppText.tabular(14, FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
        ],
        Text('Teachers', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        for (final t in c.teachers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                InitialsAvatar(initials: t.initials, size: 40, fontSize: 14),
                const SizedBox(width: 12),
                Text(
                  t.displayName,
                  style: AppText.tabular(15, FontWeight.w600),
                ),
              ],
            ),
          ),
        if (c.validityNote != null) ...[
          const SizedBox(height: 12),
          Text(c.validityNote!, style: AppText.meta),
        ],
      ],
    );
  }
}
