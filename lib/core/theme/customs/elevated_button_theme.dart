import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ElevatedButtonThemeData elevatedButtonTheme(
    BuildContext context, ColorScheme colorScheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      disabledBackgroundColor: colorScheme.secondary.withValues(alpha: 0.5),
      disabledForegroundColor: colorScheme.onSecondary,
      minimumSize: const Size(double.infinity, 50),
      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
   

      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.surface,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
