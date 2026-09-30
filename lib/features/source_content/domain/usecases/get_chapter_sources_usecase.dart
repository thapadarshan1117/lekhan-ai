import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class GetChapterSourcesUsecase
    implements UsecaseWithParam<List<ChapterSource>, GetChapterSourcesParams> {
  const GetChapterSourcesUsecase({required this.repository});

  final ChapterSourceRepository repository;

  @override
  Future<Either<AppException, List<ChapterSource>>> call(
    GetChapterSourcesParams params,
  ) {
    return repository.getSources(
      chapterId: params.chapterId,
      chapterRemoteId: params.chapterRemoteId,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetChapterSourcesParams {
  const GetChapterSourcesParams({
    required this.chapterId,
    this.chapterRemoteId,
    this.forceRefresh = false,
  });

  final String chapterId;

  /// Needed only to consult the server; the local read works without it.
  final String? chapterRemoteId;

  final bool forceRefresh;
}

/// Live list for the chapter screen: upload status, processing status and
/// progress all arrive through this stream as the sync engine updates the
/// local records.
class WatchChapterSourcesUsecase {
  const WatchChapterSourcesUsecase({required this.repository});

  final ChapterSourceRepository repository;

  Stream<List<ChapterSource>> call(String chapterId) =>
      repository.watchSources(chapterId: chapterId);
}

/// Status of a single source (used by the upload progress card).
class WatchUploadStatusUsecase {
  const WatchUploadStatusUsecase({required this.repository});

  final ChapterSourceRepository repository;

  Stream<List<ChapterSource>> call(String chapterId) =>
      repository.watchSources(chapterId: chapterId);
}
