import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Filled indigo CTA. Scales down slightly while pressed, like the design.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 54,
    this.trailingIcon,
    this.enabled = true,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final IconData? trailingIcon;
  final bool enabled;
  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onPressed != null;
    final button = AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.trackMuted,
          borderRadius: AppRadius.button,
          boxShadow: enabled ? AppShadow.primaryButton : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: AppText.buttonLg.copyWith(
                color: enabled ? Colors.white : AppColors.textSubtle,
              ),
            ),
            if (widget.trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                widget.trailingIcon,
                size: 17,
                color: enabled ? Colors.white : AppColors.textSubtle,
              ),
            ],
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: widget.expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// Hairline-outlined button used as the secondary action.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 50,
    this.icon,
    this.foreground = AppColors.ink,
    this.borderColor = AppColors.borderStrong,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final IconData? icon;
  final Color foreground;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.button,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.button,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppText.button.copyWith(fontWeight: FontWeight.w600, color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 40x40 hairline square holding a single icon — back buttons, search, overflow.
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconSize = 18,
    this.color = AppColors.ink,
    this.background,
    this.borderColor = AppColors.border,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color color;
  final Color? background;
  final Color borderColor;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Material(
        color: background ?? Colors.transparent,
        borderRadius: AppRadius.xs,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.xs,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.xs,
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: iconSize, color: color),
                if (badge)
                  Positioned(
                    top: size * 0.2,
                    right: size * 0.22,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.live,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Indigo text link, e.g. "Continue →", "See all", "View Calendar →".
class TextActionButton extends StatelessWidget {
  const TextActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.primary,
    this.fontSize = 12.5,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Text(label, style: AppText.tabular(fontSize, FontWeight.w700, color: color)),
    );
  }
}
