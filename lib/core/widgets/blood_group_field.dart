import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BloodGroupField extends StatelessWidget {
  final Map<String, String> profileData;
  final Map<String, TextEditingController> controllers;
  final bool isEditMode;
  final Function(String) moveToNextField;

  const BloodGroupField({
    super.key,
    required this.profileData,
    required this.controllers,
    required this.isEditMode,
    required this.moveToNextField,
  });

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

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
            child: const Icon(Icons.bloodtype_outlined,
                size: 16, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blood Group',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                isEditMode
                    ? DropdownButtonFormField<String>(
                        value: profileData['bloodGroup']?.isNotEmpty == true &&
                                bloodGroups.contains(profileData['bloodGroup'])
                            ? profileData['bloodGroup']
                            : null,
                        onChanged: (value) {
                          profileData['bloodGroup'] = value ?? '';
                          controllers['bloodGroup']?.text = value ?? '';
                          moveToNextField('bloodGroup');
                        },
                        items: bloodGroups
                            .map((bloodGroup) => DropdownMenuItem<String>(
                                  value: bloodGroup,
                                  child: Text(bloodGroup),
                                ))
                            .toList(),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: UnderlineInputBorder(),
                          hintText: 'Select blood group',
                        ),
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        profileData['bloodGroup']?.isNotEmpty == true
                            ? profileData['bloodGroup']!
                            : 'Not specified',
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