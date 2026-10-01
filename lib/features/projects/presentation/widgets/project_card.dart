import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_category.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_status_chip.dart';

/// One manuscript on the shelf.
///
/// A project *is* a book in this app's navigation, so the card reads as a
/// product: cover, shelf, title, author, and how far the words have come. The
/// [book] is the project's own row; when it has not been created yet the card
/// falls back to the project's own figures instead of showing zeros.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.book,
    this.onEdit,
    this.onDelete,
    this.onAiStudio,
    this.onProof,
  });

  final Project project;

  /// The project's own book, when the local store has one.
  final Book? book;

  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Secondary desks. Not wired to a screen yet - see the call site.
  final VoidCallback? onAiStudio;
  final VoidCallback? onProof;

  @override
  Widget build(BuildContext context) {
    final Book? book = this.book;
    final String title = (book?.title.trim().isNotEmpty ?? false)
        ? book!.title.trim()
        : project.name;
    final String? category = (book?.genre.trim().isNotEmpty ?? false)
        ? book!.genre.trim()
        : project.type;

    final int chaptersTotal = book?.chapterCount ?? project.totalChapters;
    final int chaptersDone = project.completedChapters;
    final int targetWords = book?.targetWords ?? 0;
    final int writtenWords = book?.currentWords ?? 0;

    final double progress = targetWords > 0
        ? (writtenWords / targetWords).clamp(0, 1).toDouble()
        : chaptersTotal > 0
            ? (chaptersDone / chaptersTotal).clamp(0, 1).toDouble()
            : 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lekhan_aiBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Cover(title: title, coverImageUrl: book?.coverImageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ProjectCategoryChip(type: category),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (book != null && book.author.trim().isNotEmpty) ...
                            <Widget>[
                          const SizedBox(height: 4),
                          Text(
                            'Author: ${book.author.trim()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    _CardMenu(onEdit: onEdit, onDelete: onDelete),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Text(
                    '$chaptersDone of $chaptersTotal Chapters',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (targetWords > 0)
                    Text(
                      '${_grouped(writtenWords)} / ${_grouped(targetWords)} w '
                      '(${(writtenWords / targetWords * 100).round()}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _CardAction(
                      icon: Icons.menu_book_outlined,
                      label: 'Chapters',
                      filled: true,
                      onTap: onTap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CardAction(
                    icon: Icons.auto_awesome_outlined,
                    label: 'AI Studio',
                    onTap: onAiStudio,
                  ),
                  const SizedBox(width: 8),
                  _CardAction(
                    icon: Icons.fact_check_outlined,
                    label: 'Proof',
                    onTap: onProof,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  ProjectStatusChip(status: project.status),
                  const Spacer(),
                  Text(
                    'Updated ${_relativeDay(project.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
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

  static String _grouped(int value) {
    final String digits = value.abs().toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return value < 0 ? '-$out' : out.toString();
  }

  static String _relativeDay(DateTime when) {
    final DateTime now = DateTime.now();
    final int days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(when.year, when.month, when.day)).inDays;
    if (days <= 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 30) return '$days days ago';
    final int months = (days / 30).floor();
    if (months < 12) return '$months mo ago';
    return '${(months / 12).floor()} yr ago';
  }
}

/// Cover thumbnail: the stored image when there is one, otherwise a spine with
/// the manuscript's initials - the same trick the printed shelf uses.
class _Cover extends StatelessWidget {
  const _Cover({required this.title, this.coverImageUrl});

  final String title;
  final String? coverImageUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = coverImageUrl?.trim();
    final String initials = _initials(title);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 64,
        height: 86,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF163C8C), Color(0xFF3E6BC4)],
          ),
        ),
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsTile(initials),
              )
            : _initialsTile(initials),
      ),
    );
  }

  Widget _initialsTile(String initials) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: Text(
        initials,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  static String _initials(String title) {
    final List<String> words = title
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

/// Overflow menu: edit and delete live here so the card body stays clean.
class _CardMenu extends StatelessWidget {
  const _CardMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Project actions',
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
      color: Colors.white,
      onSelected: (String value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (onEdit != null)
          const PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_outlined, size: 18),
              title: Text('Edit project'),
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline, size: 18),
              title: Text('Delete project'),
            ),
          ),
      ],
    );
  }
}

/// One of the card's desk buttons. [filled] is the primary action.
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color foreground = filled ? Colors.white : AppColors.textSecondary;
    final Color background =
        filled ? AppColors.success : AppColors.lekhan_aiSurfaceMuted;

    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15, color: foreground),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: filled
                ? BorderSide.none
                : const BorderSide(color: AppColors.lekhan_aiBorder),
          ),
        ),
      ),
    );
  }
}
