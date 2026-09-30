import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateField extends StatelessWidget {
  final String label;
  final String fieldKey;
  final IconData icon;
  final Map<String, String> profileData;
  final Map<String, TextEditingController> controllers;
  final bool isEditMode;
  final Function(String) selectDate;

  const DateField({
    super.key,
    required this.label,
    required this.fieldKey,
    required this.icon,
    required this.profileData,
    required this.controllers,
    required this.isEditMode,
    required this.selectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF6B6B6B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                isEditMode
                    ? GestureDetector(
                        onTap: () => selectDate(fieldKey),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: controllers[fieldKey],
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: const Color(0xFF2D2D2D),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              border: const UnderlineInputBorder(),
                              hintText: 'Select joining date',
                              hintStyle: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              suffixIcon: Icon(Icons.calendar_today_outlined,
                                  size: 16, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _formatDisplayValue(fieldKey, profileData[fieldKey]),
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDisplayValue(String key, String? value) {
    if (value == null || value.isEmpty) return 'Not specified';

    if (key == 'joiningDate') {
      try {
        final date = DateTime.parse(value);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return value;
      }
    }
    return value;
  }
}