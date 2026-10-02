import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// Registers a file that is already inside the app's store.
///
/// Used by the voice recorder: the recorder plugin writes straight into the
/// chapter's `recordings/` folder, so there is nothing to copy. After creating
/// the source record, this also refreshes the chapter counters so the chapter
/// card immediately reflects the newly saved recording.
class AddExistingFileUsecase
    implements UsecaseWithParam<ChapterSource, AddExistingFileParams> {
  const AddExistingFileUsecase({
    required this.repository,
    required this.chapterRepository,
  });

  final ChapterSourceRepository repository;
  final ChapterRepository chapterRepository;

  @override
  Future<Either<AppException, ChapterSource>> call(
    AddExistingFileParams params,
  ) async {
    final Either<AppException, ChapterSource> result =
        await repository.addExistingFile(
      localPath: params.localPath,
      chapter: params.chapter,
      sourceType: params.sourceType,
      displayName: params.displayName,
      duration: params.duration,
      createdBy: params.createdBy,
    );

    if (result.valueOrNull != null) {
      await _refreshChapterCounts(params.chapter.id);
    }

    return result;
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

class AddExistingFileParams {
  const AddExistingFileParams({
    required this.localPath,
    required this.chapter,
    required this.sourceType,
    this.displayName,
    this.duration,
    this.createdBy,
  });

  final String localPath;
  final Chapter chapter;
  final SourceType sourceType;
  final String? displayName;
  final Duration? duration;
  final String? createdBy;
}
