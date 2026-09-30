import 'package:lekhan_ai/shared/custom_fields/domain/entities/custom_field_definition.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_module.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_type.dart';

class CustomFieldDefinitionModel extends CustomFieldDefinition {


  const CustomFieldDefinitionModel({
    required super.id,
    required super.name,
    required super.fieldType,
    required super.options,
    required super.order,
    required super.isRequired,
    required super.state,
    required super.moduleType,
  });

  factory CustomFieldDefinitionModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldDefinitionModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      fieldType: CustomFieldType.fromApi((json['field_type'] ?? '').toString()),
      options: json['options'] is Map
          ? (json['options'] as Map).cast<String, dynamic>()
          : null,
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      isRequired: json['is_required'] == true,
      state: json['state'] == true,
      moduleType: _parseModuleType((json['module_type'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'field_type': fieldType.apiValue,
      'options': options,
      'order': order,
      'is_required': isRequired,
      'state': state,
      'module_type': moduleType.apiValue,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomFieldDefinition &&
        other.id == id &&
        other.name == name &&
        other.fieldType == fieldType &&
        other.order == order &&
        other.isRequired == isRequired &&
        other.state == state &&
        other.moduleType == moduleType;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        fieldType,
        order,
        isRequired,
        state,
        moduleType,
      );
}

CustomFieldModule _parseModuleType(String value) {
  final normalized = value.trim();
  for (final m in CustomFieldModule.values) {
    if (m.apiValue == normalized) return m;
  }
  return CustomFieldModule.lead;
}
