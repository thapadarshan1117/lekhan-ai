import 'package:flutter/material.dart';

/// A comfortably sized text scale for an older audience.
///
/// Platform fonts are used deliberately: they are familiar, remain available
/// offline and contain the accessibility refinements supplied by each OS.
/// System text scaling is preserved in `MyApp`, so users can enlarge these
/// sizes further from their phone settings.
class TTextTheme {
  TTextTheme._();

  static TextTheme textTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 54,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.14,
      ),
      displayMedium: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.24,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.28,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.35,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.35,
      ),
      labelMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
    );
  }
}
