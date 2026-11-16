import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Geist for the interface and headings, Mukta for Devanagari, Geist Mono for
/// times, dates and chapter numbers — the same type as abacademy.in. All
/// bundled, so text never waits on a download.
///
/// Headings are tight in English. Devanagari needs room (its matras sit above
/// and below the line), so when the app is in Hindi [hindi] is set and
/// headings get no negative tracking and taller lines.
abstract final class AppText {
  static const _family = 'Geist';
  static const _devanagari = 'Mukta';
  static const _mono = 'GeistMono';
  static const List<String> _fallback = [_devanagari];

  /// Set by the app when the language changes; the whole tree rebuilds then.
  static bool hindi = false;

  static TextStyle _base(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
    double? letterSpacing,
  }) {
    final tight = size >= 18 ? -0.015 * size : 0.0;
    return TextStyle(
      fontFamily: _family,
      fontFamilyFallback: _fallback,
      fontSize: size,
      fontWeight: weight,
      height: hindi && height != null ? height + 0.12 : height,
      color: color ?? AppColors.ink,
      letterSpacing: hindi ? 0 : (letterSpacing ?? tight),
    );
  }

  /// Display heading. (Kept as `serif` so existing screens need no change;
  /// the face is now Geist SemiBold, set tight.)
  static TextStyle serif(
    double size, {
    double height = 1.08,
    Color? color,
    bool italic = false,
  }) {
    return TextStyle(
      fontFamily: _family,
      fontFamilyFallback: _fallback,
      fontSize: hindi ? size * 0.92 : size * 0.88,
      fontWeight: FontWeight.w600,
      height: hindi ? height + 0.2 : height,
      color: color ?? AppColors.ink,
      letterSpacing: hindi ? 0 : -0.03 * size,
    );
  }

  static TextStyle display(double size, {double height = 1.08, Color? color}) =>
      serif(size, height: height, color: color);

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

  /// Monospace for times, dates, chapter numbers and order references.
  static TextStyle mono(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: _mono,
    fontFamilyFallback: _fallback,
    fontSize: size,
    fontWeight: weight.value > 500 ? FontWeight.w500 : weight,
    color: color ?? AppColors.ink,
    letterSpacing: -0.1,
  );

  // Display / headings
  static TextStyle get display38 => serif(38, height: 1.0);
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

  /// Small label above a heading, e.g. "PHYSICS", "CHAPTER 01". Mono and
  /// uppercase in English; plain Mukta in Hindi, where case does not exist.
  static TextStyle eyebrow({
    Color color = AppColors.textSubtle,
    double size = 11,
    double letterSpacing = 0.8,
  }) {
    if (hindi) {
      return TextStyle(
        fontFamily: _devanagari,
        fontSize: size + 1.5,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: color,
      );
    }
    return TextStyle(
      fontFamily: _mono,
      fontFamilyFallback: _fallback,
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.25,
      color: color,
      letterSpacing: letterSpacing.clamp(0, 1.0),
    );
  }

  /// Small badge text, e.g. "LIVE", "RESOLVED", "TEACHER".
  static TextStyle badge({required Color color, double size = 10}) => _base(
    size + 1,
    FontWeight.w600,
    height: 1.3,
    color: color,
    letterSpacing: 0.2,
  );

  // Buttons
  static TextStyle get buttonLg =>
      _base(16, FontWeight.w500, height: 1.0, color: Colors.white);
  static TextStyle get button => _base(15, FontWeight.w500, height: 1.0);
  static TextStyle get buttonSm => _base(13, FontWeight.w500, height: 1.0);

  // Numeric (tabular figures for timers, prices, progress)
  static TextStyle tabular(
    double size,
    FontWeight weight, {
    Color? color,
    double? letterSpacing,
  }) => _base(
    size,
    // Geist reads heavier than Hanken did; soften the boldest weights.
    weight.value >= 800 ? FontWeight.w600 : (weight == FontWeight.w700 ? FontWeight.w600 : weight),
    color: color,
    letterSpacing: letterSpacing,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
