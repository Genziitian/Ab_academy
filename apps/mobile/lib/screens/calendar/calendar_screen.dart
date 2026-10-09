import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/schedule.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

/// The design's month: September 2026, which starts on a Tuesday.
const _monthLabel = 'September 2026';
const _monthLength = 30;
const _firstWeekdayOffset = 1; // Monday-first grid, month starts Tuesday.

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(calendarDayProvider);
    final filter = ref.watch(calendarFilterProvider);
    final agenda = _agendaFor(filter);

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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Calendar', style: AppText.h3),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => showDemoSnack(context, 'August 2026'),
                            child: const Icon(
                              LucideIcons.chevronLeft,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(_monthLabel, style: AppText.tabular(14, FontWeight.w700)),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => showDemoSnack(context, 'October 2026'),
                            child: const Icon(
                              LucideIcons.chevronRight,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _WeekdayHeader(),
                  const SizedBox(height: 6),
                  _MonthGrid(
                    selectedDay: selectedDay,
                    onSelect: (day) => ref.read(calendarDayProvider.notifier).select(day),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: ChipRow(
                children: [
                  for (final label in ['All', 'Live Classes', 'Tests', 'Important'])
                    FilterChipPill(
                      label: label,
                      selected: filter == label,
                      onTap: () => ref.read(calendarFilterProvider.notifier).select(label),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  Text('$selectedDay September', style: AppText.sectionTitle),
                  const SizedBox(height: 16),
                  if (agenda.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        'Nothing scheduled for this filter.',
                        style: AppText.metaSm.copyWith(fontSize: 13),
                      ),
                    )
                  else
                    for (var i = 0; i < agenda.length; i++)
                      _AgendaRow(item: agenda[i], isLast: i == agenda.length - 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ScheduleItem> _agendaFor(String filter) => switch (filter) {
    'Live Classes' => MockData.calendarAgenda.where((i) => i.kind == SessionKind.live).toList(),
    'Tests' => MockData.calendarAgenda.where((i) => i.kind == SessionKind.test).toList(),
    'Important' =>
      MockData.calendarAgenda.where((i) => i.isNow || i.kind == SessionKind.test).toList(),
    _ => MockData.calendarAgenda,
  };
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final letter in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
          Expanded(
            child: Text(
              letter,
              textAlign: TextAlign.center,
              style: AppText.tabular(10.5, FontWeight.w600, color: AppColors.textFaint),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.selectedDay, required this.onSelect});

  final int selectedDay;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        mainAxisExtent: 40,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        final day = index - _firstWeekdayOffset + 1;
        if (day < 1 || day > _monthLength) return const SizedBox.shrink();

        final selected = day == selectedDay;
        final mark = MockData.calendarMarks[day];

        return GestureDetector(
          onTap: () => onSelect(day),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: AppRadius.xs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: AppText.tabular(
                    13,
                    selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mark == null
                        ? Colors.transparent
                        : (selected ? Colors.white : _markColor(mark)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _markColor(SessionKind kind) => switch (kind) {
    SessionKind.live => AppColors.live,
    SessionKind.recorded => AppColors.science,
    SessionKind.test => AppColors.warning,
  };
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.item, required this.isLast});

  final ScheduleItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final accent = switch (item.kind) {
      SessionKind.live => item.isNow ? AppColors.live : AppColors.science,
      SessionKind.recorded => AppColors.science,
      SessionKind.test => AppColors.warning,
    };
    final rail = switch (item.kind) {
      SessionKind.live => item.isNow ? const Color(0xFFFDE0E0) : const Color(0xFFE4F0EA),
      SessionKind.recorded => const Color(0xFFE4F0EA),
      SessionKind.test => const Color(0xFFF3E7D2),
    };
    final isTest = item.kind == SessionKind.test;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 62,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                item.timeLabel,
                style: AppText.tabular(
                  12.5,
                  FontWeight.w700,
                  color: item.isNow ? AppColors.ink : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 14, bottom: isLast ? 4 : 18),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: rail, width: 2)),
              ),
              child: AppCard(
                borderRadius: AppRadius.md,
                padding: const EdgeInsets.all(14),
                color: isTest ? AppColors.warningTint : AppColors.surface,
                borderColor: isTest ? AppColors.warningBorder : AppColors.border,
                shadow: isTest ? null : AppShadow.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          isTest ? 'TEST DEADLINE' : 'LIVE CLASS',
                          style: AppText.badge(
                            color: isTest ? AppColors.warningInk : accent,
                            size: 9.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(item.title, style: AppText.rowTitle.copyWith(height: 1.3)),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: AppText.meta.copyWith(
                        color: isTest ? AppColors.warningText : AppColors.textSubtle,
                      ),
                    ),
                    if (item.joinable) ...[
                      const SizedBox(height: 9),
                      TextActionButton(
                        label: 'Join →',
                        onPressed: () => context.push(Routes.liveLobby),
                      ),
                    ],
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
