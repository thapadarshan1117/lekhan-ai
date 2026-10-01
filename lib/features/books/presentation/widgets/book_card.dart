import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';

/// One book inside a project.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final double progress = book.targetWords <= 0
        ? 0
        : (book.currentWords / book.targetWords).clamp(0, 1).toDouble();

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
                      book.title,
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
                      tooltip: 'Edit book',
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
                      tooltip: 'Delete book',
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
                  _BookStatusChip(status: book.status),
                ],
              ),
              if (book.author.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'by ${book.author}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
                  Text(
                    '${book.chapterCount} chapters',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    book.targetWords > 0
                        ? '${book.currentWords} / ${book.targetWords} words'
                        : '${book.currentWords} words',
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

class _BookStatusChip extends StatelessWidget {
  const _BookStatusChip({required this.status});

  final BookStatus status;

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

  static Color _colorFor(BookStatus status) {
    switch (status) {
      case BookStatus.planning:
        return AppColors.textSecondary;
      case BookStatus.writing:
        return AppColors.primary;
      case BookStatus.review:
        return AppColors.secondary;
      case BookStatus.completed:
        return const Color(0xFF1B7F4B);
      case BookStatus.archived:
        return AppColors.textDisabled;
    }
  }
}
