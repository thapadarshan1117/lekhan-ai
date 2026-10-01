import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Single source of truth for chapters: local store first, backend when
/// it is reachable, and an explicit conflict rule in between.
abstract class ChapterRepository {
  Future<Either<AppException, List<Chapter>>> getChapters({
    String? bookId,
    bool forceRefresh,
  });

  /// Reads only the local cache, without consulting any remote datasource.
  Future<Either<AppException, List<Chapter>>> getCachedChapters({
    String? bookId,
  });

  Future<Either<AppException, Chapter>> getChapter(String id);

  Stream<List<Chapter>> watchChapters({String? bookId});

  Future<Either<AppException, List<Chapter>>> refreshChapters({
    String? bookId,
  });

  /// Persists a local edit and queues it for the server.
  Future<Either<AppException, Chapter>> saveLocal(Chapter chapter);

  /// Removes a chapter locally and queues its server-side tombstone when needed.
  Future<Either<AppException, bool>> deleteLocal(String id);

  Future<Either<AppException, Chapter>> markSynced(
    String id, {
    String? remoteId,
  });

  /// Pulls the server copy of one record into the local store.
  Future<Either<AppException, Chapter>> refreshChapter(String id);

  /// Word count / status progress, saved locally and queued on the light
  /// `progress` channel.
  Future<Either<AppException, Chapter>> updateProgress({
    required String chapterId,
    required int currentWords,
    ChapterStatus? status,
  });

  /// Recomputed after sources are added or removed.
  Future<Either<AppException, Chapter>> updateSourceCounts({
    required String chapterId,
    required int sourceCount,
    required int pendingSourceCount,
  });
}
