import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_type.dart';

class CustomFieldValue {
  final String id;
  final String name;
  final CustomFieldType fieldType;
  final Map<String, dynamic>? options;
  final bool isRequired;
  final dynamic value;

  const CustomFieldValue({
    required this.id,
    required this.name,
    required this.fieldType,
    this.options,
    required this.isRequired,
    required this.value,
  });
}
