import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BodyDescriptionText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  const BodyDescriptionText(
      {super.key, required this.text, this.color = Colors.black87, this.fontWeight, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color,fontWeight: fontWeight,fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 14),
    );
  }
}
