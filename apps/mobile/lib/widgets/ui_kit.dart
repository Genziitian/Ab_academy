import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Building blocks of the app layout: gradient header cards, coloured
/// icon tiles, large page titles and grouped menu lists.
abstract final class AppGradients {
  /// Coal into warm brown — headers, the centre tab button, avatars.
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1814), Color(0xFF3A342D)],
  );

  static LinearGradient pair(Color a, Color b) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [a, b],
  );

  static final violet = pair(const Color(0xFF8E4FA3), const Color(0xFF7A3E8E));
  static final orange = pair(const Color(0xFFE8742A), const Color(0xFFB4521A));
  static final green = pair(const Color(0xFF1C9C88), const Color(0xFF0F7A6E));
  static final sky = pair(const Color(0xFF3E8FB0), const Color(0xFF2B6F8C));
  static final blue = pair(const Color(0xFF6B5D50), const Color(0xFF3A342D));
  static final pink = pair(const Color(0xFFD0533B), const Color(0xFFB23A26));
}

/// Big page title with an optional one-line subtitle, as on Academics.
class PageTitle extends StatelessWidget {
  const PageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.h1.copyWith(letterSpacing: -0.6)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppText.bodyLg),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Rounded square back button used on full-page screens.
class BackSquareButton extends StatelessWidget {
  const BackSquareButton({super.key, this.onTap, this.onDark = false});

  final VoidCallback? onTap;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onDark
          ? Colors.white.withValues(alpha: 0.18)
          : AppColors.fillMuted,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md,
        side: onDark
            ? BorderSide(color: Colors.white.withValues(alpha: 0.25))
            : const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        customBorder: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        onTap: onTap ?? () => context.pop(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            LucideIcons.chevronLeft,
            size: 22,
            color: onDark ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Coloured gradient square holding a white icon.
class GradientIcon extends StatelessWidget {
  const GradientIcon({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 56,
    this.iconSize = 26,
    this.round = false,
  });

  final IconData icon;
  final Gradient gradient;
  final double size;
  final double iconSize;
  final bool round;

  @override
  Widget build(BuildContext context) {
    final colors = gradient is LinearGradient
        ? (gradient as LinearGradient).colors
        : const [AppColors.primary];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(size * 0.3),
        // A faint, tight shadow: depth without a coloured glow.
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }
}

/// Soft tinted square with a coloured icon — menu rows and list items.
class TintIcon extends StatelessWidget {
  const TintIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.48, color: color),
    );
  }
}

/// White rounded card with a soft shadow — the base surface of the layout.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: AppColors.border),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1C1814),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Section label above a grouped list, e.g. GENERAL.
class GroupHeading extends StatelessWidget {
  const GroupHeading(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Text(
        label.toUpperCase(),
        style: AppText.tabular(
          14,
          FontWeight.w600,
          color: AppColors.textMuted,
        ).copyWith(letterSpacing: 1.1),
      ),
    );
  }
}

/// One row of a grouped menu: tinted icon, label, chevron.
class MenuRow {
  const MenuRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final String? value;
}

class MenuList extends StatelessWidget {
  const MenuList({super.key, required this.rows});

  final List<MenuRow> rows;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
            InkWell(
              onTap: row.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    TintIcon(icon: row.icon, color: row.color),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        row.label,
                        style: AppText.tabular(16, FontWeight.w500),
                      ),
                    ),
                    if (row.value != null) ...[
                      Text(row.value!, style: AppText.meta),
                      const SizedBox(width: 6),
                    ],
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: AppColors.textSubtle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Circle with initials on the brand gradient.
class GradientAvatar extends StatelessWidget {
  const GradientAvatar({
    super.key,
    required this.initials,
    this.size = 56,
    this.ring = false,
  });

  final String initials;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8742A), Color(0xFFB4521A)],
        ),
        shape: BoxShape.circle,
        border: ring
            ? Border.all(color: Colors.white, width: 3)
            : Border.all(color: const Color(0xFFEFC9AD), width: 2),
      ),
      child: Text(
        initials.isEmpty ? '?' : initials.characters.first.toUpperCase(),
        style: AppText.tabular(
          size * 0.42,
          FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// "View All →" link in section headers.
class ViewAllLink extends StatelessWidget {
  const ViewAllLink({super.key, required this.onTap, this.label = 'View All'});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xs,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppText.tabular(
                16,
                FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              LucideIcons.arrowRight,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title with an optional trailing action.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppText.h3.copyWith(letterSpacing: -0.4)),
        ),
        ?trailing,
      ],
    );
  }
}
