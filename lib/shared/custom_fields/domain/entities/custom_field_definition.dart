import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_module.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_type.dart';

class CustomFieldDefinition {
  final String id;
  final String name;
  final CustomFieldType fieldType;
  final Map<String, dynamic>? options;
  final int order;
  final bool isRequired;
  final bool state;
  final CustomFieldModule moduleType;

  const CustomFieldDefinition({
    required this.id,
    required this.name,
    required this.fieldType,
    required this.options,
    required this.order,
    required this.isRequired,
    required this.state,
    required this.moduleType,
  });
}
