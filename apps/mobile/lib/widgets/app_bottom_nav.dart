import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data/providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ui_kit.dart';

/// Order matches the shell branches in the router.
enum AppTab { home, courses, academics, updates, more }

/// Bottom bar: Home, Courses, a raised Academics button in the middle,
/// Updates (announcements and notifications) and More.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({
    super.key,
    required this.active,
    required this.onSelected,
  });

  final AppTab active;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final unread = ref.watch(unreadCountProvider);

    Widget item(AppTab tab, IconData icon, String label, {int badge = 0}) =>
        Expanded(
          child: _NavItem(
            icon: icon,
            label: label,
            selected: tab == active,
            badge: badge,
            onTap: () => onSelected(tab),
          ),
        );

    return SizedBox(
      height: 74 + (safeBottom > 0 ? safeBottom : 8),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.navBorder)),
              ),
              padding: EdgeInsets.only(
                bottom: safeBottom > 0 ? safeBottom : 8,
                top: 8,
              ),
              child: Row(
                children: [
                  item(AppTab.home, LucideIcons.home, 'Home'),
                  item(AppTab.courses, LucideIcons.bookOpen, 'Courses'),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(AppTab.academics),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Academics',
                          style: AppText.tabular(
                            12,
                            FontWeight.w600,
                            color: active == AppTab.academics
                                ? AppColors.primary
                                : AppColors.textSubtle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  item(
                    AppTab.updates,
                    LucideIcons.bell,
                    'Updates',
                    badge: unread,
                  ),
                  item(AppTab.more, LucideIcons.menu, 'More'),
                ],
              ),
            ),
          ),
          // The raised centre button sits half above the bar.
          Positioned(
            top: -26,
            child: Semantics(
              button: true,
              selected: active == AppTab.academics,
              label: 'Academics',
              child: GestureDetector(
                onTap: () => onSelected(AppTab.academics),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const GradientIcon(
                    icon: LucideIcons.graduationCap,
                    gradient: AppGradients.brand,
                    size: 62,
                    iconSize: 28,
                    round: true,
                  ),
                ),
              ),
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
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSubtle;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -5,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 17),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      height: 17,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.liveDot,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: AppText.tabular(
                          10,
                          FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppText.tabular(12, FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
