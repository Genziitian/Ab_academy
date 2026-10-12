import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/schedule.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

const _dotColors = {
  SessionKind.live: AppColors.liveDot,
  SessionKind.recorded: AppColors.primary,
  SessionKind.test: AppColors.accent,
};

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Event type on a date, from the mock marks keyed by offset from today.
SessionKind? _markOn(DateTime date) =>
    MockData.calendarMarks[date.difference(_today()).inDays];

/// The agenda for a date: today's full schedule, or one item on marked days.
List<ScheduleItem> _agendaFor(DateTime date) {
  if (date == _today()) return MockData.calendarAgenda;
  final kind = _markOn(date);
  if (kind == null) return const [];
  return [
    ScheduleItem(
      timeLabel: '5:00 PM',
      title: kind == SessionKind.test ? 'Weekly test' : 'Physics',
      subtitle: switch (kind) {
        SessionKind.recorded => 'Recorded · 45 min',
        SessionKind.test => '20 questions · 45 min',
        SessionKind.live => 'Amit Sir',
      },
      kind: kind,
      subject: 'Physics',
    ),
  ];
}

/// 15 · Calendar — month grid with event dots, agenda for the chosen day.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CalendarView(onBack: () => context.pop()),
      ),
    );
  }
}

/// Month grid + agenda. Pushed full-screen from Home, and embedded as the
/// Calendar section of the Academics tab (without a back button).
class CalendarView extends ConsumerWidget {
  const CalendarView({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final selected = ref.watch(calendarDayProvider);
    final agenda = _agendaFor(selected);

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 18),
          child: Column(
            children: [
              Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: AppColors.ink,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      // Lines the month up with the page's 20px gutter
                      // when there is no back button in front of it.
                      padding: EdgeInsets.only(left: onBack == null ? 12 : 0),
                      child: Text(
                        DateFormat('MMMM y').format(month),
                        textAlign: onBack == null
                            ? TextAlign.left
                            : TextAlign.center,
                        style: AppText.tabular(17, FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: () =>
                        ref.read(calendarMonthProvider.notifier).shift(-1),
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () =>
                        ref.read(calendarMonthProvider.notifier).shift(1),
                    icon: const Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _MonthGrid(
                  month: month,
                  selected: selected,
                  onSelect: ref.read(calendarDayProvider.notifier).select,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                DateFormat('EEEE, d MMMM').format(selected),
                style: AppText.tabular(15, FontWeight.w600),
              ),
              const SizedBox(height: 10),
              if (agenda.isEmpty)
                const EmptyState(
                  icon: LucideIcons.calendarX,
                  title: 'No classes scheduled',
                  body: 'Pick a day with a dot to see its classes.',
                ),
              for (final item in agenda) ...[
                _AgendaCard(item: item),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    // Monday-first grid.
    final lead = (month.weekday + 6) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cells = ((lead + daysInMonth) / 7).ceil() * 7;
    final today = _today();

    return Column(
      children: [
        Row(
          children: [
            for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: AppText.tabular(
                      12,
                      FontWeight.w600,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (var row = 0; row < cells ~/ 7; row++)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _DayCell(
                        date: () {
                          final day = row * 7 + col - lead + 1;
                          return day < 1 || day > daysInMonth
                              ? null
                              : DateTime(month.year, month.month, day);
                        }(),
                        selected: selected,
                        today: today,
                        onSelect: onSelect,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  final DateTime? date;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox(height: 38);
    final on = date == selected;
    final kind = _markOn(date!);
    return GestureDetector(
      onTap: () => onSelect(date!),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        decoration: BoxDecoration(
          color: on ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.xs,
          border: !on && date == today
              ? Border.all(color: AppColors.primaryTintBorder)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date!.day}',
              style: AppText.tabular(
                13,
                on ? FontWeight.w700 : FontWeight.w500,
                color: on ? Colors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kind == null
                    ? Colors.transparent
                    : (on ? Colors.white : _dotColors[kind]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final (tagBg, tagFg) = switch (item.kind) {
      SessionKind.live => (AppColors.liveTint, AppColors.liveInk),
      SessionKind.recorded => (AppColors.primaryTint, AppColors.primary),
      SessionKind.test => (AppColors.amberTint, AppColors.warningInk),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.joinable ? AppColors.primarySoft : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: item.joinable ? AppColors.primaryTintBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.timeLabel, style: AppText.tabular(13, FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: AppRadius.badge,
                ),
                child: Text(
                  item.kind.name.toUpperCase(),
                  style: AppText.badge(color: tagFg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.title, style: AppText.cardTitle),
          const SizedBox(height: 1),
          Text(item.subtitle.replaceAll('•', '·'), style: AppText.meta),
          if (item.joinable) ...[
            const SizedBox(height: 10),
            Material(
              color: AppColors.primary,
              borderRadius: AppRadius.xs,
              child: InkWell(
                onTap: () => context.push(Routes.liveRoom),
                borderRadius: AppRadius.xs,
                child: SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Join now',
                      style: AppText.tabular(
                        13,
                        FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
