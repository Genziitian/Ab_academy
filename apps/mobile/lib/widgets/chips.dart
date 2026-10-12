import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

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
          borderRadius: AppRadius.xs,
          border: Border.all(
            color: selected ? AppColors.primaryDeep : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppText.tabular(
            13,
            selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textBody,
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
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: AppRadius.xs,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppText.tabular(
            13,
            selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textBody,
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
        subject,
        style: AppText.tabular(12, FontWeight.w600, color: palette.ink),
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

  const StatusBadge.live({super.key})
    : label = 'LIVE',
      color = AppColors.liveInk,
      background = AppColors.liveTint,
      fontSize = 9,
      letterSpacing = 0.4;

  const StatusBadge.teacher({super.key})
    : label = 'TEACHER',
      color = Colors.white,
      background = AppColors.primary,
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
  const LivePill({super.key, this.label = 'LIVE NOW', this.onDark = true});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.live.withValues(alpha: 0.18)
            : AppColors.liveTint,
        borderRadius: AppRadius.badge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveDot(color: onDark ? AppColors.live : AppColors.liveInk),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.badge(
              color: onDark ? AppColors.liveOnDark : AppColors.liveInk,
              size: 11,
            ).copyWith(letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}
