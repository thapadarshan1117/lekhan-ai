import 'dart:ui';
import 'package:lekhan_ai/core/theme/app_color.dart';

enum Priority {
  high,
  medium,
  low,
  none;

  static Priority fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      case 'low':
        return Priority.low;
      default:
        return Priority.none;
    }
  }
}

class PriorityUtils {
  static PriorityMeta resolve(Priority priority) {
    switch (priority) {
      case Priority.high:
        return PriorityMeta(
          label: 'High',
          color: AppColors.error,
          weight: 3,
        );
      case Priority.medium:
        return PriorityMeta(
          label: 'Medium',
          color: AppColors.warning,
          weight: 2,
        );
      case Priority.low:
        return PriorityMeta(
          label: 'Low',
          color: AppColors.success,
          weight: 1,
        );
      case Priority.none:
        return PriorityMeta(
          label: 'None',
          color: AppColors.onSurfaceVariant,
          weight: 0,
        );
    }
  }
}

class PriorityMeta {
  final String label;
  final Color color;
  final int weight;

  const PriorityMeta({
    required this.label,
    required this.color,
    required this.weight,
  });
}
