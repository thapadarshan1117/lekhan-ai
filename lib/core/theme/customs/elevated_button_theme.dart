import 'package:flutter/material.dart';

ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.35),
      disabledForegroundColor: colorScheme.onPrimary,
      minimumSize: const Size(64, 56),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 17,
      ),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  );
}
