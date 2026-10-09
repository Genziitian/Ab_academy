import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Plus Jakarta Sans for Latin, Noto Sans Devanagari for Hindi strings.
abstract final class AppText {
  static TextStyle _base(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? AppColors.ink,
      letterSpacing: letterSpacing,
    );
  }

  /// Devanagari counterpart — used for Hindi copy (कक्षा दस, बिहार बोर्ड …).
  static TextStyle devanagari(double size, FontWeight weight, {double? height, Color? color}) {
    return GoogleFonts.notoSansDevanagari(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? AppColors.ink,
    );
  }

  // Display / headings
  static TextStyle get display => _base(30, FontWeight.w800, height: 1.0, letterSpacing: -0.6);
  static TextStyle get h1 => _base(28, FontWeight.w800, height: 1.2, letterSpacing: -0.6);
  static TextStyle get h2 => _base(26, FontWeight.w800, height: 1.25, letterSpacing: -0.5);
  static TextStyle get h3 => _base(24, FontWeight.w800, height: 1.2, letterSpacing: -0.5);
  static TextStyle get h4 => _base(21, FontWeight.w800, height: 1.3, letterSpacing: -0.4);
  static TextStyle get h5 => _base(20, FontWeight.w800, height: 1.2, letterSpacing: -0.4);

  // Section + card titles
  static TextStyle get sectionTitle => _base(16, FontWeight.w700, height: 1.0, letterSpacing: -0.2);
  static TextStyle get cardTitleLg => _base(17, FontWeight.w700, height: 1.3, letterSpacing: -0.2);
  static TextStyle get cardTitle => _base(15, FontWeight.w700, height: 1.3);
  static TextStyle get cardTitleSm => _base(14, FontWeight.w700, height: 1.3);
  static TextStyle get rowTitle => _base(14.5, FontWeight.w700, height: 1.0);

  // Body
  static TextStyle get body => _base(13.5, FontWeight.w400, height: 1.7, color: AppColors.textBody);
  static TextStyle get bodyCompact =>
      _base(14, FontWeight.w400, height: 1.5, color: AppColors.textMuted);
  static TextStyle get bodyLg =>
      _base(14.5, FontWeight.w400, height: 1.5, color: AppColors.textMuted);

  // Labels / metadata
  static TextStyle get label => _base(13, FontWeight.w500, height: 1.0, color: AppColors.textMuted);
  static TextStyle get labelStrong =>
      _base(12.5, FontWeight.w600, height: 1.0, color: AppColors.textMuted);
  static TextStyle get meta => _base(12, FontWeight.w400, height: 1.0, color: AppColors.textSubtle);
  static TextStyle get metaSm =>
      _base(11.5, FontWeight.w400, height: 1.0, color: AppColors.textSubtle);

  /// Uppercase eyebrow label, e.g. "SCIENCE", "CHAPTER 01", "TODAY".
  static TextStyle eyebrow({
    Color color = AppColors.textSubtle,
    double size = 11,
    double letterSpacing = 1,
  }) => _base(size, FontWeight.w700, height: 1.0, color: color, letterSpacing: letterSpacing);

  /// Pill badge text, e.g. "LIVE", "COMPLETED", "LOCKED".
  static TextStyle badge({required Color color, double size = 9.5}) =>
      _base(size, FontWeight.w800, height: 1.3, color: color, letterSpacing: 1);

  // Buttons
  static TextStyle get buttonLg => _base(15.5, FontWeight.w700, height: 1.0, color: Colors.white);
  static TextStyle get button => _base(14.5, FontWeight.w700, height: 1.0);
  static TextStyle get buttonSm => _base(13, FontWeight.w700, height: 1.0);

  // Numeric (tabular figures for timers, prices, progress)
  static TextStyle tabular(double size, FontWeight weight, {Color? color, double? letterSpacing}) =>
      _base(
        size,
        weight,
        color: color,
        letterSpacing: letterSpacing,
      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
