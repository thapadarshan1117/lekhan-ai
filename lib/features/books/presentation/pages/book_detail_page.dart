import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_book_detail_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/get_chapters_usecase.dart';
import 'package:lekhan_ai/features/chapters/presentation/bloc/chapters_bloc/chapters_bloc.dart';
import 'package:lekhan_ai/features/chapters/presentation/widgets/chapter_card.dart';
import 'package:lekhan_ai/features/sync/presentation/widgets/sync_status_chip.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// A book and its chapters.
class BookDetailPage extends StatelessWidget {
  const BookDetailPage({super.key, required this.bookId, this.initial});

  final String bookId;
  final Book? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChaptersBloc>(
      create: (BuildContext context) => ChaptersBloc(
        bookId: bookId,
        getChapters: sl<GetChaptersUsecase>(),
        watchChapters: sl<WatchChaptersUsecase>(),
      )..add(const ChaptersEvent.started()),
      child: _BookDetailView(bookId: bookId, initial: initial),
    );
  }
}

class _BookDetailView extends StatelessWidget {
  const _BookDetailView({required this.bookId, this.initial});

  final String bookId;
  final Book? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Book',
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
          final ChaptersState state = context.read<ChaptersBloc>().state;
          final int next = state.maybeWhen(
            loaded: (List<Chapter> chapters, bool _, String? __, bool ___) =>
                chapters.isEmpty
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
              'number': '$next',
            },
          );
          if (saved == true && context.mounted) {
            context.read<ChaptersBloc>().add(const ChaptersEvent.refreshed());
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New chapter'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _BookHeader(book: initial, bookId: bookId),
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
            child: BlocBuilder<ChaptersBloc, ChaptersState>(
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
                  loaded: (List<Chapter> chapters, bool isRefreshing,
                      String? message, bool isEmptyBecauseOfError) {
                    if (chapters.isEmpty) {
                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => context
                            .read<ChaptersBloc>()
                            .add(const ChaptersEvent.refreshed()),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
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
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: chapters.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) {
                          final Chapter chapter = chapters[index];
                          return ChapterCard(
                            chapter: chapter,
                            onTap: () => context.pushNamed(
                              'chapterDetail',
                              pathParameters: <String, String>{
                                'id': chapter.id,
                              },
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
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.book, required this.bookId});

  final Book? book;
  final String bookId;

  @override
  Widget build(BuildContext context) {
    final Book? value = book;
    if (value != null) return _buildHeader(value);

    return FutureBuilder<Either<AppException, Book>>(
      future: sl<GetBookDetailUsecase>()(bookId),
      builder:
          (BuildContext context, AsyncSnapshot<Either<AppException, Book>> snap) {
        final Book? loaded = snap.data?.valueOrNull;
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

  Widget _buildHeader(Book book) {
    final double progress = book.targetWords <= 0
        ? 0
        : (book.currentWords / book.targetWords).clamp(0, 1).toDouble();

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
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
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
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.targetWords > 0
                ? '${book.currentWords} of ${book.targetWords} words · '
                    '${book.status.label}'
                : '${book.currentWords} words · ${book.status.label}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
          ],
        ),
      ),
    );
  }
}
