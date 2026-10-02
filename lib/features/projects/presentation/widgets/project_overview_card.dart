import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/presentation/bloc/chapters_bloc/chapters_bloc.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_category.dart';
import 'package:lekhan_ai/l10n/l10n.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_status_chip.dart';

/// Who a manuscript is for, how far its words have come, and what the chapters
/// are still waiting on - the desk's whole summary of one project.
///
/// Everything here is derived: the completion figure from the book's word
/// counts, the shelf pills from the loaded chapter list, "last active" from the
/// project's own timestamp. Nothing is stored twice.
class ProjectOverviewCard extends StatelessWidget {
  const ProjectOverviewCard({
    super.key,
    required this.project,
    required this.book,
  });

  final Project project;

  /// The project's own book: the title, author and word counts shown here are
  /// the ones the writing desk tracks.
  final Book book;

  @override
  Widget build(BuildContext context) {
    final String title = book.title.trim().isNotEmpty
        ? book.title.trim()
        : project.name;
    final int target = book.targetWords;
    final int written = book.currentWords;
    final int percent = target > 0 ? (written / target * 100).round() : 0;
    final String? genre = book.genre.trim().isNotEmpty
        ? book.genre.trim()
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lekhan_aiBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Widget identity = _Identity(
                  title: title,
                  project: project,
                );

                final Widget score = _WordScore(
                  percent: percent,
                  written: written,
                  target: target,
                );

                if (constraints.maxWidth < 620) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      identity,
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: score,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: identity),
                    const SizedBox(width: 16),
                    score,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _OverallProgress(
              percent: percent,
              book: book,
              project: project,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                _InfoPill(
                  icon: Icons.menu_book_outlined,
                  label: context.l10n.bookSemantics(title),
                  accent: AppColors.primary,
                ),
                if (genre != null)
                  _InfoPill(
                    icon: Icons.category_outlined,
                    label: ProjectCategory.localizedLabel(context, genre),
                    accent: ProjectCategory.color(genre),
                  ),
                if (book.author.trim().isNotEmpty)
                  _InfoPill(
                    icon: Icons.person_outline,
                    label: context.l10n.byAuthor(book.author.trim()),
                    accent: AppColors.tertiary,
                  ),
                const SizedBox(width: 4),
                _AddChapterButton(
                  bookId: book.id,
                  projectId: book.projectId,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.dividerLight),
            const SizedBox(height: 12),
            const _ChapterTallies(),
          ],
        ),
      ),
    );
  }

}

class _Identity extends StatelessWidget {
  const _Identity({required this.title, required this.project});

  final String title;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _initials(title),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: <Widget>[
                  _Meta(
                    icon: Icons.schedule,
                    text: context.l10n.lastActive(
                      _relativeDay(context, project.updatedAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ProjectStatusChip(status: project.status),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _initials(String title) {
    final List<String> words = title
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
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

class _WordScore extends StatelessWidget {
  const _WordScore({
    required this.percent,
    required this.written,
    required this.target,
  });

  final int percent;
  final int written;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          context.l10n.percentDone(percent),
          style: const TextStyle(
            fontSize: 26,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          target > 0
              ? context.l10n.wordsOfGoal(
                  _grouped(written),
                  _grouped(target),
                )
              : context.l10n.wordsCount(_grouped(written)),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
}

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({
    required this.percent,
    required this.book,
    required this.project,
  });

  final int percent;
  final Book book;
  final Project project;

  @override
  Widget build(BuildContext context) {
    final double value = book.targetWords > 0
        ? (book.currentWords / book.targetWords).clamp(0, 1).toDouble()
        : project.totalChapters > 0
            ? (project.completedChapters / project.totalChapters)
                  .clamp(0, 1)
                  .toDouble()
            : 0;

    return Row(
      children: <Widget>[
        const Icon(
          Icons.schedule,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          context.l10n.overallPercent(percent),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// Counts of the chapters in each state, straight off the loaded list.
class _ChapterTallies extends StatelessWidget {
  const _ChapterTallies();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChaptersBloc, ChaptersState>(
      builder: (BuildContext context, ChaptersState state) {
        final List<Chapter> chapters = state.maybeWhen(
          loaded:
              (
                List<Chapter> chapters,
                bool isRefreshing,
                String? message,
                bool isEmptyBecauseOfError,
              ) => chapters,
          orElse: () => const <Chapter>[],
        );

        final int planned = chapters
            .where((Chapter c) => c.status == ChapterStatus.notStarted)
            .length;
        final int collecting = chapters
            .where((Chapter c) => c.status == ChapterStatus.researching)
            .length;
        final int drafting = chapters
            .where((Chapter c) => c.status == ChapterStatus.drafting)
            .length;
        final int review = chapters
            .where((Chapter c) => c.status == ChapterStatus.review)
            .length;
        final int done = chapters
            .where((Chapter c) => c.status == ChapterStatus.completed)
            .length;
        final int pendingAudio = chapters
            .where((Chapter c) => c.pendingSourceCount > 0)
            .length;

        final List<_Tally> tallies = <_Tally>[
          _Tally(
            Icons.event_note_outlined,
            context.l10n.planned,
            planned,
            AppColors.textSecondary,
          ),
          _Tally(
            Icons.mic_none_outlined,
            context.l10n.collecting,
            collecting,
            AppColors.info,
          ),
          _Tally(
            Icons.edit_note_outlined,
            context.l10n.drafting,
            drafting,
            AppColors.secondary,
          ),
          _Tally(
            Icons.rate_review_outlined,
            context.l10n.inReview,
            review,
            AppColors.tertiary,
          ),
          _Tally(
            Icons.task_alt_outlined,
            context.l10n.completed,
            done,
            AppColors.success,
          ),
          _Tally(
            Icons.graphic_eq,
            context.l10n.waitingForBackup,
            pendingAudio,
            AppColors.primary,
          ),
        ].where((_Tally t) => t.count > 0).toList();

        if (tallies.isEmpty) {
          return Text(
            context.l10n.noChaptersInBook,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final _Tally tally in tallies)
              _TallyPill(
                icon: tally.icon,
                label: tally.label,
                count: tally.count,
                color: tally.color,
              ),
          ],
        );
      },
    );
  }
}

class _Tally {
  const _Tally(this.icon, this.label, this.count, this.color);

  final IconData icon;
  final String label;
  final int count;
  final Color color;
}

class _TallyPill extends StatelessWidget {
  const _TallyPill({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lekhan_aiSurfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lekhan_aiBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textDisabled),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// "Add Chapter" for the book this card describes.
///
/// Reads the chapter bloc through its *own* context - the card sits below the
/// provider the page builds, so the button can too - and numbers the new
/// chapter after the highest one already loaded.
class _AddChapterButton extends StatelessWidget {
  const _AddChapterButton({required this.bookId, required this.projectId});

  final String bookId;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _openForm(context),
      icon: const Icon(Icons.add_rounded, size: 24, color: Colors.white),
            label: Text(
              context.l10n.addChapter,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final ChaptersState state = context.read<ChaptersBloc>().state;
    final int next = state.maybeWhen(
      loaded:
          (
            List<Chapter> chapters,
            bool isRefreshing,
            String? message,
            bool isEmptyBecauseOfError,
          ) => chapters.isEmpty
              ? 1
              : chapters
                    .map((Chapter chapter) => chapter.number)
                    .reduce((int a, int b) => a > b ? a : b) +
                  1,
      orElse: () => 1,
    );

    final bool? saved = await context.pushNamed<bool>(
      'chapterForm',
      queryParameters: <String, String>{
        'bookId': bookId,
        'projectId': projectId,
        'number': '$next',
      },
    );

    // The local watcher normally reports a saved chapter on its own; this
    // covers the form returning before the stream caught up.
    if (saved == true && context.mounted) {
      context.read<ChaptersBloc>().add(const ChaptersEvent.refreshed());
    }
  }
}
