import 'package:flutter/material.dart';

OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(width: 1.5, color: colorScheme.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      minimumSize: const Size(64, 56),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      foregroundColor: colorScheme.primary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  );
}
