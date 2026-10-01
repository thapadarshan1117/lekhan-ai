import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';

/// One chapter in the list, including how much source material is still
/// waiting to upload - the number the writer actually cares about.
class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Chapter chapter;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final double progress = chapter.targetWords <= 0
        ? 0
        : (chapter.currentWords / chapter.targetWords).clamp(0, 1).toDouble();

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
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${chapter.number}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      chapter.title.isEmpty
                          ? 'Chapter ${chapter.number}'
                          : chapter.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (onEdit != null) ...<Widget>[
                    IconButton(
                      tooltip: 'Edit chapter',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 30,
                        height: 30,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                  ] else
                    const SizedBox(width: 8),
                  if (onDelete != null) ...<Widget>[
                    IconButton(
                      tooltip: 'Delete chapter',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 17),
                      color: Theme.of(context).colorScheme.error,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 30,
                        height: 30,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                  ],
                  _ChapterStatusChip(status: chapter.status),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.folder_outlined,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${chapter.sourceCount} sources',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (chapter.pendingSourceCount > 0) ...<Widget>[
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${chapter.pendingSourceCount} waiting',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    chapter.targetWords > 0
                        ? '${chapter.currentWords}/${chapter.targetWords}'
                        : '${chapter.currentWords} words',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterStatusChip extends StatelessWidget {
  const _ChapterStatusChip({required this.status});

  final ChapterStatus status;

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

  static Color _colorFor(ChapterStatus status) {
    switch (status) {
      case ChapterStatus.notStarted:
        return AppColors.textSecondary;
      case ChapterStatus.researching:
        return AppColors.secondary;
      case ChapterStatus.drafting:
        return AppColors.primary;
      case ChapterStatus.review:
        return AppColors.tertiary;
      case ChapterStatus.completed:
        return const Color(0xFF1B7F4B);
    }
  }
}
