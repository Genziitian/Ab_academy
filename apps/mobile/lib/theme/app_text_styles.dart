import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Hanken Grotesk for the interface and Instrument Serif for headings, as on
/// the website. IBM Plex Sans Devanagari is the fallback so Hindi (and ₹)
/// render in a matching weight. All bundled, so text never waits on a download.
abstract final class AppText {
  static const _family = 'Hanken';
  static const _serif = 'InstrumentSerif';
  static const _devanagari = 'PlexDevanagari';
  static const List<String> _fallback = [_devanagari];

  static TextStyle _base(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _family,
      fontFamilyFallback: _fallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? AppColors.ink,
      letterSpacing: letterSpacing ?? (size >= 18 ? -0.2 : 0),
    );
  }

  /// Serif headline. Instrument Serif has one weight, so it is never bolded.
  static TextStyle serif(
    double size, {
    double height = 1.05,
    Color? color,
    bool italic = false,
  }) {
    return TextStyle(
      fontFamily: _serif,
      fontFamilyFallback: _fallback,
      fontSize: size,
      fontWeight: FontWeight.w400,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      color: color ?? AppColors.ink,
      letterSpacing: -0.3,
    );
  }

  /// Devanagari-first style for copy that is entirely Hindi.
  static TextStyle devanagari(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _devanagari,
      fontSize: size,
      fontWeight: weight.value > 700 ? FontWeight.w700 : weight,
      height: height,
      color: color ?? AppColors.ink,
    );
  }

  /// Monospace digits for countdowns and order references.
  static TextStyle mono(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: 'PlexMono',
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.ink,
  );

  // Display / headings
  static TextStyle get display => serif(38, height: 1.0);
  static TextStyle get h1 => serif(34);
  static TextStyle get h2 => serif(32);
  static TextStyle get h3 => serif(30);
  static TextStyle get h4 => serif(27, height: 1.1);
  static TextStyle get h5 => serif(24, height: 1.1);

  // Section + card titles
  static TextStyle get sectionTitle => serif(22, height: 1.1);
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
    double letterSpacing = 1.4,
  }) => _base(
    size,
    FontWeight.w700,
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
