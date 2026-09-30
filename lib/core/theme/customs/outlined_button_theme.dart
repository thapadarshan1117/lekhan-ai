import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(width: 1, color: colorScheme.secondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minimumSize: const Size(double.infinity, 50),
      textStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        fontFamily: GoogleFonts.outfit().fontFamily,
        
        color: colorScheme.secondary,
      ),
      foregroundColor: colorScheme.secondary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
