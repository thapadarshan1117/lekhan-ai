import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(    context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
              ),
  
        ),
        const SizedBox(height: 8),
        SizedBox(height: 50,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: value,
            
            decoration: InputDecoration(
              hintText: 'Select',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                fontFamily: GoogleFonts.urbanist().fontFamily,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      e,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: GoogleFonts.urbanist().fontFamily,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
