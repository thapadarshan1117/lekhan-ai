import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/delete_book_usecase.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_books_usecase.dart';
import 'package:lekhan_ai/features/books/presentation/bloc/books_bloc/books_bloc.dart';
import 'package:lekhan_ai/features/books/presentation/widgets/book_card.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/get_project_detail_usecase.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_status_chip.dart';
import 'package:lekhan_ai/features/sync/presentation/widgets/sync_status_chip.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// A project and the books inside it.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.projectId, this.initial});

  final String projectId;

  /// Passed through `extra` when arriving from the list, so the header is
  /// on screen instantly. Null on a cold start / deep link.
  final Project? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BooksBloc>(
      // Created here rather than in DI: the bloc is scoped to one project, so
      // the id is only known at the point of use. The use case itself comes
      // from the service locator.
      create: (BuildContext context) => BooksBloc(
        projectId: projectId,
        getBooks: sl<GetBooksUsecase>(),
        watchBooks: sl<WatchBooksUsecase>(),
      )..add(const BooksEvent.started()),
      child: _ProjectDetailView(projectId: projectId, initial: initial),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  const _ProjectDetailView({required this.projectId, this.initial});

  final String projectId;
  final Project? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: SyncStatusChip(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? saved = await context.pushNamed<bool>(
            'bookForm',
            queryParameters: <String, String>{'projectId': projectId},
          );
          if (saved == true && context.mounted) {
            context.read<BooksBloc>().add(const BooksEvent.refreshed());
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New book'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ProjectHeader(project: initial, projectId: projectId),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Books',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<BooksBloc, BooksState>(
              listener: (BuildContext context, BooksState state) {
                state.maybeWhen(
                  loaded: (List<Book> books, bool isRefreshing, String? message,
                      bool isEmptyBecauseOfError) {
                    if (message != null && !isEmptyBecauseOfError) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                  orElse: () {},
                );
              },
              builder: (BuildContext context, BooksState state) {
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
                  loaded: (List<Book> books, bool isRefreshing, String? message,
                      bool isEmptyBecauseOfError) {
                    if (books.isEmpty) {
                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => context
                            .read<BooksBloc>()
                            .add(const BooksEvent.refreshed()),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const <Widget>[
                            SizedBox(height: 60),
                            _NoBooksYet(),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => context
                          .read<BooksBloc>()
                          .add(const BooksEvent.refreshed()),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: books.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) {
                          final Book book = books[index];
                          return BookCard(
                            book: book,
                            onEdit: () => context.pushNamed(
                              'bookForm',
                              queryParameters: <String, String>{
                                'projectId': projectId,
                              },
                              extra: book,
                            ),
                            onDelete: () => _deleteBook(context, book),
                            onTap: () => context.pushNamed(
                              'bookDetail',
                              pathParameters: <String, String>{'id': book.id},
                              extra: book,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBook(BuildContext context, Book book) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Delete book?'),
            content: Text(
              '“${book.title}” and all of its chapters and source files will be '
              'removed from this device. The server deletion will sync when available.',
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
                child: const Text('Delete book'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;

    final result = await sl<DeleteBookUsecase>()(book.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete book: ${failure.message}')),
      ),
      (deleted) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deleted ? 'Book deleted.' : 'Book could not be deleted.')),
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

    if (value != null) return _buildHeader(value);

    // No `extra` (deep link): read it from the local store via the repository.
    return FutureBuilder<Either<AppException, Project>>(
      future: sl<GetProjectDetailUsecase>()(projectId),
      builder: (BuildContext context,
          AsyncSnapshot<Either<AppException, Project>> snapshot) {
        final Project? loaded = snapshot.data?.valueOrNull;
        if (loaded == null) {
          return const SizedBox(
            height: 90,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return _buildHeader(loaded);
      },
    );
  }

  Widget _buildHeader(Project project) {
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
              Text(
                '${project.totalChapters} chapters · '
                '${project.completedChapters} completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoBooksYet extends StatelessWidget {
  const _NoBooksYet();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.auto_stories_outlined,
              size: 40,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: 12),
            Text(
              'No books in this project yet',
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
