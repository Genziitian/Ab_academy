import 'package:flutter/material.dart';

/// "Saffron & Ink" — the same cream / coal / saffron palette as the website,
/// so the app and abacademy.in read as one product. Primary is the deeper
/// clay so white button text stays readable; saffron is the accent.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFFB4521A);
  static const primaryPressed = Color(0xFF8A3C10);

  /// Navy used for hero cards, the course page header and headings.
  static const primaryDeep = Color(0xFF1C1814);
  static const primaryDeepRaised = Color(0xFF3A342D);
  static const primaryTint = Color(0xFFFBEADC);
  static const primaryTintBorder = Color(0xFFEFC9AD);
  static const primarySoft = Color(0xFFF7F3EC);
  static const accent = Color(0xFFE8742A);
  static const violet = Color(0xFF7A3E8E);
  static const teal = Color(0xFF0F7A6E);

  // Subject accents (ink / tint pairs)
  static const physics = Color(0xFFB4521A);
  static const physicsTint = Color(0xFFFBEADC);
  static const chemistry = Color(0xFF0F7A6E);
  static const chemistryTint = Color(0xFFE3F2EC);
  static const maths = Color(0xFF7A3E8E);
  static const mathsTint = Color(0xFFF3E8F5);
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
  static const ink = Color(0xFF1C1814);
  static const textBody = Color(0xFF4A433B);
  static const textBodyAlt = Color(0xFF4A433B);
  static const textMuted = Color(0xFF5E554B);
  static const textSubtle = Color(0xFF9A8F82);
  static const textFaint = Color(0xFFB5AB9E);
  static const textDisabled = Color(0xFFCFC6B8);
  static const textOnDark = Color(0xFFD9D1C4);
  static const textOnDarkMuted = Color(0xFFBDB4A7);
  static const textOnDarkAccent = Color(0xFFE8742A);

  // Surfaces
  static const surface = Color(0xFFFFFDF8);
  static const background = Color(0xFFF7F3EC);
  static const surfaceHover = Color(0xFFFBF8F2);
  static const surfaceMuted = Color(0xFFF3EDE3);
  static const fillMuted = Color(0xFFF3EDE3);
  static const fillMutedAlt = Color(0xFFECE4D6);
  static const trackMuted = Color(0xFFECE4D6);
  static const classroom = Color(0xFF1C1814);

  // Borders
  static const border = Color(0xFFE4DCCF);
  static const borderStrong = Color(0xFFE4DCCF);
  static const borderInput = Color(0xFFD9CFBF);
  static const borderRadio = Color(0xFFCFC4B3);
  static const divider = Color(0xFFECE4D6);
  static const dividerSoft = Color(0xFFF0E9DD);
  static const dividerFaint = Color(0xFFF0E9DD);
  static const navBorder = Color(0xFFE4DCCF);
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
