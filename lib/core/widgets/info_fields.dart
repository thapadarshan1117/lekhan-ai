

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoField extends StatelessWidget {
  final String label;
  final String fieldKey;
  final IconData icon;
  final Map<String, String> profileData;
  final Map<String, TextEditingController> controllers;
  final Map<String, FocusNode> focusNodes;
  final bool isEditMode;
  final Function(String) moveToNextField;

  const InfoField({
    super.key,
    required this.label,
    required this.fieldKey,
    required this.icon,
    required this.profileData,
    required this.controllers,
    required this.focusNodes,
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
                isEditMode && _isFieldEditable(fieldKey)
                    ? TextField(
                        controller: controllers[fieldKey],
                        focusNode: focusNodes[fieldKey],
                        textInputAction: _getTextInputAction(fieldKey),
                        onSubmitted: (_) => moveToNextField(fieldKey),
                        keyboardType: _getKeyboardType(fieldKey),
                        maxLines: _isMultilineField(fieldKey) ? 3 : 1,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          border: const UnderlineInputBorder(),
                          hintText: _getHintText(fieldKey),
                          hintStyle: GoogleFonts.urbanist(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDisplayValue(fieldKey, profileData[fieldKey]),
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: const Color(0xFF2D2D2D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isEditMode && !_isFieldEditable(fieldKey))
                            Icon(Icons.lock_outline,
                                size: 16, color: Colors.grey[500]),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods moved from main widget
  TextInputAction _getTextInputAction(String key) {
    const fieldOrder = [
      'name', 'email', 'phone', 'gender', 'position', 'experience',
      'joiningDate', 'qualifications', 'address', 'subjects', 'classes',
    ];
    final currentIndex = fieldOrder.indexOf(key);
    if (currentIndex == -1 || currentIndex == fieldOrder.length - 1) {
      return TextInputAction.done;
    }
    return TextInputAction.next;
  }

  TextInputType _getKeyboardType(String key) {
    switch (key) {
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'experience':
        return TextInputType.number;
      case 'address':
      case 'subjects':
      case 'classes':
      case 'qualifications':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  bool _isMultilineField(String key) {
    return ['address', 'subjects', 'classes', 'qualifications'].contains(key);
  }

  bool _isFieldEditable(String key) {
    const nonEditableFields = ['email', 'subjects', 'classes'];
    return !nonEditableFields.contains(key);
  }

  String _getHintText(String key) {
    switch (key) {
      case 'name':
        return 'Enter your full name';
      case 'email':
        return 'Email cannot be changed';
      case 'phone':
        return 'Enter your phone number';
      case 'position':
        return 'e.g., Senior Teacher, Head of Department';
      case 'experience':
        return 'Years of teaching experience (number only)';
      case 'qualifications':
        return 'e.g., M.Sc. Mathematics, B.Ed.';
      case 'address':
        return 'Enter your complete address';
      case 'subjects':
        return 'List subjects you teach (comma separated)';
      case 'classes':
        return 'List your assigned classes (comma separated)';
      default:
        return 'Enter $key';
    }
  }

  String _formatDisplayValue(String key, String? value) {
    if (value == null || value.isEmpty) return 'Not specified';

    switch (key) {
      case 'experience':
        return value == '0' || value.isEmpty ? 'Not specified' : '$value years';
      default:
        return value;
    }
  }
}