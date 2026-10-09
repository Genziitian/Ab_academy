import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// 8pt spacing scale and the radii used across the design.
abstract final class AppRadius {
  static const pill = BorderRadius.all(Radius.circular(999));
  static const xl = BorderRadius.all(Radius.circular(22));
  static const lg = BorderRadius.all(Radius.circular(20));
  static const card = BorderRadius.all(Radius.circular(18));
  static const md = BorderRadius.all(Radius.circular(16));
  static const button = BorderRadius.all(Radius.circular(15));
  static const sm = BorderRadius.all(Radius.circular(14));
  static const xs = BorderRadius.all(Radius.circular(12));
  static const tag = BorderRadius.all(Radius.circular(10));
}

abstract final class AppShadow {
  static const card = [BoxShadow(color: Color(0x0A14161C), blurRadius: 2, offset: Offset(0, 1))];
  static const cardRaised = [
    BoxShadow(color: Color(0x0D14161C), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const primaryButton = [
    BoxShadow(color: Color(0x403A3F99), blurRadius: 16, offset: Offset(0, 6)),
  ];
  static const hero = [BoxShadow(color: Color(0x381C1F4A), blurRadius: 24, offset: Offset(0, 10))];
  static const modal = [BoxShadow(color: Color(0x2414161C), blurRadius: 28, offset: Offset(0, 12))];
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.liveInk,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        base.textTheme,
      ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      splashFactory: InkRipple.splashFactory,
      dividerColor: AppColors.divider,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      ),
    );
  }
}
