import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

/// Filter chip — subject filters on Notes, class / stream on Explore. The
/// selected chip is filled navy, the rest are white with a hairline border.
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDeep : AppColors.surface,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: selected ? AppColors.primaryDeep : AppColors.rule,
          ),
        ),
        child: Text(
          label,
          style: AppText.tabular(
            13,
            FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Outlined selectable chip — ticket categories. Selected is blue-tinted.
class ChoiceChipPill extends StatelessWidget {
  const ChoiceChipPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppText.tabular(
            13,
            FontWeight.w500,
            color: selected ? AppColors.ink : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Subject label in its own colour, e.g. "Physics", "Chemistry".
class SubjectTag extends StatelessWidget {
  const SubjectTag({super.key, required this.subject});

  final String subject;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(subject);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: palette.tint,
        borderRadius: AppRadius.badge,
      ),
      child: Text(
        tx.subject(subject),
        style: AppText.tabular(12, FontWeight.w500, color: palette.ink),
      ),
    );
  }
}

/// Small uppercase status badge — LIVE, RESOLVED, IN PROGRESS, TEACHER.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.fontSize = 10,
    this.letterSpacing = 0.4,
  });

  StatusBadge.live({super.key})
    : label = tx.liveCaps,
      color = AppColors.live,
      background = AppColors.successTint,
      fontSize = 9,
      letterSpacing = 0.4;

  StatusBadge.teacher({super.key})
    : label = tx.teacherCaps,
      color = Colors.white,
      background = AppColors.ink,
      fontSize = 8,
      letterSpacing = 0.4;

  final String label;
  final Color color;
  final Color background;
  final double fontSize;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.badge,
      ),
      child: Text(
        label,
        style: AppText.badge(
          color: color,
          size: fontSize,
        ).copyWith(letterSpacing: letterSpacing),
      ),
    );
  }
}

/// Pulsing dot used by every LIVE affordance.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.size = 6, this.color = AppColors.live});

  final double size;
  final Color color;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // A ring expanding to 6px then fading.
        final t = Curves.easeOut.transform(
          (_controller.value / 0.7).clamp(0.0, 1.0),
        );
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5 * (1 - t)),
                spreadRadius: 6 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// "LIVE NOW" tag with the pulsing dot. [onDark] for the navy hero cards.
class LivePill extends StatelessWidget {
  const LivePill({super.key, this.label, this.onDark = true});

  final String? label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.live.withValues(alpha: 0.18)
            : AppColors.successTint,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveDot(color: onDark ? AppColors.liveOnDark : AppColors.live),
          const SizedBox(width: 6),
          Text(
            label ?? tx.liveNowCaps,
            style: AppText.badge(
              color: onDark ? AppColors.liveOnDark : AppColors.live,
              size: 11,
            ).copyWith(letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}
