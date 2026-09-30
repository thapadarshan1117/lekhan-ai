import 'dart:io';

import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Adding source content, offline-first.
///
///   1. the file is copied into the chapter folder,
///   2. a local record is written,
///   3. a sync task is queued - **not** executed,
///   4. the chapter's counters are refreshed.
///
/// The screen can therefore answer immediately with "waiting to upload" and the
/// data is already safe if the phone loses its connection, is closed, or runs
/// out of battery right after this call returns.
class AddSourceUsecase
    implements UsecaseWithParam<ChapterSource, AddSourceParams> {
  const AddSourceUsecase({
    required this.repository,
    required this.chapterRepository,
  });

  final ChapterSourceRepository repository;
  final ChapterRepository chapterRepository;

  @override
  Future<Either<AppException, ChapterSource>> call(AddSourceParams params) async {
    final Either<AppException, ChapterSource> result = await repository.addSource(
      file: params.file,
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

class AddSourceParams {
  const AddSourceParams({
    required this.file,
    required this.chapter,
    this.sourceType,
    this.displayName,
    this.duration,
    this.createdBy,
  });

  final File file;
  final Chapter chapter;

  /// Usually derived from the extension; pass it explicitly when the picker
  /// already knows better.
  final SourceType? sourceType;

  final String? displayName;
  final Duration? duration;
  final String? createdBy;
}
