import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

/// Building blocks of the app layout: icon tiles, large page titles and
/// grouped menu lists. Flat, as on the website: these "gradients" are kept
/// for existing callers but every tile now draws quietly in ink on grey.
abstract final class AppGradients {
  /// Ink — headers, avatars.
  static const brand = LinearGradient(
    colors: [Color(0xFF171511), Color(0xFF171511)],
  );

  static LinearGradient pair(Color a, Color b) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [a, b],
  );

  static final violet = pair(AppColors.maths, AppColors.maths);
  static final orange = pair(AppColors.accent, AppColors.accent);
  static final green = pair(AppColors.teal, AppColors.teal);
  static final sky = pair(AppColors.commerce, AppColors.commerce);
  static final blue = pair(AppColors.ink, AppColors.ink);
  static final pink = pair(AppColors.english, AppColors.english);
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
              Text(title, style: AppText.h1),
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

/// Grey square holding an ink icon. (Took a gradient before the redesign;
/// [gradient] now only tints the icon.)
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.tray,
        shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, size: iconSize * 0.9, color: AppColors.ink),
    );
  }
}

/// Quiet square with an ink icon — menu rows and list items. [color] is kept
/// for existing callers; tiles are neutral so the screen stays calm.
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
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.rule),
      ),
      child: Icon(icon, size: size * 0.44, color: AppColors.ink),
    );
  }
}

/// White card with a hairline border — the base surface of the layout.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = 16,
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
    return Material(
      color: AppColors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
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
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        tx.hindi ? label : label.toUpperCase(),
        style: AppText.eyebrow(size: 11.5),
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
                    TintIcon(icon: row.icon, color: row.color, size: 38),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        row.label,
                        style: AppText.tabular(15, FontWeight.w500),
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

/// Ink circle with the first initial.
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
        color: AppColors.ink,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: Text(
        initials.isEmpty ? '?' : initials.characters.first.toUpperCase(),
        style: AppText.tabular(
          size * 0.4,
          FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// "View All →" link in section headers.
class ViewAllLink extends StatelessWidget {
  const ViewAllLink({super.key, required this.onTap, this.label});

  final VoidCallback onTap;
  final String? label;

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
              label ?? tx.viewAll,
              style: AppText.tabular(14, FontWeight.w500, color: AppColors.ink),
            ),
            const SizedBox(width: 4),
            const Icon(
              LucideIcons.arrowRight,
              size: 15,
              color: AppColors.ink,
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
          child: Text(title, style: AppText.serif(24)),
        ),
        ?trailing,
      ],
    );
  }
}
