import 'package:lekhan_ai/shared/custom_fields/domain/entities/custom_field_value.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_type.dart';

class CustomFieldValueModel extends CustomFieldValue {
  const CustomFieldValueModel({
    required super.id,
    required super.name,
    required super.fieldType,
    super.options,
    required super.isRequired,
    required super.value,
  });

  factory CustomFieldValueModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldValueModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      fieldType: CustomFieldType.fromApi((json['field_type'] ?? '').toString()),
      options: json['options'] is Map
          ? (json['options'] as Map).cast<String, dynamic>()
          : null,
      isRequired: json['is_required'] == true,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'field_type': fieldType.apiValue,
      'options': options,
      'is_required': isRequired,
      'value': value,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomFieldValue &&
        other.id == id &&
        other.name == name &&
        other.fieldType == fieldType &&
        other.isRequired == isRequired &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        fieldType,
        isRequired,
        value,
      );
}
