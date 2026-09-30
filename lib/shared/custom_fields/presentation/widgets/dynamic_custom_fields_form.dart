import 'package:lekhan_ai/shared/custom_fields/domain/entities/custom_field_definition.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_type.dart';
import 'package:flutter/material.dart';

class DynamicCustomFieldsForm extends StatelessWidget {
  final List<CustomFieldDefinition> fields;

  /// Mutable values map owned by the screen.
  final Map<String, dynamic> values;

  /// Called whenever a value changes.
  final void Function(String fieldId, dynamic value) onChanged;

  const DynamicCustomFieldsForm({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) return const SizedBox.shrink();

    return Column(
      children: fields
          .map(
            (f) => _FieldTile(field: f, values: values, onChanged: onChanged),
          )
          .toList(),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final CustomFieldDefinition field;
  final Map<String, dynamic> values;
  final void Function(String fieldId, dynamic value) onChanged;

  const _FieldTile({
    required this.field,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = field.isRequired ? '${field.name} *' : field.name;

    switch (field.fieldType) {
      case CustomFieldType.text:
      case CustomFieldType.email:
      case CustomFieldType.number:
      case CustomFieldType.description:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextFormField(
              initialValue: (values[field.id] ?? '').toString(),
              keyboardType: _keyboardType(field.fieldType),
              maxLines: field.fieldType == CustomFieldType.description ? 3 : 1,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) {
                if (!field.isRequired) return null;
                if (v == null || v.trim().isEmpty) {
                  return '${field.name} is required';
                }
                if (field.fieldType == CustomFieldType.email &&
                    !v.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onChanged: (v) =>
                  onChanged(field.id, v.trim().isEmpty ? null : v),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(field.name),
                    if (field.isRequired)
                      Text(' *', style: TextStyle(color: Colors.red[400])),
                  ],
                ),
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
                hintText: 'Enter ${field.name.toLowerCase()}',
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                errorStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.red[400]),
              ),
            ),
          ),
        );

      case CustomFieldType.select:
        final items = _selectItems(field.options);
        // If no options configured for select field, show a message
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: 'No options configured',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(field.name),
                      if (field.isRequired)
                        Text(' *', style: TextStyle(color: Colors.red[400])),
                    ],
                  ),
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
                  errorStyle: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.red[400]),
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: values[field.id] as String?,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e.value,
                      child: Text(e.label),
                    ),
                  )
                  .toList(),
              onChanged: (v) => onChanged(field.id, v),
              validator: (v) {
                if (!field.isRequired) return null;
                if (v == null || v.isEmpty) return '${field.name} is required';
                return null;
              },
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(field.name),
                    if (field.isRequired)
                      Text(' *', style: TextStyle(color: Colors.red[400])),
                  ],
                ),
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
                hintText: 'Select ${field.name.toLowerCase()}',
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                errorStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.red[400]),
              ),
            ),
          ),
        );

      case CustomFieldType.date:
      case CustomFieldType.time:
      case CustomFieldType.dateTime:
      case CustomFieldType.timeRange:
        return _DateTimeField(
          field: field,
          label: label,
          values: values,
          onChanged: onChanged,
        );
    }
  }
}

class _DateTimeField extends StatelessWidget {
  final CustomFieldDefinition field;
  final String label;
  final Map<String, dynamic> values;
  final void Function(String fieldId, dynamic value) onChanged;

  const _DateTimeField({
    required this.field,
    required this.label,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final display = _displayValue(field.fieldType, values[field.id]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(text: display),
          onTap: () => _pick(context),
          validator: (v) {
            if (!field.isRequired) return null;
            if ((values[field.id] ?? '').toString().isEmpty) {
              return '${field.name} is required';
            }
            return null;
          },
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: InputBorder.none,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey[500],
              ),
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(field.name),
                if (field.isRequired)
                  Text(' *', style: TextStyle(color: Colors.red[400])),
              ],
            ),
            labelStyle: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
            hintText: 'Select ${field.name.toLowerCase()}',
            hintStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            errorStyle: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.red[400]),
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    switch (field.fieldType) {
      case CustomFieldType.date:
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (!context.mounted) return;
        if (d != null) {
          onChanged(field.id, d.toIso8601String());
        }
        return;

      case CustomFieldType.time:
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              ),
            );
          },
        );
        if (!context.mounted) return;
        if (t != null) {
          onChanged(
            field.id,
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
          );
        }
        return;

      case CustomFieldType.dateTime:
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (!context.mounted) return;
        if (d == null) return;
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              ),
            );
          },
        );
        if (!context.mounted) return;
        if (t == null) return;
        final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        onChanged(field.id, dt.toIso8601String());
        return;

      case CustomFieldType.timeRange:
        final start = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              ),
            );
          },
        );
        if (!context.mounted) return;
        if (start == null) return;
        final end = await showTimePicker(
          context: context,
          initialTime: start,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              ),
            );
          },
        );
        if (!context.mounted) return;
        if (end == null) return;
        final s =
            '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
        final e =
            '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
        onChanged(field.id, {'start': s, 'end': e});
        return;

      default:
        return;
    }
  }
}

TextInputType _keyboardType(CustomFieldType type) {
  switch (type) {
    case CustomFieldType.email:
      return TextInputType.emailAddress;
    case CustomFieldType.number:
      return TextInputType.number;
    default:
      return TextInputType.text;
  }
}

String _displayValue(CustomFieldType type, dynamic raw) {
  if (raw == null) return '';

  if (type == CustomFieldType.timeRange) {
    if (raw is Map) {
      final start = raw['start']?.toString() ?? '';
      final end = raw['end']?.toString() ?? '';
      if (start.isEmpty && end.isEmpty) return '';
      return '$start - $end';
    }
  }

  if (type == CustomFieldType.date || type == CustomFieldType.dateTime) {
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    if (type == CustomFieldType.date) {
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  return raw.toString();
}

class _SelectItem {
  final String value;
  final String label;

  const _SelectItem(this.value, this.label);
}

List<_SelectItem> _selectItems(Map<String, dynamic>? options) {
  if (options == null || options.isEmpty) return const [];

  // Treat map keys as submitted values, map values as labels.
  return options.entries
      .map((e) => _SelectItem(e.key.toString(), e.value.toString()))
      .toList();
}
