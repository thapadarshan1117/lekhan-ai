import 'package:flutter/material.dart';
import 'color_scheme.dart';

class CustomChipTheme {
  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: lightColorScheme.surfaceContainerHighest,
    selectedColor: lightColorScheme.primary,
    backgroundColor: lightColorScheme.onPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: TextStyle(
      color: lightColorScheme.onPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: lightColorScheme.outline,
        width: 1,
      ),
    ),
    secondarySelectedColor: lightColorScheme.primary,
    showCheckmark: false,
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: lightColorScheme.surfaceContainerHighest,
    selectedColor: lightColorScheme.primary,
    backgroundColor: lightColorScheme.surfaceContainerHighest,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        width: 1,
      ),
    ),
    secondarySelectedColor: lightColorScheme.primary,
    showCheckmark: false,
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
  );
}
