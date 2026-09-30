import 'package:flutter/material.dart';

class TFormDivider extends StatelessWidget {
  const TFormDivider({
    super.key,
    required this.dividerText,
  });
  final String dividerText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          child: Divider(
            color: Color(0xFFB1B1B1),
            thickness: 0.5,
            indent: 10,
            endIndent: 5,
          ),
        ),
        SizedBox(width: 10),
        Text(
          dividerText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Color(0xFFB1B1B1),
              ),
        ),
        SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Divider(
            color: Color(0xFFB1B1B1),
            thickness: 0.5,
            indent: 5,
            endIndent: 10,
          ),
        )
      ],
    );
  }
}
