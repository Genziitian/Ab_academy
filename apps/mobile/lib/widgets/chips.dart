import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Pill filter chip — "All / In Progress / Completed", subject and calendar filters.
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({super.key, required this.label, required this.selected, this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.pill,
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderStrong),
        ),
        child: Text(
          label,
          style: AppText.labelStrong.copyWith(color: selected ? Colors.white : AppColors.textMuted),
        ),
      ),
    );
  }
}

/// Subject label in its own colour, e.g. "Mathematics", "Science".
class SubjectTag extends StatelessWidget {
  const SubjectTag({super.key, required this.subject});

  final String subject;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(subject);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(color: palette.tint, borderRadius: AppRadius.tag),
      child: Text(subject, style: AppText.labelStrong.copyWith(color: palette.ink)),
    );
  }
}

/// Small uppercase status pill — LIVE, COMPLETED, LOCKED, 85%.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.fontSize = 9,
    this.letterSpacing = 0.8,
  });

  const StatusBadge.live({super.key})
    : label = 'LIVE',
      color = AppColors.liveInk,
      background = AppColors.liveTint,
      fontSize = 9,
      letterSpacing = 0.8;

  final String label;
  final Color color;
  final Color background;
  final double fontSize;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Text(
        label,
        style: AppText.badge(color: color, size: fontSize).copyWith(letterSpacing: letterSpacing),
      ),
    );
  }
}

/// Pulsing red dot used by every LIVE affordance in the design.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.size = 7, this.color = AppColors.live});

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
        // Matches the `livePulse` keyframes: a ring expanding to 7px then fading.
        final t = Curves.easeOut.transform((_controller.value / 0.7).clamp(0.0, 1.0));
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.55 * (1 - t)),
                spreadRadius: 7 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// "LIVE NOW" / "LIVE CLASS" capsule with the pulsing dot.
class LivePill extends StatelessWidget {
  const LivePill({
    super.key,
    this.label = 'LIVE CLASS',
    this.background = AppColors.liveTint,
    this.textColor = AppColors.liveInk,
    this.dotColor = AppColors.live,
  });

  final String label;
  final Color background;
  final Color textColor;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveDot(color: dotColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppText.badge(color: textColor, size: 10.5).copyWith(letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}
