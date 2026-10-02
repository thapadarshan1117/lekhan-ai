import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_category.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_status_chip.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// A clear, uncluttered book card for the main shelf.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.book,
    this.onEdit,
    this.onDelete,
  });

  final Project project;
  final Book? book;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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

    return Semantics(
      container: true,
      label: context.l10n.bookSemantics(title),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lekhan_aiBorder, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _Cover(title: title, coverImageUrl: book?.coverImageUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ProjectCategoryChip(type: category),
                          const SizedBox(height: 9),
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (book != null && book.author.trim().isNotEmpty) ...
                              <Widget>[
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.byAuthor(book.author.trim()),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.35,
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
                if (project.description.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(
                    project.description.trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        chaptersTotal > 0
                            ? context.l10n.chaptersComplete(
                                chaptersDone,
                                chaptersTotal,
                              )
                            : context.l10n.readyFirstChapter,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (targetWords > 0) ...<Widget>[
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                if (targetWords > 0) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.wordsOfGoal(
                      _grouped(writtenWords),
                      _grouped(targetWords),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.menu_book_rounded, size: 25),
                  label: Text(context.l10n.openBook),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 58),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    ProjectStatusChip(status: project.status),
                    Text(
                      context.l10n.updatedWhen(_relativeDay(context, project.updatedAt)),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

  static String _relativeDay(BuildContext context, DateTime when) {
    final DateTime now = DateTime.now();
    final int days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(when.year, when.month, when.day))
        .inDays;
    if (days <= 0) return context.l10n.today;
    if (days == 1) return context.l10n.yesterday;
    if (days < 30) return context.l10n.daysAgo(days);
    final int months = (days / 30).floor();
    if (months < 12) return context.l10n.monthsAgo(months);
    return context.l10n.yearsAgo((months / 12).floor());
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.title, this.coverImageUrl});

  final String title;
  final String? coverImageUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = coverImageUrl?.trim();
    final String initials = _initials(title);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 78,
        height: 106,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF2F855A), Color(0xFF0F5132)],
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
      padding: const EdgeInsets.all(8),
      child: Text(
        initials,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 20,
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
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: context.l10n.bookActions,
      icon: const Icon(Icons.more_vert_rounded),
      constraints: const BoxConstraints(minWidth: 210),
      onSelected: (String value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (onEdit != null)
          PopupMenuItem<String>(
            value: 'edit',
            height: 56,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined),
              title: Text(
                context.l10n.editBook,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        if (onDelete != null)
          PopupMenuItem<String>(
            value: 'delete',
            height: 56,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              title: Text(
                context.l10n.deleteBook,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
