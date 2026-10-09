import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';

/// Scaffold holding the five bottom-nav tabs; each tab keeps its own state.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        active: AppTab.values[navigationShell.currentIndex],
        onSelected: (tab) => navigationShell.goBranch(
          tab.index,
          initialLocation: tab.index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
