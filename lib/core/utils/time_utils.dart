import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/services/app_timezone_service.dart';

class DueDateStatus {
  final String text;
  final Color color;
  final bool isOverdue;

  const DueDateStatus({
    required this.text,
    required this.color,
    required this.isOverdue,
  });
}

class DueDateUtils {
  static DueDateStatus getStatus(DateTime dueDate, {DateTime? now}) {
    final current = now ?? AppTimezoneService.instance.now();
    final diff = dueDate.difference(current);

    if (diff.isNegative) {
      final past = current.difference(dueDate);

      if (past.inDays > 0) {
        return DueDateStatus(
          text: 'Overdue ${past.inDays}d',
          color: AppColors.error,
          isOverdue: true,
        );
      } else if (past.inHours > 0) {
        return DueDateStatus(
          text: 'Overdue ${past.inHours}h',
          color: AppColors.error,
          isOverdue: true,
        );
      } else {
        return DueDateStatus(
          text: 'Overdue ${past.inMinutes}m',
          color: AppColors.error,
          isOverdue: true,
        );
      }
    }

    if (diff.inDays > 0) {
      return DueDateStatus(
        text: 'Due in ${diff.inDays}d',
        color: AppColors.success,
        isOverdue: false,
      );
    } else if (diff.inHours > 0) {
      return DueDateStatus(
        text: 'Due in ${diff.inHours}h',
        color: AppColors.warning,
        isOverdue: false,
      );
    } else if (diff.inMinutes > 0) {
      return DueDateStatus(
        text: 'Due in ${diff.inMinutes}m',
        color: AppColors.warning,
        isOverdue: false,
      );
    }

    return DueDateStatus(
      text: 'Due now',
      color: AppColors.warning,
      isOverdue: false,
    );
  }
}
