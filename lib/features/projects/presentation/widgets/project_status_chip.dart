import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';

/// Colour-coded status of a project, book or chapter.
///
/// Kept in one place so the same status never looks different on two screens.
class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = _colorFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static Color _colorFor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return AppColors.textSecondary;
      case ProjectStatus.assigned:
        return AppColors.tertiary;
      case ProjectStatus.inProgress:
        return AppColors.primary;
      case ProjectStatus.onHold:
        return AppColors.secondary;
      case ProjectStatus.completed:
        return const Color(0xFF1B7F4B);
      case ProjectStatus.archived:
        return AppColors.textDisabled;
    }
  }
}
