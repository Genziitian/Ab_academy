import 'package:flutter/material.dart';

/// Design tokens from the 2026 redesign — the same blue / navy palette as the
/// website, so the app and akhandbharatacademy.in read as one product.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF2962FF);
  static const primaryPressed = Color(0xFF1A4DE0);

  /// Navy used for hero cards, the course page header and headings.
  static const primaryDeep = Color(0xFF122046);
  static const primaryDeepRaised = Color(0xFF2A3A6E);
  static const primaryTint = Color(0xFFE8F0FF);
  static const primaryTintBorder = Color(0xFFC9D6F5);
  static const primarySoft = Color(0xFFF5F8FF);
  static const accent = Color(0xFFFF8A3D);
  static const violet = Color(0xFF7C5CFF);
  static const teal = Color(0xFF14B8A6);

  // Subject accents (ink / tint pairs)
  static const physics = Color(0xFF2962FF);
  static const physicsTint = Color(0xFFE8F0FF);
  static const chemistry = Color(0xFF0F8F81);
  static const chemistryTint = Color(0xFFE8FFF6);
  static const maths = Color(0xFF6B4FD8);
  static const mathsTint = Color(0xFFF1ECFF);
  static const biology = Color(0xFFC06A1A);
  static const biologyTint = Color(0xFFFFF1E8);
  static const english = Color(0xFFC23A68);
  static const englishTint = Color(0xFFFFEEF3);
  static const commerce = Color(0xFF1F7373);
  static const commerceTint = Color(0xFFE4F1F1);

  // Status
  static const live = Color(0xFFFF5D8F);
  static const liveOnDark = Color(0xFFFF8FB0);
  static const liveDot = Color(0xFFE5484D);
  static const liveInk = Color(0xFFC43B3B);
  static const liveTint = Color(0xFFFDE8E8);
  static const pdfTint = Color(0xFFFDE9E9);
  static const success = Color(0xFF16A34A);
  static const successTint = Color(0xFFE9F9EF);
  static const successDot = Color(0xFF22C55E);
  static const warning = Color(0xFFC06A1A);
  static const warningInk = Color(0xFFC06A1A);
  static const warningTint = Color(0xFFFFF8EC);
  static const warningBorder = Color(0xFFF6E3C4);
  static const warningText = Color(0xFF8A6A3E);
  static const amberTint = Color(0xFFFFF1E8);
  static const dangerBorder = Color(0xFFF2D6D6);

  // Text
  static const ink = Color(0xFF122046);
  static const textBody = Color(0xFF4A5872);
  static const textBodyAlt = Color(0xFF4A5872);
  static const textMuted = Color(0xFF6B7A90);
  static const textSubtle = Color(0xFF98A3B6);
  static const textFaint = Color(0xFFB0B8C6);
  static const textDisabled = Color(0xFFC7CAD3);
  static const textOnDark = Color(0xFFC8D1E4);
  static const textOnDarkMuted = Color(0xFF9AA7C2);
  static const textOnDarkAccent = Color(0xFF9FB8FF);

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F8FC);
  static const surfaceHover = Color(0xFFFAFBFD);
  static const surfaceMuted = Color(0xFFF5F8FF);
  static const fillMuted = Color(0xFFF2F3F7);
  static const fillMutedAlt = Color(0xFFECEEF3);
  static const trackMuted = Color(0xFFEDEFF4);
  static const classroom = Color(0xFF0F1B2D);

  // Borders
  static const border = Color(0xFFE6EBF5);
  static const borderStrong = Color(0xFFE4E7EE);
  static const borderInput = Color(0xFFDDE0E8);
  static const borderRadio = Color(0xFFD2D6E0);
  static const divider = Color(0xFFEFF1F5);
  static const dividerSoft = Color(0xFFF2F3F7);
  static const dividerFaint = Color(0xFFF2F3F7);
  static const navBorder = Color(0xFFECEEF3);
}

/// Subject-specific ink + tint used by tags, avatars and lesson rows.
enum SubjectPalette {
  physics(AppColors.physics, AppColors.physicsTint),
  chemistry(AppColors.chemistry, AppColors.chemistryTint),
  mathematics(AppColors.maths, AppColors.mathsTint),
  biology(AppColors.biology, AppColors.biologyTint),
  english(AppColors.english, AppColors.englishTint),
  commerce(AppColors.commerce, AppColors.commerceTint),
  other(AppColors.textBody, AppColors.fillMuted);

  const SubjectPalette(this.ink, this.tint);

  final Color ink;
  final Color tint;

  static SubjectPalette fromName(String name) => switch (name.toLowerCase()) {
    'physics' => physics,
    'chemistry' || 'science' => chemistry,
    'mathematics' || 'maths' || 'math' => mathematics,
    'biology' || 'hindi' => biology,
    'english' => english,
    'accountancy' ||
    'business studies' ||
    'economics' ||
    'commerce' ||
    'social science' ||
    'social' => commerce,
    _ => other,
  };
}
