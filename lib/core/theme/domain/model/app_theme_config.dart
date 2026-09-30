import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class AppThemeConfig {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isActive;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppThemeConfig({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isActive,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory AppThemeConfig.fromJson(Map<String, dynamic> json) {
    return AppThemeConfig(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      primaryColor: _parseHexColor((json['primary_color'] ?? '').toString()),
      secondaryColor:
          _parseHexColor((json['secondary_color'] ?? '').toString()),
      isActive: json['is_active'] == true,
      isDefault: json['is_default'] == true,
      createdAt: _tryParseDateTime(json['created_at']),
      updatedAt: _tryParseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primary_color': _toHex(primaryColor),
      'secondary_color': _toHex(secondaryColor),
      'is_active': isActive,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AppThemeConfig copyWith({
    String? id,
    String? name,
    Color? primaryColor,
    Color? secondaryColor,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppThemeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppThemeConfig &&
        other.id == id &&
        other.primaryColor.value == primaryColor.value &&
        other.secondaryColor.value == secondaryColor.value &&
        other.isActive == isActive &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hash(
        id,
        primaryColor.value,
        secondaryColor.value,
        isActive,
        isDefault,
      );
}

DateTime? _tryParseDateTime(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return DateTime.tryParse(str);
}

Color _parseHexColor(String input) {
  final cleaned = input.trim().replaceFirst('#', '');
  if (cleaned.isEmpty) {
    return AppColors.primary;
  }

  // Accept RGB (6) or ARGB (8)
  final normalized = cleaned.length == 6
      ? 'FF$cleaned'
      : cleaned.length == 8
          ? cleaned
          : null;

  if (normalized == null) {
    return AppColors.primary;
  }

  final value = int.tryParse(normalized, radix: 16);
  if (value == null) {
    return AppColors.primary;
  }

  return Color(value);
}

String _toHex(Color color) {
  final rgb = color.value & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
