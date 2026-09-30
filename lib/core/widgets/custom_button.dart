import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final double borderRadius;
  final double elevation;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 48.0,
    this.borderRadius = 12.0,
    this.elevation = 2.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity, // Default to full width if not specified
      height: height, // Default height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ??
              Theme.of(context)
                  .colorScheme
                  .secondaryContainer, // Default to theme primary
          foregroundColor: textColor ?? Colors.white, // Text/icon color
          elevation: elevation, // Shadow elevation
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(borderRadius), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 24.0), // Increased horizontal padding
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20.0),
              const SizedBox(width: 8.0), // Space between icon and text
            ],
            Text(
              text,
              style: textStyle ??
                  TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          textColor ?? Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
