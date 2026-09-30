  import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

InputDecoration get dropdownDecoration => InputDecoration(
        hintStyle: GoogleFonts.urbanist(
          textStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontFamily: GoogleFonts.urbanist().fontFamily,
            fontWeight: FontWeight.w400,),
          fontSize: 14,
          color: Colors.grey[500],
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      );