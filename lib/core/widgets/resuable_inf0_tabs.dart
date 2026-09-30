import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableInfoTabs extends StatelessWidget {
  const ReusableInfoTabs({
    super.key,
    this.icon,
    required this.title,
    required this.onTap,
    this.subTitle,
  });

  final IconData? icon;
  final String? subTitle;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF4FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB1B1B1),width: 0.5)
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF333333),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize: 16,
                      fontFamily: GoogleFonts.urbanist().fontFamily,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF353535),
                    ),
                  ),
                  if (subTitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subTitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight:  FontWeight.w400,
                        color: Color(0xFF353535),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFAAAAAA),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}