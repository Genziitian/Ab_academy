import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

enum AppTab { home, courses, live, community, profile }

const _items = <(AppTab, IconData, String)>[
  (AppTab.home, LucideIcons.home, 'Home'),
  (AppTab.courses, LucideIcons.bookOpen, 'Courses'),
  (AppTab.live, LucideIcons.radio, 'Live'),
  (AppTab.community, LucideIcons.users, 'Community'),
  (AppTab.profile, LucideIcons.user, 'Profile'),
];

/// The five-tab bottom bar from `BottomNav.dc.html`.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.active, required this.onSelected});

  final AppTab active;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.navBorder)),
      ),
      padding: EdgeInsets.fromLTRB(12, 10, 12, safeBottom > 0 ? safeBottom : 14),
      child: Row(
        children: [
          for (final (tab, icon, label) in _items)
            Expanded(
              child: _NavItem(
                icon: icon,
                label: label,
                selected: tab == active,
                onTap: () => onSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSubtle;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.only(top: 8, bottom: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : Colors.transparent,
          borderRadius: AppRadius.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppText.tabular(10.5, FontWeight.w600, color: color, letterSpacing: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}
