import 'package:flutter/material.dart';

class TTextFieldTheme {
  TTextFieldTheme._();

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      errorMaxLines: 1,
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      hintStyle: const TextStyle().copyWith(
        color: colorScheme.onSurfaceVariant,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle().copyWith(
        fontWeight: FontWeight.w400,
        color: colorScheme.scrim,
        height: 1.0,
        textBaseline: TextBaseline.alphabetic,
      ),
      border: const OutlineInputBorder().copyWith(
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      floatingLabelStyle: const TextStyle().copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.secondary,
        height: 1.0,
        textBaseline: TextBaseline.alphabetic,
      ),
      enabledBorder: const OutlineInputBorder().copyWith(
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.secondary,
          width: 1.0,
        ),
      ),
      errorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 0.8,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error, width: 1.0),
      ),
      errorStyle: const TextStyle().copyWith(
        fontSize: 12,
        color: colorScheme.error,
      ),
    );
  }
}
