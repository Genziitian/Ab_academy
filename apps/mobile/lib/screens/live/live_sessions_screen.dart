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

/// 12 · Live sessions — the class on air now, then upcoming and past.
class LiveSessionsScreen extends ConsumerStatefulWidget {
  const LiveSessionsScreen({super.key});

  @override
  ConsumerState<LiveSessionsScreen> createState() => _LiveSessionsScreenState();
}

class _LiveSessionsScreenState extends ConsumerState<LiveSessionsScreen> {
  String _tab = 'Upcoming';
  final _reminders = <String>{'live-genetics'};

  @override
  Widget build(BuildContext context) {
    final grouped = ref.watch(groupedLiveSessionsProvider);
    final liveNow = grouped[LiveStatus.liveNow] ?? const [];
    final list = _tab == 'Upcoming'
        ? grouped[LiveStatus.upcoming] ?? const <LiveSession>[]
        : grouped[LiveStatus.ended] ?? const <LiveSession>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Row(
              children: [
                Expanded(child: Text('Live classes', style: AppText.h2)),
                SquareIconButton(
                  icon: LucideIcons.calendar,
                  onPressed: () => context.push(Routes.calendar),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final session in liveNow) ...[
              _LiveNowCard(session: session),
              const SizedBox(height: 16),
            ],
            SegmentedTabs(
              tabs: const ['Upcoming', 'Past'],
              selected: _tab,
              onSelected: (tab) => setState(() => _tab = tab),
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              EmptyState(
                icon: LucideIcons.radio,
                title: _tab == 'Upcoming'
                    ? 'No classes scheduled'
                    : 'No recordings yet',
                body: _tab == 'Upcoming'
                    ? 'New live classes appear here as teachers schedule them.'
                    : 'Finished classes show up here with their recording.',
              )
            else
              ListCard(
                children: [
                  for (final session in list)
                    _SessionRow(
                      session: session,
                      reminded: _reminders.contains(session.id),
                      onRemind: () => setState(() {
                        if (!_reminders.remove(session.id)) {
                          _reminders.add(session.id);
                        }
                      }),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveNowCard extends StatelessWidget {
  const _LiveNowCard({required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LivePill(),
          const SizedBox(height: 12),
          Text(
            '${session.subject} · ${session.title}',
            style: AppText.tabular(19, FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.teacherName} · ${session.studentsEnrolled} students',
            style: AppText.tabular(
              13,
              FontWeight.w400,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.white,
            borderRadius: AppRadius.xs,
            child: InkWell(
              onTap: () => context.push(Routes.liveRoom),
              borderRadius: AppRadius.xs,
              child: SizedBox(
                height: 42,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Join Live Class →',
                    style: AppText.tabular(14, FontWeight.w600),
                  ),
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
  const _SessionRow({
    required this.session,
    required this.reminded,
    required this.onRemind,
  });

  final LiveSession session;
  final bool reminded;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(session.subject);
    final past = session.status == LiveStatus.ended;
    return InkWell(
      onTap: () => past
          ? context.push(Routes.lesson('ch1-l3'))
          : context.push(Routes.liveLobby),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.tint,
                borderRadius: AppRadius.xs,
              ),
              child: Text(
                session.teacherInitials,
                style: AppText.tabular(12, FontWeight.w600, color: palette.ink),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.subject} · ${session.title}',
                    style: AppText.rowTitle,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    [
                      session.scheduleLabel.replaceAll('•', '·'),
                      if (past && session.durationLabel != null)
                        session.durationLabel!
                      else
                        session.teacherName,
                    ].join(' · '),
                    style: AppText.meta,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (past)
              Text(
                'Watch',
                style: AppText.tabular(
                  12,
                  FontWeight.w600,
                  color: AppColors.primary,
                ),
              )
            else
              GestureDetector(
                onTap: onRemind,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    reminded ? '✓ Set' : 'Remind',
                    style: AppText.tabular(
                      12,
                      FontWeight.w600,
                      color: reminded ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
