import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_books_usecase.dart';
import 'package:lekhan_ai/features/books/domain/usecases/save_book_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/delete_chapter_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/get_chapters_usecase.dart';
import 'package:lekhan_ai/features/chapters/presentation/bloc/chapters_bloc/chapters_bloc.dart';
import 'package:lekhan_ai/features/chapters/presentation/widgets/chapter_card.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/get_project_detail_usecase.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_overview_card.dart';
import 'package:lekhan_ai/features/source_content/presentation/widgets/add_source_sheet.dart';
import 'package:lekhan_ai/features/sync/presentation/widgets/sync_status_chip.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

const String _kCouldNotOpen =
    'This project could not be opened on this device.';

/// A project and the chapters inside it.
///
/// Navigation in this app is **project → chapter → source**: a project *is*
/// the book the writer is working in, so there is no separate books layer in
/// the UI. The [Book] row the offline file tree
/// (`projects/<projectId>/<bookId>/<chapterId>/…`) and the sync queue still
/// expect is resolved here - and created on first use - so every layer below
/// this screen keeps working untouched.
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.projectId, this.initial});

  final String projectId;

  /// Passed through `extra` when arriving from the list, so the header is on
  /// screen instantly. Null on a cold start / deep link.
  final Project? initial;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Project? _project;
  Book? _book;
  bool _resolvingBook = true;
  String? _resolveError;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _openProjectBook();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Finds the book that belongs to this project and opens the chapter list
  /// against it. A project that has never held a chapter yet gets its book row
  /// created right here, silently, so "New chapter" always has a parent.
  Future<void> _openProjectBook() async {
    // First call comes from initState, where the flag is already set.
    if (!_resolvingBook) {
      setState(() {
        _resolvingBook = true;
        _resolveError = null;
      });
    }

    final Project? project =
        widget.initial ??
        (await sl<GetProjectDetailUsecase>()(widget.projectId)).valueOrNull;

    final Book? book = await _resolveProjectBook(
      projectId: widget.projectId,
      fallbackTitle: project?.name ?? '',
    );

    if (!mounted) return;

    setState(() {
      _project = project;
      _book = book;
      _resolvingBook = false;
      _resolveError = book == null ? _kCouldNotOpen : null;
    });
  }

  /// The project's own book: the oldest one already on this device, or a freshly
  /// created row when the project does not have one yet.
  Future<Book?> _resolveProjectBook({
    required String projectId,
    required String fallbackTitle,
  }) async {
    final Either<AppException, List<Book>> existing = await sl<GetBooksUsecase>()(
      GetBooksParams(projectId: projectId),
    );
    final List<Book>? books = existing.valueOrNull;

    if (books != null && books.isNotEmpty) {
      final List<Book> ordered = List<Book>.of(books)
        ..sort((Book a, Book b) => a.createdAt.compareTo(b.createdAt));
      return ordered.first;
    }

    String title = fallbackTitle.trim();
    if (title.isEmpty) {
      final Project? project =
          (await sl<GetProjectDetailUsecase>()(projectId)).valueOrNull;
      title = project?.name.trim() ?? '';
    }

    final DateTime now = DateTime.now();
    final Book book = Book(
      id: IdGenerator.bookId(),
      projectId: projectId,
      title: title.isEmpty ? 'Untitled' : title,
      createdAt: now,
      updatedAt: now,
    );

    final Either<AppException, Book> saved = await sl<SaveBookUsecase>()(book);
    return saved.valueOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final Book? book = _book;
    final Project? project = _project;

    final Widget page = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          project?.name ?? book?.title ?? 'Project',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const <Widget>[
          Padding(padding: EdgeInsets.only(right: 12), child: SyncStatusChip()),
        ],
      ),
      body: _buildBody(project, book),
    );

    // The bloc only exists once the project's book is known, and it has to sit
    // above the scaffold so the header and the action button can read it too.
    if (book == null) return page;

    return BlocProvider<ChaptersBloc>(
      // Created here rather than in DI: the bloc is scoped to this project's
      // book, and that id is only known once the book has been resolved.
      create: (BuildContext context) => ChaptersBloc(
        bookId: book.id,
        getChapters: sl<GetChaptersUsecase>(),
        watchChapters: sl<WatchChaptersUsecase>(),
      )..add(const ChaptersEvent.started()),
      child: page,
    );
  }

  Widget _buildBody(Project? project, Book? book) {
    if (_resolvingBook) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (project == null || book == null) {
      return _CouldNotOpenProject(
        message: _resolveError ?? _kCouldNotOpen,
        onRetry: _openProjectBook,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ProjectOverviewCard(project: project, book: book),
        _ChapterToolbar(
          book: book,
          controller: _searchController,
          onQuery: (String value) => setState(() => _query = value),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _ChaptersSection(
            bookId: book.id,
            projectId: project.id,
            query: _query,
          ),
        ),
      ],
    );
  }

}

/// Which book the chapter list belongs to, plus the search that narrows it.
class _ChapterToolbar extends StatelessWidget {
  const _ChapterToolbar({
    required this.book,
    required this.controller,
    required this.onQuery,
  });

  final Book book;
  final TextEditingController controller;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final String genre = book.genre.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lekhan_aiBorder),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget label = Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.menu_book_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Book: ${book.title}'
                    '${genre.isNotEmpty ? ' ($genre)' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            );

            final Widget search = SizedBox(
              height: 36,
              width: constraints.maxWidth < 460 ? double.infinity : 220,
              child: TextField(
                controller: controller,
                onChanged: onQuery,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search chapters...',
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDisabled,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 17,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.lekhan_aiSurfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            );

            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  label,
                  const SizedBox(height: 8),
                  search,
                ],
              );
            }

            return Row(
              children: <Widget>[
                label,
                const Spacer(),
                search,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The chapter list of the project's book.
class _ChaptersSection extends StatelessWidget {
  const _ChaptersSection({
    required this.bookId,
    required this.projectId,
    required this.query,
  });

  final String bookId;
  final String projectId;
  final String query;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChaptersBloc, ChaptersState>(
      listener: (BuildContext context, ChaptersState state) {
        state.maybeWhen(
          loaded:
              (
                List<Chapter> chapters,
                bool isRefreshing,
                String? message,
                bool isEmptyBecauseOfError,
              ) {
                if (message != null && !isEmptyBecauseOfError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(message)));
                }
              },
          orElse: () {},
        );
      },
      builder: (BuildContext context, ChaptersState state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (String message) => Center(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          loaded:
              (
                List<Chapter> chapters,
                bool isRefreshing,
                String? message,
                bool isEmptyBecauseOfError,
              ) {
                final String needle = query.trim().toLowerCase();
                final List<Chapter> visible = needle.isEmpty
                    ? chapters
                    : chapters
                          .where(
                            (Chapter chapter) =>
                                chapter.title.toLowerCase().contains(needle) ||
                                chapter.summary.toLowerCase().contains(needle),
                          )
                          .toList();

                if (chapters.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => context
                        .read<ChaptersBloc>()
                        .add(const ChaptersEvent.refreshed()),
                    child: ListView(
                      physics: const AlwaysScrollablePhysics(),
                      children: const <Widget>[
                        SizedBox(height: 48),
                        _NoChaptersYet(),
                      ],
                    ),
                  );
                }

                if (visible.isEmpty) {
                  return const _NoChapterMatches();
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context
                      .read<ChaptersBloc>()
                      .add(const ChaptersEvent.refreshed()),
                  child: ListView.separated(
                    physics: const AlwaysScrollablePhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final Chapter chapter = visible[index];
                      return ChapterCard(
                        chapter: chapter,
                        onTap: () => context.pushNamed(
                          'chapterDetail',
                          pathParameters: <String, String>{
                            'id': chapter.id,
                          },
                          extra: chapter,
                        ),
                        onEditDraft: () => context.pushNamed(
                          'chapterForm',
                          queryParameters: <String, String>{
                            'bookId': bookId,
                            'projectId': projectId,
                            'number': '${chapter.number}',
                          },
                          extra: chapter,
                        ),
                        onUpload: () =>
                            AddSourceSheet.showWithChapter(context, chapter),
                        onDelete: () => _deleteChapter(context, chapter),
                      );
                    },
                  ),
                );
              },
        );
      },
    );
  }

  Future<void> _deleteChapter(BuildContext context, Chapter chapter) async {
    final String title = chapter.title.isEmpty
        ? 'Chapter ${chapter.number}'
        : chapter.title;
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Delete chapter?'),
            content: Text(
              '“$title” and its source files will be removed from this device. '
              'The server deletion will sync when available.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(dialogContext).colorScheme.error,
                ),
                child: const Text('Delete chapter'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;

    final result = await sl<DeleteChapterUsecase>()(chapter.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete chapter: ${failure.message}')),
      ),
      (deleted) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleted ? 'Chapter deleted.' : 'Chapter could not be deleted.',
          ),
        ),
      ),
    );
  }
}

class _NoChaptersYet extends StatelessWidget {
  const _NoChaptersYet();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.list_alt_outlined,
              size: 38,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: 12),
            Text(
              'No chapters yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Add the first one with “Add Chapter” above.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoChapterMatches extends StatelessWidget {
  const _NoChapterMatches();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search_off_outlined, size: 30, color: AppColors.textDisabled),
            SizedBox(height: 10),
            Text(
              'No chapter matches that search',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouldNotOpenProject extends StatelessWidget {
  const _CouldNotOpenProject({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollablePhysics(),
        children: <Widget>[
          const SizedBox(height: 120),
          const Icon(
            Icons.error_outline,
            size: 38,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
