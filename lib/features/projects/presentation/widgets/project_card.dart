import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_status_chip.dart';

/// One engagement in the projects list.
///
/// Shows the offline story explicitly: a card that has never reached the server
/// says so, instead of pretending it is saved everywhere.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (onEdit != null) ...<Widget>[
                    IconButton(
                      tooltip: 'Edit project',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 2),
                  ] else
                    const SizedBox(width: 8),
                  if (onDelete != null) ...<Widget>[
                    IconButton(
                      tooltip: 'Delete project',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Theme.of(context).colorScheme.error,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                  ],
                  ProjectStatusChip(status: project.status),
                ],
              ),
              if (project.description.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${project.totalChapters} chapters',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (project.completedChapters > 0) ...<Widget>[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${project.completedChapters} done',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    project.readableUpdatedAt,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
              if (project.remoteId == null) ...<Widget>[
                const SizedBox(height: 10),
                const _WaitingToUploadBadge(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Waiting to upload" is a first-class state here, not an error.
class _WaitingToUploadBadge extends StatelessWidget {
  const _WaitingToUploadBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.cloud_upload_outlined,
            size: 13,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 5),
          Text(
            'Waiting to upload',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
