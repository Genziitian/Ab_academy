import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Radii from the redesign: flat, 8–16px corners rather than soft pills.
abstract final class AppRadius {
  static const pill = BorderRadius.all(Radius.circular(999));
  static const xl = BorderRadius.all(Radius.circular(22));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const card = BorderRadius.all(Radius.circular(12));
  static const md = BorderRadius.all(Radius.circular(14));
  static const button = BorderRadius.all(Radius.circular(10));
  static const sm = BorderRadius.all(Radius.circular(10));
  static const xs = BorderRadius.all(Radius.circular(8));
  static const tag = BorderRadius.all(Radius.circular(6));
  static const badge = BorderRadius.all(Radius.circular(4));
}

/// The redesign is mostly flat — hairline borders instead of drop shadows.
abstract final class AppShadow {
  static const card = <BoxShadow>[];
  static const cardRaised = [
    BoxShadow(color: Color(0x14122046), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const primaryButton = <BoxShadow>[];
  static const hero = <BoxShadow>[];
  static const page = [
    BoxShadow(color: Color(0x14122046), blurRadius: 14, offset: Offset(0, 4)),
  ];
  static const modal = [
    BoxShadow(color: Color(0x24122046), blurRadius: 28, offset: Offset(0, 12)),
  ];
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Jakarta',
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.liveInk,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Jakarta',
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      dividerColor: AppColors.divider,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryDeep,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      ),
    );
  }
}
