import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme textTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.13,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF020202),
        height: 1.15,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF020202),
        height: 1.22,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.28,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.33,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.5,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.43,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.33,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.42,
      ),
      labelMedium: GoogleFonts.outfit(
      fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.45,
      ),
    );
  }
}