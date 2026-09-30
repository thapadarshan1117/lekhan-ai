import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderField extends StatelessWidget {
  final Map<String, String> profileData;
  final Map<String, TextEditingController> controllers;
  final bool isEditMode;
  final Function(String) moveToNextField;

  const GenderField({
    super.key,
    required this.profileData,
    required this.controllers,
    required this.isEditMode,
    required this.moveToNextField,
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
            child: const Icon(Icons.person_pin_outlined,
                size: 16, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                isEditMode
                    ? DropdownButtonFormField<String>(
                        value: profileData['gender']?.isNotEmpty == true
                            ? profileData['gender']
                            : null,
                        onChanged: (value) {
                          profileData['gender'] = value ?? '';
                          controllers['gender']?.text = value ?? '';
                          moveToNextField('gender');
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: UnderlineInputBorder(),
                        ),
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        profileData['gender'] ?? 'Not specified',
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
}