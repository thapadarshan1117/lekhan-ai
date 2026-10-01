import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
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
import 'package:lekhan_ai/features/projects/presentation/widgets/project_status_chip.dart';
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

  /// Passed through `extra` when arriving from the list, so the header is
  /// on screen instantly. Null on a cold start / deep link.
  final Project? initial;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  String? _bookId;
  bool _resolvingBook = true;
  String? _resolveError;

  @override
  void initState() {
    super.initState();
    _openProjectBook();
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

    final String? bookId = await _resolveProjectBookId(
      projectId: widget.projectId,
      fallbackTitle: widget.initial?.name ?? '',
    );

    if (!mounted) return;

    setState(() {
      _resolvingBook = false;
      _bookId = bookId;
      _resolveError = bookId == null ? _kCouldNotOpen : null;
    });
  }

  /// Local id of the project's own book: the oldest one already on this device,
  /// or a freshly created row when the project does not have one yet.
  Future<String?> _resolveProjectBookId({
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
      return ordered.first.id;
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
    return saved.valueOrNull?.id;
  }

  @override
  Widget build(BuildContext context) {
    final String? bookId = _bookId;

    final Widget page = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const <Widget>[
          Padding(padding: EdgeInsets.only(right: 12), child: SyncStatusChip()),
        ],
      ),
      floatingActionButton: bookId == null
          ? null
          : _NewChapterButton(bookId: bookId, projectId: widget.projectId),
      body: _buildBody(bookId),
    );

    // The bloc only exists once the project's book is known, and it has to sit
    // above the scaffold so the action button can read it as well.
    if (bookId == null) return page;

    return BlocProvider<ChaptersBloc>(
      // Created here rather than in DI: the bloc is scoped to this project's
      // book, and that id is only known once the book has been resolved.
      create: (BuildContext context) => ChaptersBloc(
        bookId: bookId,
        getChapters: sl<GetChaptersUsecase>(),
        watchChapters: sl<WatchChaptersUsecase>(),
      )..add(const ChaptersEvent.started()),
      child: page,
    );
  }

  Widget _buildBody(String? bookId) {
    if (_resolvingBook) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (bookId == null) {
      return _CouldNotOpenProject(
        message: _resolveError ?? _kCouldNotOpen,
        onRetry: _openProjectBook,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ProjectHeader(project: widget.initial, projectId: widget.projectId),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'Chapters',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: _ChaptersSection(bookId: bookId, projectId: widget.projectId),
        ),
      ],
    );
  }
}

/// "New chapter" for the project's book, numbered after the highest chapter
/// already loaded.
class _NewChapterButton extends StatelessWidget {
  const _NewChapterButton({required this.bookId, required this.projectId});

  final String bookId;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openForm(context),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('New chapter'),
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
    // covers the case where the form returned before the stream caught up.
    if (saved == true && context.mounted) {
      context.read<ChaptersBloc>().add(const ChaptersEvent.refreshed());
    }
  }
}

/// The chapter list of the project's book.
class _ChaptersSection extends StatelessWidget {
  const _ChaptersSection({required this.bookId, required this.projectId});

  final String bookId;
  final String projectId;

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
                if (chapters.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => context
                        .read<ChaptersBloc>()
                        .add(const ChaptersEvent.refreshed()),
                    child: ListView(
                      physics: const AlwaysScrollablePhysics(),
                      children: const <Widget>[
                        SizedBox(height: 60),
                        _NoChaptersYet(),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context
                      .read<ChaptersBloc>()
                      .add(const ChaptersEvent.refreshed()),
                  child: ListView.separated(
                    physics: const AlwaysScrollablePhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: chapters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final Chapter chapter = chapters[index];
                      return ChapterCard(
                        chapter: chapter,
                        onEdit: () => context.pushNamed(
                          'chapterForm',
                          queryParameters: <String, String>{
                            'bookId': bookId,
                            'projectId': projectId,
                            'number': '${chapter.number}',
                          },
                          extra: chapter,
                        ),
                        onDelete: () => _deleteChapter(context, chapter),
                        onTap: () => context.pushNamed(
                          'chapterDetail',
                          pathParameters: <String, String>{
                            'id': chapter.id,
                          },
                          extra: chapter,
                        ),
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

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({required this.project, required this.projectId});

  final Project? project;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final Project? value = project;

    if (value != null) return _buildHeader(context, value);

    // No `extra` (deep link): read it from the local store via the repository.
    return FutureBuilder<Either<AppException, Project>>(
      future: sl<GetProjectDetailUsecase>()(projectId),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<Either<AppException, Project>> snapshot,
          ) {
            final Project? loaded = snapshot.data?.valueOrNull;
            if (loaded == null) {
              return const SizedBox(
                height: 90,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            return _buildHeader(context, loaded);
          },
    );
  }

  Widget _buildHeader(BuildContext context, Project project) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ProjectStatusChip(status: project.status),
            ],
          ),
          if (project.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              project.description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
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
              Expanded(child: _ChapterCounts(project: project)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chapter totals straight from the loaded list, so the header never disagrees
/// with what is on screen. Falls back to the stored project figures until the
/// local store has answered.
class _ChapterCounts extends StatelessWidget {
  const _ChapterCounts({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChaptersBloc, ChaptersState>(
      builder: (BuildContext context, ChaptersState state) {
        return state.maybeWhen(
          loaded:
              (
                List<Chapter> chapters,
                bool isRefreshing,
                String? message,
                bool isEmptyBecauseOfError,
              ) {
                final int done = chapters
                    .where(
                      (Chapter chapter) =>
                          chapter.status == ChapterStatus.completed,
                    )
                    .length;
                return _counts(chapters.length, done);
              },
          orElse: () =>
              _counts(project.totalChapters, project.completedChapters),
        );
      },
    );
  }

  Widget _counts(int total, int done) {
    return Text(
      '$total chapters · $done completed',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
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
              size: 40,
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
            SizedBox(height: 6),
            Text(
              'Add the first one with the button below.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            size: 40,
            color: AppColors.textDisabled,
          ),          const SizedBox(height: 12),
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
