import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
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
import '../../widgets/course_slider.dart';

/// 06 · Home — live hero, continue learning and today's schedule.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final unread = ref.watch(unreadCountProvider);
    // Stands in for the Supabase realtime subscription: an admin-sent
    // notification lands a few seconds after Home opens.
    ref.watch(realtimeNotificationProvider);

    final summary = [
      'Class ${student.classLevel}',
      if (student.stream != null) student.stream!,
      student.board,
    ].join(' · ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()}, ${student.fullName.split(' ').first}',
                        style: AppText.label,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.tabular(15, FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SquareIconButton(
                  icon: LucideIcons.bell,
                  badge: unread > 0,
                  onPressed: () => context.push(Routes.notifications),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.go(Routes.profile),
                  child: InitialsAvatar(
                    initials: student.initials,
                    size: 40,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Admin-managed course slider (App slider in the console).
            const CourseSlider(padding: EdgeInsets.only(bottom: 20)),
            const _LiveHeroCard(),
            const SizedBox(height: 20),
            Text('Continue learning', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            const _ContinueLearningCard(),
            const SizedBox(height: 20),
            SectionHeader(
              title: "Today's schedule",
              trailing: TextActionButton(
                label: 'Calendar →',
                onPressed: () => context.push(Routes.calendar),
              ),
            ),
            const SizedBox(height: 10),
            const _ScheduleCard(items: MockData.todaySchedule),
            const SizedBox(height: 20),
            const _UpcomingTestBanner(),
          ],
        ),
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

/// Navy "LIVE NOW" hero at the top of Home.
class _LiveHeroCard extends StatelessWidget {
  const _LiveHeroCard();

  @override
  Widget build(BuildContext context) {
    const session = MockData.liveNow;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LivePill(),
              Text(
                session.scheduleLabel.replaceAll('•', '·'),
                style: AppText.tabular(
                  12,
                  FontWeight.w400,
                  color: AppColors.textOnDarkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            session.subject.toUpperCase(),
            style: AppText.tabular(
              12,
              FontWeight.w600,
              color: AppColors.textOnDarkAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(session.title, style: AppText.h4.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              InitialsAvatar(
                initials: session.teacherInitials,
                size: 30,
                fontSize: 11,
                background: AppColors.primaryDeepRaised,
                foreground: const Color(0xFFC7D4FF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  session.teacherName,
                  style: AppText.tabular(
                    13,
                    FontWeight.w400,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                borderRadius: AppRadius.xs,
                child: InkWell(
                  onTap: () => context.push(Routes.liveRoom),
                  borderRadius: AppRadius.xs,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'Join Live →',
                      style: AppText.tabular(14, FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(Routes.lesson('ch1-l3')),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 84,
            decoration: BoxDecoration(
              color: palette.tint,
              borderRadius: AppRadius.xs,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 18,
                    color: palette.ink,
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDeep.withValues(alpha: 0.75),
                      borderRadius: AppRadius.badge,
                    ),
                    child: Text(
                      lesson.durationLabel,
                      style: AppText.tabular(
                        10,
                        FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.subject.toUpperCase(),
                        style: AppText.eyebrow(color: palette.ink),
                      ),
                      const SizedBox(height: 3),
                      Text(lesson.title, style: AppText.cardTitleSm),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(lesson.progress * 100).round()}% complete',
                            style: AppText.meta,
                          ),
                          Text(
                            'Continue →',
                            style: AppText.tabular(
                              12,
                              FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ProgressBar(
                        value: lesson.progress,
                        height: 5,
                        color: AppColors.teal,
                      ),
                    ],
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

/// Compact list of today's sessions, inside one card.
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.items});

  final List<ScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: items[i].joinable
                  ? () => context.push(Routes.liveRoom)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: i < items.length - 1
                      ? const Border(
                          bottom: BorderSide(color: AppColors.divider),
                        )
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        items[i].timeLabel,
                        style: AppText.tabular(
                          12,
                          FontWeight.w600,
                          color: items[i].isNow
                              ? AppColors.ink
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  items[i].title,
                                  style: AppText.rowTitle,
                                ),
                              ),
                              if (items[i].kind == SessionKind.live) ...[
                                const SizedBox(width: 6),
                                const StatusBadge.live(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            items[i].subtitle.replaceAll('•', '·'),
                            style: AppText.meta,
                          ),
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

class _UpcomingTestBanner extends StatelessWidget {
  const _UpcomingTestBanner();

  @override
  Widget build(BuildContext context) {
    const test = MockData.upcomingTest;
    return GestureDetector(
      onTap: () => context.push(Routes.calendar),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.warningTint,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.warningBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECD6),
                borderRadius: AppRadius.sm,
              ),
              child: const Icon(
                LucideIcons.clipboardList,
                size: 18,
                color: AppColors.warningInk,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(test.title, style: AppText.cardTitleSm),
                  const SizedBox(height: 2),
                  Text(
                    test.detail.replaceAll('•', '·'),
                    style: AppText.tabular(
                      13,
                      FontWeight.w400,
                      color: AppColors.warningText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.warningInk,
            ),
          ],
        ),
      ),
    );
  }
}
