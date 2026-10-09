import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/schedule.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

/// Live classes get their own destination: what is on now, what is coming, and
/// what can be watched back. The month view lives on the Calendar screen.
class LiveSessionsScreen extends ConsumerWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedLiveSessionsProvider);
    final liveNow = grouped[LiveStatus.liveNow] ?? const [];
    final upcoming = grouped[LiveStatus.upcoming] ?? const [];
    final past = grouped[LiveStatus.ended] ?? const [];

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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Live Classes', style: AppText.h3),
                  SecondaryButton(
                    label: 'Calendar',
                    icon: LucideIcons.calendar,
                    height: 40,
                    onPressed: () => context.push(Routes.calendar),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  if (liveNow.isNotEmpty) ...[
                    const GroupLabel('HAPPENING NOW'),
                    const SizedBox(height: 10),
                    for (final session in liveNow) ...[
                      _LiveNowCard(session: session),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    const GroupLabel('UPCOMING'),
                    const SizedBox(height: 10),
                    for (final session in upcoming) ...[
                      _SessionRow(session: session),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 10),
                  ],
                  if (past.isNotEmpty) ...[
                    const GroupLabel('PAST RECORDINGS'),
                    const SizedBox(height: 10),
                    for (final session in past) ...[
                      _SessionRow(session: session),
                      const SizedBox(height: 10),
                    ],
                  ],
                  if (liveNow.isEmpty && upcoming.isEmpty && past.isEmpty)
                    const EmptyState(
                      icon: LucideIcons.radio,
                      title: 'No live classes yet',
                      body: 'Your schedule will appear here once your batch starts.',
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

/// The dark hero treatment, reused from Home for the session that is on air.
class _LiveNowCard extends StatelessWidget {
  const _LiveNowCard({required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 16),
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
          Text(session.title, style: AppText.h3.copyWith(fontSize: 22, color: Colors.white)),
          if (session.chapterLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              session.chapterLabel!,
              style: AppText.tabular(
                12,
                FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
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
                  '${session.teacherName} • ${session.studentsEnrolled} watching',
                  style: AppText.tabular(
                    12.5,
                    FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: AppRadius.sm,
            child: InkWell(
              onTap: () => context.push(Routes.liveRoom),
              borderRadius: AppRadius.sm,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Join Live Class',
                      style: AppText.tabular(15, FontWeight.w700, color: AppColors.primaryDeep),
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.primaryDeep),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(session.subject);
    final ended = session.status == LiveStatus.ended;

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => ended ? context.push(Routes.lesson(session.id)) : context.push(Routes.liveLobby),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: palette.tint, borderRadius: AppRadius.xs),
            child: Icon(
              ended ? Icons.play_arrow_rounded : LucideIcons.radio,
              size: ended ? 22 : 18,
              color: palette.ink,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.subject.toUpperCase(),
                  style: AppText.eyebrow(color: palette.ink, letterSpacing: 0.6),
                ),
                const SizedBox(height: 5),
                Text(session.title, style: AppText.cardTitleSm),
                const SizedBox(height: 4),
                Text(
                  ended
                      ? '${session.scheduleLabel} • ${session.durationLabel}'
                      : '${session.scheduleLabel} • ${session.teacherName}',
                  style: AppText.metaSm,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (ended)
            Text('Watch', style: AppText.tabular(12, FontWeight.w700, color: AppColors.primary))
          else
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtle),
        ],
      ),
    );
  }
}
