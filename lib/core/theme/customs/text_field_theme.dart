import 'package:flutter/material.dart';

class TTextFieldTheme {
  TTextFieldTheme._();

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      errorMaxLines: 3,
      filled: true,
      fillColor: colorScheme.surface,
      prefixIconColor: colorScheme.primary,
      suffixIconColor: colorScheme.onSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      hintStyle: TextStyle(
        fontSize: 16,
        color: colorScheme.onSurfaceVariant,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        textBaseline: TextBaseline.alphabetic,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
        textBaseline: TextBaseline.alphabetic,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      errorStyle: TextStyle(fontSize: 14, color: colorScheme.error),
    );
  }
}
