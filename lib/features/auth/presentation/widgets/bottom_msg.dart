import 'package:flutter/material.dart';

class BottomMsg extends StatelessWidget {
  const BottomMsg({
    super.key,
    required this.text,
    required this.onTap,
    required this.onTapText,
  });

  final String text;
  final VoidCallback? onTap;
  final String onTapText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Added this
      crossAxisAlignment: CrossAxisAlignment.center, // Added this
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w400,
              ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size.zero, // Removes minimum size constraints
            padding: EdgeInsets.zero, // Removes default padding
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks tap area
          ),
          onPressed: onTap,
          child: Text(
            onTapText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
      ],
    );
  }
}
