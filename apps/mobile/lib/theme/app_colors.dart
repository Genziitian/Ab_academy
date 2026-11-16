import 'package:flutter/material.dart';

/// "Calm classroom" — the same palette as abacademy.in: warm paper grey,
/// white panels, near-black ink. Saffron only marks things (the brand, today,
/// the active tab, live). Token names are kept from the earlier design so
/// every screen picks up the new look without changes.
abstract final class AppColors {
  // ---------------------------------------------------------------- core

  /// Page background — warm paper grey.
  static const canvas = Color(0xFFF3F2EE);

  /// Grey tray that holds a white card (stat tiles, grouped lists).
  static const tray = Color(0xFFEAE8E2);

  /// Hairline rule between and around panels.
  static const rule = Color(0xFFE3E0D8);
  static const ruleStrong = Color(0xFFCDC9BE);

  /// Saffron, and the darker saffron used for text on light backgrounds.
  static const accent = Color(0xFFD4622A);
  static const accentInk = Color(0xFFA8481B);
  static const accentSoft = Color(0xFFFBEEE5);

  // Brand. Primary actions are ink, as on the website.
  static const primary = Color(0xFF171511);
  static const primaryPressed = Color(0xFF000000);

  /// Ink panels: the continue-learning card, the course page header.
  static const primaryDeep = Color(0xFF171511);
  static const primaryDeepRaised = Color(0xFF2E2B25);
  static const primaryTint = Color(0xFFEFEDE7);
  static const primaryTintBorder = Color(0xFFCDC9BE);
  static const primarySoft = Color(0xFFF3F2EE);
  static const violet = Color(0xFF5B4A8A);
  static const teal = Color(0xFF2C7A6B);

  // Subject accents (ink / tint pairs) — quiet, so subjects read as labels.
  static const physics = Color(0xFFA8481B);
  static const physicsTint = Color(0xFFFBEEE5);
  static const chemistry = Color(0xFF2C7A6B);
  static const chemistryTint = Color(0xFFE6F1ED);
  static const maths = Color(0xFF5B4A8A);
  static const mathsTint = Color(0xFFEEEBF5);
  static const biology = Color(0xFF8A6A1E);
  static const biologyTint = Color(0xFFF6F0E1);
  static const english = Color(0xFF9A3B5B);
  static const englishTint = Color(0xFFF7EBF0);
  static const commerce = Color(0xFF2D6670);
  static const commerceTint = Color(0xFFE5EFF1);

  // Status. "Live" is green, as on the website; red is kept for errors.
  static const live = Color(0xFF2C7A4B);
  static const liveOnDark = Color(0xFF8FD3A8);
  static const liveDot = Color(0xFF2C7A4B);
  static const liveInk = Color(0xFFB42318);
  static const liveTint = Color(0xFFFCEBE9);
  static const pdfTint = Color(0xFFFCEBE9);
  static const success = Color(0xFF2C7A4B);
  static const successTint = Color(0xFFE5F1E9);
  static const successDot = Color(0xFF2C7A4B);
  static const warning = Color(0xFFA8481B);
  static const warningInk = Color(0xFFA8481B);
  static const warningTint = Color(0xFFFBEEE5);
  static const warningBorder = Color(0xFFF3D5C2);
  static const warningText = Color(0xFF7A4A2A);
  static const amberTint = Color(0xFFFBEEE5);
  static const dangerBorder = Color(0xFFF3CDC8);

  // Text
  static const ink = Color(0xFF171511);
  static const textBody = Color(0xFF3D3A34);
  static const textBodyAlt = Color(0xFF3D3A34);
  static const textMuted = Color(0xFF55514A);
  static const textSubtle = Color(0xFF8B867C);
  static const textFaint = Color(0xFFA9A498);
  static const textDisabled = Color(0xFFCDC9BE);
  static const textOnDark = Color(0xFFD8D5CE);
  static const textOnDarkMuted = Color(0xFFA9A498);
  static const textOnDarkAccent = Color(0xFFE88A5A);

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const background = canvas;
  static const surfaceHover = Color(0xFFF7F6F3);
  static const surfaceMuted = tray;
  static const fillMuted = canvas;
  static const fillMutedAlt = tray;
  static const trackMuted = tray;
  static const classroom = Color(0xFF171511);

  // Borders
  static const border = rule;
  static const borderStrong = ruleStrong;
  static const borderInput = ruleStrong;
  static const borderRadio = Color(0xFFB9B4A9);
  static const divider = Color(0xFFECEAE4);
  static const dividerSoft = Color(0xFFF0EEE9);
  static const dividerFaint = Color(0xFFF0EEE9);
  static const navBorder = rule;
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
    'physics' || 'भौतिकी' => physics,
    'chemistry' || 'science' || 'रसायन विज्ञान' => chemistry,
    'mathematics' || 'maths' || 'math' || 'गणित' => mathematics,
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
