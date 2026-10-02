import 'package:flutter/material.dart';

/// Accessible, nature-inspired colours used throughout Lekhan AI.
///
/// The primary green has a 6.5:1 contrast ratio against white, so large and
/// normal-sized button labels remain readable. Pale greens are reserved for
/// backgrounds; important text always uses one of the dark ink colours below.
class AppColors {
  // Primary brand colours
  static const Color primary = Color(0xFF176B45);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDDF3E6);
  static const Color onPrimaryContainer = Color(0xFF0B3522);

  // Secondary greens
  static const Color secondary = Color(0xFF2F6F4E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE4F2E9);
  static const Color onSecondaryContainer = Color(0xFF123C28);
  static const Color tertiary = Color(0xFF456653);

  // Error colours
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // Calm, warm-white surfaces reduce glare without lowering contrast.
  static const Color background = Color(0xFFF7FAF8);
  static const Color onBackground = Color(0xFF17251D);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF17251D);
  static const Color surfaceVariant = Color(0xFFE5EEE8);
  static const Color onSurfaceVariant = Color(0xFF405148);

  // Borders are intentionally visible for users with reduced contrast vision.
  static const Color outline = Color(0xFF68786F);
  static const Color outlineVariant = Color(0xFFC5D3CA);

  // Text colours
  static const Color textPrimary = Color(0xFF172B20);
  static const Color textSecondary = Color(0xFF4D6155);
  static const Color textDisabled = Color(0xFF65756C);

  // Status colours
  static const Color success = Color(0xFF176B45);
  static const Color warning = Color(0xFF9A6700);
  static const Color info = Color(0xFF1B6B69);
  static const Color primaryText = textPrimary;

  // Legacy aliases retained for older screens; all now use the green brand.
  static const Color gradientOrange = Color(0xFF4F9A70);
  static const Color gradientBlue = Color(0xFF176B45);
  static const Color gradientRed = Color(0xFF8A5A44);
  static const List<Color> primaryGradient = <Color>[
    Color(0xFF2F855A),
    Color(0xFF176B45),
  ];

  static const Color mainBrand = primary;
  static const Color mainDarker = Color(0xFF0F5132);
  static const Color mainLighter = Color(0xFFBFE3CD);
  static const Color mainSubtle = Color(0xFFE7F2EB);

  static const Color secondaryOrange = Color(0xFF397A57);
  static const Color secondaryLighter = Color(0xFFAED8BD);
  static const Color secondarySubtle = Color(0xFFE6F3EB);

  // Shared surfaces, dividers, ratings and badges
  static const Color chipBackground = Color(0xFFEDF4EF);
  static const Color dividerLight = Color(0xFFDDE7E0);
  static const Color sectionBackground = Color(0xFFF2F7F4);
  static const Color ratingStar = Color(0xFF9A6700);
  static const Color verifiedBlue = Color(0xFF176B69);
  static const Color offerRed = Color(0xFFB3261E);
  static const Color bookNowPillBackground = Color(0xFFE1F1E7);
  static const Color spotlightOrangeStart = Color(0xFF397A57);
  static const Color spotlightOrangeEnd = Color(0xFF17442D);
  static const Color spotlightBlueStart = Color(0xFF2E6B4A);
  static const Color spotlightBlueEnd = Color(0xFF123C28);

  // Older feature names are kept to avoid breaking existing screens.
  static const Color lekhan_aiOrange = primary;
  static const Color lekhan_aiOrangeLight = Color(0xFFE1F1E7);
  static const Color lekhan_aiWhite = Color(0xFFFFFFFF);
  static const Color lekhan_aiSurfaceMuted = Color(0xFFF0F6F2);
  static const Color lekhan_aiTextPrimary = textPrimary;
  static const Color lekhan_aiTextSecondary = textSecondary;
  static const Color lekhan_aiTextTertiary = textDisabled;
  static const Color lekhan_aiBorder = Color(0xFFD5E2D9);
  static const Color lekhan_aiRating = Color(0xFF9A6700);
  static const Color lekhan_aiVerified = Color(0xFF176B69);
  static const Color lekhan_aiLimitedRed = error;
}
