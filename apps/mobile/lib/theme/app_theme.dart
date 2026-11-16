import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Radii from "calm classroom": quiet rounding, 12px buttons, 16px cards.
abstract final class AppRadius {
  static const pill = BorderRadius.all(Radius.circular(999));
  static const xl = BorderRadius.all(Radius.circular(24));
  static const lg = BorderRadius.all(Radius.circular(20));
  static const card = BorderRadius.all(Radius.circular(16));
  static const md = BorderRadius.all(Radius.circular(14));
  static const button = BorderRadius.all(Radius.circular(12));
  static const sm = BorderRadius.all(Radius.circular(10));
  static const xs = BorderRadius.all(Radius.circular(8));
  static const tag = BorderRadius.all(Radius.circular(6));
  static const badge = BorderRadius.all(Radius.circular(4));
}

/// Flat: hairline borders instead of shadows. Only sheets and dialogs lift.
abstract final class AppShadow {
  static const card = <BoxShadow>[];
  static const cardRaised = <BoxShadow>[];
  static const primaryButton = <BoxShadow>[];
  static const hero = <BoxShadow>[];
  static const page = <BoxShadow>[];
  static const modal = [
    BoxShadow(color: Color(0x24171511), blurRadius: 32, offset: Offset(0, 12)),
  ];
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Geist',
      fontFamilyFallback: const ['Mukta'],
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.liveInk,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Geist',
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      splashColor: const Color(0x0F171511),
      highlightColor: const Color(0x0A171511),
      dividerColor: AppColors.divider,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.tray,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: Color(0x33D4622A),
        selectionHandleColor: AppColors.accent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryDeep,
        contentTextStyle: TextStyle(
          fontFamily: 'Geist',
          fontFamilyFallback: ['Mukta'],
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      ),
    );
  }
}
