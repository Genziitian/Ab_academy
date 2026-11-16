import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../l10n/strings.dart';

/// Order matches the shell branches in the router.
enum AppTab { home, academics, courses, more }

List<(AppTab, IconData, String)> get _items => [
  (AppTab.home, LucideIcons.home, tx.tabHome),
  (AppTab.academics, LucideIcons.graduationCap, tx.tabAcademics),
  (AppTab.courses, LucideIcons.bookOpen, tx.tabCourses),
  (AppTab.more, LucideIcons.layoutGrid, tx.tabMore),
];

/// Bottom bar: four equal tabs. The selected one is ink, with a grey pill
/// behind its icon and a saffron dot; every tab has the same tap target and ripple, and the
/// bar scales with the screen width.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.active,
    required this.onSelected,
  });

  final AppTab active;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    // Small phones get a slightly tighter bar; tablets a roomier one.
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 360;
    final wide = width >= 600;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.rule)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          wide ? 48 : 8,
          6,
          wide ? 48 : 8,
          bottom > 0 ? bottom : 8,
        ),
        child: Row(
          children: [
            for (final (tab, icon, label) in _items)
              Expanded(
                child: _NavItem(
                  icon: icon,
                  label: label,
                  selected: tab == active,
                  compact: compact,
                  onTap: () {
                    if (tab != active) HapticFeedback.selectionClick();
                    onSelected(tab);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.textSubtle;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: compact ? 52 : 60,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? AppColors.tray : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  scale: 1,
                  child: Icon(icon, size: 22, color: color),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: AppText.tabular(
                  compact ? 11 : 12,
                  selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.1,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
