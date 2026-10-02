import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        _labelFor(context, status),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static String _labelFor(BuildContext context, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return context.l10n.projectStatusDraft;
      case ProjectStatus.assigned:
        return context.l10n.projectStatusAssigned;
      case ProjectStatus.inProgress:
        return context.l10n.projectStatusInProgress;
      case ProjectStatus.onHold:
        return context.l10n.projectStatusOnHold;
      case ProjectStatus.completed:
        return context.l10n.projectStatusCompleted;
      case ProjectStatus.archived:
        return context.l10n.projectStatusArchived;
    }
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
