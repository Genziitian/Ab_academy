import 'package:flutter/material.dart';

import '../config/academy.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The 60-day board plan as a register: three 20-day phases (concepts,
/// practice, revision), one cell per day, filled up to today. Real dates
/// only — it never claims to know a student's attendance. Same design as the
/// plan on abacademy.in.
class PlanRegister extends StatelessWidget {
  const PlanRegister({super.key, this.now});

  /// For previews and tests; defaults to the device clock.
  final DateTime? now;

  static const _phases = 3;

  @override
  Widget build(BuildContext context) {
    final today = now ?? DateTime.now();
    final start = Academy.batchStart;
    final total = Academy.planDays;
    final perPhase = total ~/ _phases;

    int daysBetween(DateTime a, DateTime b) =>
        DateTime(b.year, b.month, b.day).difference(DateTime(a.year, a.month, a.day)).inDays;

    final sinceStart = daysBetween(start, today);
    final day = sinceStart < 0 ? 0 : (sinceStart + 1).clamp(1, total + 1);
    final toStart = daysBetween(today, start);
    final toExam = daysBetween(today, Academy.examDate).clamp(0, 9999);

    final (statusLabel, statusFg, statusBg) = day == 0
        ? (tx.planStartsIn(toStart), AppColors.accentInk, AppColors.accentSoft)
        : day > total
        ? (tx.planDone, AppColors.textMuted, AppColors.canvas)
        : (tx.planDayOf(day), AppColors.live, AppColors.successTint);

    String date(DateTime d) => '${d.day} ${tx.monthsShort[d.month - 1]} ${d.year}';

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: AppColors.tray, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 8),
            child: Row(
              children: [
                Expanded(child: Text(tx.planTitle, style: AppText.label)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(statusLabel, style: AppText.tabular(12.5, FontWeight.w500, color: statusFg)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.rule),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: '${tx.planTitle}: $statusLabel',
                  excludeSemantics: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var phase = 0; phase < _phases; phase++) ...[
                        if (phase > 0) const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.count(
                                crossAxisCount: 5,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                padding: EdgeInsets.zero,
                                children: [
                                  for (var i = 0; i < perPhase; i++)
                                    _Cell(state: _cellState(phase * perPhase + i + 1, day)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(tx.planPhases[phase], style: AppText.tabular(13, FontWeight.w500)),
                              const SizedBox(height: 1),
                              Text(tx.planPhaseDays[phase], style: AppText.mono(10.5, color: AppColors.textSubtle)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Fact(label: tx.planClassesStart, value: date(start)),
                    ),
                    Expanded(
                      child: _Fact(
                        label: tx.planBoardExam,
                        value: date(Academy.examDate),
                        note: tx.planDaysLeft(toExam),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static _CellState _cellState(int cellDay, int today) {
    if (cellDay < today) return _CellState.done;
    if (cellDay == today) return _CellState.today;
    return _CellState.ahead;
  }
}

enum _CellState { done, today, ahead }

class _Cell extends StatelessWidget {
  const _Cell({required this.state});

  final _CellState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: switch (state) {
          _CellState.done => AppColors.ink,
          _CellState.today => AppColors.accent,
          _CellState.ahead => AppColors.canvas,
        },
        borderRadius: BorderRadius.circular(3),
        border: state == _CellState.ahead ? Border.all(color: AppColors.rule) : null,
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.meta.copyWith(color: AppColors.textSubtle)),
        const SizedBox(height: 4),
        Text(value, style: AppText.mono(14)),
        if (note != null) ...[
          const SizedBox(height: 2),
          Text(note!, style: AppText.tabular(12.5, FontWeight.w500, color: AppColors.accentInk)),
        ],
      ],
    );
  }
}
