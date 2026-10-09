import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/models/schedule.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final unread = ref.watch(unreadCountProvider);
    // Stands in for the Supabase realtime subscription: an admin-sent
    // notification lands a few seconds after Home opens.
    ref.watch(realtimeNotificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            // Greeting + notification bell + avatar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, ${student.fullName.split(' ').first} 👋',
                        style: AppText.tabular(13.5, FontWeight.w500, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Class ${student.classLevel} • ${student.board}',
                        style: AppText.tabular(16.5, FontWeight.w700, letterSpacing: -0.2),
                      ),
                    ],
                  ),
                ),
                SquareIconButton(
                  icon: LucideIcons.bell,
                  iconSize: 19,
                  background: AppColors.surface,
                  badge: unread > 0,
                  onPressed: () => context.push(Routes.notifications),
                ),
                const SizedBox(width: 10),
                InitialsAvatar(
                  initials: student.initials,
                  size: 40,
                  fontSize: 13,
                  border: AppColors.primaryTintBorder,
                ),
              ],
            ),
            const SizedBox(height: 26),

            const _LiveHeroCard(),
            const SizedBox(height: 26),

            SectionHeader(title: 'Continue learning'),
            const SizedBox(height: 12),
            const _ContinueLearningCard(),
            const SizedBox(height: 26),

            SectionHeader(
              title: "Today's schedule",
              trailing: TextActionButton(
                label: 'View Calendar →',
                onPressed: () => context.push(Routes.calendar),
              ),
            ),
            const SizedBox(height: 14),
            const _ScheduleTimeline(),
            const SizedBox(height: 26),

            SectionHeader(
              title: 'My courses',
              trailing: TextActionButton(
                label: 'See all',
                onPressed: () => context.go(Routes.courses),
              ),
            ),
            const SizedBox(height: 12),
            for (final course in ref.watch(coursesProvider)) ...[
              _CourseProgressCard(course: course),
              if (course != ref.watch(coursesProvider).last) const SizedBox(height: 12),
            ],
            const SizedBox(height: 26),

            const _UpcomingTestBanner(),
          ],
        ),
      ),
    );
  }
}

/// Dark indigo "LIVE NOW" hero at the top of Home.
class _LiveHeroCard extends StatelessWidget {
  const _LiveHeroCard();

  @override
  Widget build(BuildContext context) {
    const session = MockData.liveNow;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: AppRadius.xl,
        boxShadow: AppShadow.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LivePill(
                label: 'LIVE NOW',
                background: Color(0x29D93A3A),
                textColor: Color(0xFFFF7A7A),
                dotColor: Color(0xFFFF5A5A),
              ),
              Text(
                session.scheduleLabel,
                style: AppText.tabular(
                  12,
                  FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            session.subject,
            style: AppText.tabular(
              12.5,
              FontWeight.w600,
              color: const Color(0xFF9BA2E8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(session.title, style: AppText.h3.copyWith(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 18),
          Row(
            children: [
              InitialsAvatar(
                initials: session.teacherInitials,
                size: 32,
                fontSize: 11,
                background: const Color(0xFF33376E),
                foreground: const Color(0xFFC7CBF5),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  session.teacherName,
                  style: AppText.tabular(
                    13,
                    FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
              _JoinLiveButton(onTap: () => context.push(Routes.liveLobby)),
            ],
          ),
        ],
      ),
    );
  }
}

class _JoinLiveButton extends StatelessWidget {
  const _JoinLiveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Join Live Class',
                style: AppText.tabular(14.5, FontWeight.w700, color: AppColors.primaryDeep),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.primaryDeep),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context) {
    const lesson = MockData.continueLesson;
    final palette = SubjectPalette.fromName(lesson.subject);

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(Routes.lesson('ch1-l3')),
      // The 96pt thumbnail sets the row height; the text column stretches to match.
      child: SizedBox(
        height: 96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(color: palette.tint, borderRadius: AppRadius.sm),
                    alignment: Alignment.center,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0x1F14161C), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.play_arrow_rounded, size: 22, color: palette.ink),
                    ),
                  ),
                  Positioned(
                    right: 7,
                    bottom: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Text(
                        lesson.durationLabel,
                        style: AppText.tabular(9.5, FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.subject.toUpperCase(),
                        style: AppText.eyebrow(color: palette.ink, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 5),
                      Text(lesson.title, style: AppText.tabular(14.5, FontWeight.w700)),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(lesson.progress * 100).round()}% complete',
                            style: AppText.tabular(
                              11.5,
                              FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Continue →',
                            style: AppText.tabular(12, FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ProgressBar(value: lesson.progress, color: palette.ink),
                    ],
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

class _ScheduleTimeline extends StatelessWidget {
  const _ScheduleTimeline();

  @override
  Widget build(BuildContext context) {
    final items = MockData.todaySchedule;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _ScheduleRow(item: items[i], isLast: i == items.length - 1),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item, required this.isLast});

  final ScheduleItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(item.subject);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              children: [
                Text(
                  item.timeLabel,
                  style: AppText.tabular(
                    12.5,
                    FontWeight.w700,
                    color: item.isNow ? AppColors.ink : AppColors.textMuted,
                  ).copyWith(height: 1.2),
                ),
                if (!isLast)
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: VerticalDivider(width: 1.5, thickness: 1.5, color: Color(0xFFE4E7EE)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScheduleIcon(item: item, palette: palette),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(item.title, style: AppText.cardTitleSm)),
                            if (item.kind == SessionKind.live) ...[
                              const SizedBox(width: 8),
                              const StatusBadge.live(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item.subtitle, style: AppText.meta),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleIcon extends StatelessWidget {
  const _ScheduleIcon({required this.item, required this.palette});

  final ScheduleItem item;
  final SubjectPalette palette;

  @override
  Widget build(BuildContext context) {
    // Hindi lessons use the Devanagari glyph tile from the design.
    if (item.subject == 'Hindi') {
      return IconTile(
        background: AppColors.hindiTint,
        label: 'हि',
        labelStyle: AppText.devanagari(13, FontWeight.w700, color: const Color(0xFFC4711F)),
      );
    }
    return IconTile(
      background: palette.tint,
      icon: switch (item.subject) {
        'Mathematics' => LucideIcons.alignLeft,
        'Science' => LucideIcons.flaskConical,
        _ => LucideIcons.bookOpen,
      },
      iconColor: palette.ink,
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(Routes.courseDetails(course.id)),
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
                    Text(course.title, style: AppText.cardTitle),
                    const SizedBox(height: 4),
                    Text(course.nextUpLabel ?? course.chaptersLabel, style: AppText.meta),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${course.progressPercent}%',
                style: AppText.tabular(17, FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ProgressBar(value: course.progress),
          if (course.id == 'class-10-complete-batch') ...[
            const SizedBox(height: 13),
            TextActionButton(
              label: 'Continue Learning →',
              onPressed: () => context.push(Routes.courseDetails(course.id)),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingTestBanner extends StatelessWidget {
  const _UpcomingTestBanner();

  @override
  Widget build(BuildContext context) {
    const test = MockData.upcomingTest;
    return AppCard(
      color: AppColors.warningTint,
      borderColor: AppColors.warningBorder,
      shadow: null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconTile(
            background: Color(0xFFF6EBD8),
            icon: LucideIcons.fileText,
            iconColor: AppColors.warningInk,
            size: 36,
            radius: 11,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.title, style: AppText.cardTitleSm),
                const SizedBox(height: 4),
                Text(
                  test.detail,
                  style: AppText.tabular(12.5, FontWeight.w400, color: AppColors.warningText),
                ),
                const SizedBox(height: 10),
                TextActionButton(
                  label: 'View Details →',
                  color: AppColors.warningInk,
                  onPressed: () =>
                      showDemoSnack(context, 'Test details open once the test is live'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
