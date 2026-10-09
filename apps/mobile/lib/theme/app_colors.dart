import 'package:flutter/material.dart';

/// Design tokens from the Bihar Board App design system (component sheet).
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF3A3F99);
  static const primaryPressed = Color(0xFF2A2E77);
  static const primaryDeep = Color(0xFF1C1F4A);
  static const primaryTint = Color(0xFFEEEFFA);
  static const primaryTintBorder = Color(0xFFDCDEF2);
  static const accent = Color(0xFFE07A2F);

  // Subject accents (ink / tint pairs)
  static const maths = Color(0xFF2C5FA8);
  static const mathsTint = Color(0xFFE8EEF9);
  static const science = Color(0xFF2E8B63);
  static const scienceInk = Color(0xFF2E7A58);
  static const scienceTint = Color(0xFFE9F3EE);
  static const hindi = Color(0xFFB5701F);
  static const hindiTint = Color(0xFFFDF0E4);
  static const english = Color(0xFF6B4FB5);
  static const englishTint = Color(0xFFF0ECFA);
  static const social = Color(0xFF1F7373);
  static const socialTint = Color(0xFFE4F1F1);

  // Status
  static const live = Color(0xFFD93A3A);
  static const liveInk = Color(0xFFC43B3B);
  static const liveTint = Color(0xFFFDE8E8);
  static const pdfTint = Color(0xFFFDE9E9);
  static const warning = Color(0xFFC08A2E);
  static const warningInk = Color(0xFFB5822A);
  static const warningTint = Color(0xFFFDF8F0);
  static const warningBorder = Color(0xFFF0E3CE);
  static const warningText = Color(0xFF8A7A5E);

  // Text
  static const ink = Color(0xFF14161C);
  static const textBody = Color(0xFF5A6070);
  static const textBodyAlt = Color(0xFF4A5060);
  static const textMuted = Color(0xFF6A7080);
  static const textSubtle = Color(0xFF9AA0AE);
  static const textFaint = Color(0xFFB0B5C0);
  static const textDisabled = Color(0xFFC7CAD3);

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFFBFBFD);
  static const surfaceHover = Color(0xFFFAFAFC);
  static const surfaceMuted = Color(0xFFF6F7FB);
  static const fillMuted = Color(0xFFF2F3F7);
  static const fillMutedAlt = Color(0xFFF4F5F8);
  static const trackMuted = Color(0xFFEDEFF4);

  // Borders
  static const border = Color(0xFFE8EAF0);
  static const borderStrong = Color(0xFFE4E7EE);
  static const borderInput = Color(0xFFDDE0E8);
  static const divider = Color(0xFFEFF1F5);
  static const dividerSoft = Color(0xFFF0F2F6);
  static const dividerFaint = Color(0xFFF2F3F7);
  static const navBorder = Color(0xFFECEEF3);
}

/// Subject-specific ink + tint used by tags, avatars and lesson rows.
enum SubjectPalette {
  mathematics(AppColors.maths, AppColors.mathsTint),
  science(AppColors.scienceInk, AppColors.scienceTint),
  hindi(AppColors.hindi, AppColors.hindiTint),
  english(AppColors.english, AppColors.englishTint),
  socialScience(AppColors.social, AppColors.socialTint);

  const SubjectPalette(this.ink, this.tint);

  final Color ink;
  final Color tint;

  static SubjectPalette fromName(String name) => switch (name.toLowerCase()) {
    'mathematics' || 'maths' || 'math' => mathematics,
    'science' => science,
    'hindi' => hindi,
    'english' => english,
    'social science' || 'social' => socialScience,
    _ => mathematics,
  };
}
