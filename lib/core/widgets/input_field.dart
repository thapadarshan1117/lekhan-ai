import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePasswordVisibility;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;
  final IconData? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final double? iconWeight;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final String? errorText;
  final Function()? onSuffixIconTap;
  final String? prefixText;
  final TextInputAction textInputAction;
  final Color? color;
  final double? size;

  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePasswordVisibility,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.readOnly = false,
    this.prefixText,
    this.suffixIcon,
    this.maxLines,
    this.iconWeight,
    this.inputFormatters,
    this.onChanged,
    this.errorText,
    this.onSuffixIconTap,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.color,
    this.size,
  }) : assert(!isPassword || maxLines == null || maxLines == 1,
            'Obscured fields cannot be multiline.');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          maxLines: isPassword ? 1 : maxLines,
          controller: controller,
          keyboardType: keyboardType,
          obscuringCharacter: '*',
          obscureText: isPassword && !isPasswordVisible,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.outfit().fontFamily,
              ),
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),

            // Enhanced border styling
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 0.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 0.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 0.5,
              ),
            ),

            // Fill color for better appearance
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,

            // Improved prefix handling
            prefixIcon: _buildPrefixWidget(context),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),

            // Enhanced suffix icon handling
            suffixIcon: _buildSuffixWidget(context),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),

            isDense: false,
            contentPadding: EdgeInsets.symmetric(
              horizontal: prefixIcon != null || prefixText != null ? 0 : 16,
              vertical: 16,
            ),

            // Error text styling
            errorStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
            errorMaxLines: 2,
          ),
          validator: validator,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }

  // Enhanced prefix widget builder
  Widget? _buildPrefixWidget(BuildContext context) {
    if (prefixIcon == null && prefixText == null) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon first
          if (prefixIcon != null) ...[
            prefixIcon!,
            if (prefixText != null) const SizedBox(width: 8),
          ],
          // Then prefix text
          if (prefixText != null)
            Container(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                prefixText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
              ),
            ),
        ],
      ),
    );
  }

  // Enhanced suffix widget builder
  Widget? _buildSuffixWidget(BuildContext context) {
    if (isPassword) {
      return Container(
        padding: const EdgeInsets.only(right: 12),
        child: IconButton(
          icon: Icon(
            isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
            size: 20,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: onTogglePasswordVisibility,
          tooltip: isPasswordVisible ? 'Hide password' : 'Show password',
          splashRadius: 20,
        ),
      );
    }

    if (suffixIcon != null) {
      return Container(
        padding: const EdgeInsets.only(right: 12),
        child: IconButton(
          icon: Icon(
            suffixIcon,
            size: 20,
            color: color ??
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: onSuffixIconTap,
          splashRadius: 20,
        ),
      );
    }

    return null;
  }
}
