import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequiredText extends StatelessWidget {
  const RequiredText({
    super.key,
    required this.title,
    this.isRequired = false,
  });

  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: GoogleFonts.urbanist().fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              fontFamily: GoogleFonts.urbanist().fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
