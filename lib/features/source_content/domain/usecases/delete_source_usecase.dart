import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Deleting is local-first as well: the bytes and the queued upload are removed
/// immediately, and the server is told afterwards (or on the next pass).
class DeleteSourceUsecase
    implements UsecaseWithParam<bool, DeleteSourceParams> {
  const DeleteSourceUsecase({
    required this.repository,
    required this.chapterRepository,
  });

  final ChapterSourceRepository repository;
  final ChapterRepository chapterRepository;

  @override
  Future<Either<AppException, bool>> call(DeleteSourceParams params) async {
    final Either<AppException, bool> deleted =
        await repository.deleteSource(params.sourceId);

    await _refreshChapterCounts(params.chapterId);
    return deleted;
  }

  Future<void> _refreshChapterCounts(String chapterId) async {
    final Either<AppException, List<ChapterSource>> sources =
        await repository.getSources(chapterId: chapterId);
    final Either<AppException, int> pending =
        await repository.pendingCount(chapterId);

    await chapterRepository.updateSourceCounts(
      chapterId: chapterId,
      sourceCount: sources.valuesOrEmpty.length,
      pendingSourceCount: pending.valueOrNull ?? 0,
    );
  }
}

class DeleteSourceParams {
  const DeleteSourceParams({required this.sourceId, required this.chapterId});

  final String sourceId;
  final String chapterId;
}

/// "Retry" on a failed card in the source list.
class RetryUploadUsecase
    implements UsecaseWithParam<ChapterSource, String> {
  const RetryUploadUsecase({required this.repository});

  final ChapterSourceRepository repository;

  @override
  Future<Either<AppException, ChapterSource>> call(String sourceId) {
    return repository.retryUpload(sourceId);
  }
}
