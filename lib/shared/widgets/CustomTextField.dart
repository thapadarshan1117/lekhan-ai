import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool required;
  final int? maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final Widget? suffix;
  final bool readOnly;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.maxLines,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.nextFocusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.suffix,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            Text('*', style: TextStyle(color: Colors.red[600])),
          ],
        ]),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines ?? 1,
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: readOnly ? Colors.grey[600] : null,
              ),
          focusNode: focusNode,
          textInputAction: textInputAction ??
              (nextFocusNode != null
                  ? TextInputAction.next
                  : TextInputAction.done),
          onEditingComplete: onEditingComplete ??
              () {
                if (nextFocusNode != null) {
                  nextFocusNode!.requestFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey[400],
                ),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey[400], size: 18)
                : null,
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: suffix,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey[50] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
          ),
          validator: validator ??
              (required
                  ? (value) => (value == null || value.trim().isEmpty)
                      ? 'This field is required'
                      : null
                  : null),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
