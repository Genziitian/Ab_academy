import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// IBM Plex Sans for Latin, with IBM Plex Sans Devanagari as the fallback so
/// Hindi strings mixed into English copy render in the matching family.
abstract final class AppText {
  static final List<String> _fallback = [
    GoogleFonts.ibmPlexSansDevanagari().fontFamily!,
  ];

  static TextStyle _base(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: size,
      // Plex ships up to 700; heavier requests would be synthesised.
      fontWeight: weight.value > 700 ? FontWeight.w700 : weight,
      height: height,
      color: color ?? AppColors.ink,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: _fallback);
  }

  /// Devanagari-first style for copy that is entirely Hindi.
  static TextStyle devanagari(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
  }) {
    return GoogleFonts.ibmPlexSansDevanagari(
      fontSize: size,
      fontWeight: weight.value > 600 ? FontWeight.w600 : weight,
      height: height,
      color: color ?? AppColors.ink,
    );
  }

  /// Monospace digits for countdowns and order references.
  static TextStyle mono(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.ibmPlexMono(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.ink,
  );

  // Display / headings
  static TextStyle get display =>
      _base(30, FontWeight.w700, height: 1.1, letterSpacing: -0.6);
  static TextStyle get h1 =>
      _base(28, FontWeight.w700, height: 1.2, letterSpacing: -0.5);
  static TextStyle get h2 =>
      _base(26, FontWeight.w700, height: 1.2, letterSpacing: -0.5);
  static TextStyle get h3 =>
      _base(24, FontWeight.w700, height: 1.2, letterSpacing: -0.3);
  static TextStyle get h4 =>
      _base(22, FontWeight.w700, height: 1.25, letterSpacing: -0.2);
  static TextStyle get h5 =>
      _base(20, FontWeight.w700, height: 1.25, letterSpacing: -0.2);

  // Section + card titles
  static TextStyle get sectionTitle => _base(16, FontWeight.w600, height: 1.2);
  static TextStyle get cardTitleLg => _base(17, FontWeight.w600, height: 1.3);
  static TextStyle get cardTitle => _base(15, FontWeight.w600, height: 1.3);
  static TextStyle get cardTitleSm => _base(14, FontWeight.w600, height: 1.3);
  static TextStyle get rowTitle => _base(14, FontWeight.w600, height: 1.3);

  // Body
  static TextStyle get body =>
      _base(14, FontWeight.w400, height: 1.6, color: AppColors.textBody);
  static TextStyle get bodyCompact =>
      _base(14, FontWeight.w400, height: 1.5, color: AppColors.textMuted);
  static TextStyle get bodyLg =>
      _base(15, FontWeight.w400, height: 1.5, color: AppColors.textMuted);

  // Labels / metadata
  static TextStyle get label =>
      _base(13, FontWeight.w500, height: 1.3, color: AppColors.textMuted);
  static TextStyle get labelStrong =>
      _base(13, FontWeight.w600, height: 1.3, color: AppColors.textMuted);
  static TextStyle get meta =>
      _base(12, FontWeight.w400, height: 1.35, color: AppColors.textMuted);
  static TextStyle get metaSm =>
      _base(11, FontWeight.w400, height: 1.35, color: AppColors.textMuted);

  /// Uppercase eyebrow label, e.g. "PHYSICS", "CHAPTER 01", "TODAY".
  static TextStyle eyebrow({
    Color color = AppColors.textMuted,
    double size = 11,
    double letterSpacing = 0.7,
  }) => _base(
    size,
    FontWeight.w600,
    height: 1.2,
    color: color,
    letterSpacing: letterSpacing,
  );

  /// Small badge text, e.g. "LIVE", "RESOLVED", "TEACHER".
  static TextStyle badge({required Color color, double size = 10}) => _base(
    size,
    FontWeight.w700,
    height: 1.3,
    color: color,
    letterSpacing: 0.4,
  );

  // Buttons
  static TextStyle get buttonLg =>
      _base(16, FontWeight.w600, height: 1.0, color: Colors.white);
  static TextStyle get button => _base(15, FontWeight.w600, height: 1.0);
  static TextStyle get buttonSm => _base(13, FontWeight.w600, height: 1.0);

  // Numeric (tabular figures for timers, prices, progress)
  static TextStyle tabular(
    double size,
    FontWeight weight, {
    Color? color,
    double? letterSpacing,
  }) => _base(
    size,
    weight,
    color: color,
    letterSpacing: letterSpacing,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
