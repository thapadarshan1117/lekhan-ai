import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/sync/conflict_resolver.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_request_bus.dart';
import 'package:lekhan_ai/core/sync/sync_task_builder.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/local/chapter_local_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/remote/chapter_remote_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  ChapterRepositoryImpl({
    required this.local,
    required this.remote,
    required this.queue,
    required this.requestBus,
    required this.bookLocal,
    ConflictResolver? conflictResolver,
  }) : _conflicts = conflictResolver ?? const ConflictResolver();

  final ChapterLocalDataSource local;
  final ChapterRemoteDataSource remote;
  final SyncQueue queue;
  final SyncRequestBus requestBus;

  /// Used to translate a local parent id into the remote id the API expects.
  final BookLocalDataSource bookLocal;

  final ConflictResolver _conflicts;

  static const String _identifier = 'ChapterRepositoryImpl';

  @override
  Future<Either<AppException, List<Chapter>>> getChapters({
    String? bookId,
    bool forceRefresh = false,
  }) async {
    final Either<AppException, List<ChapterModel>> cached = await _readCache(
      bookId,
    );
    final List<ChapterModel> cachedItems = cached.valuesOrEmpty;

    if (!forceRefresh && cachedItems.isNotEmpty) {
      return Right<AppException, List<Chapter>>(_asEntities(cachedItems));
    }

    final Either<AppException, List<ChapterModel>> fetched = await _fetchRemote(
      bookId,
    );
    final List<ChapterModel>? remoteItems = fetched.valueOrNull;

    if (remoteItems == null) {
      if (cachedItems.isNotEmpty)
        return Right<AppException, List<Chapter>>(_asEntities(cachedItems));
      return Left<AppException, List<Chapter>>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown chapter fetch failure'),
              identifier: '$_identifier.getChapters',
            ),
      );
    }

    final List<ChapterModel> merged = await _mergeIntoCache(remoteItems);
    return Right<AppException, List<Chapter>>(_asEntities(merged));
  }

  @override
  Future<Either<AppException, Chapter>> getChapter(String id) async {
    final Either<AppException, ChapterModel?> cached = await local.getChapter(
      id,
    );
    final ChapterModel? item = cached.valueOrNull;

    if (item != null && (!item.isDirty || item.remoteId == null)) {
      return Right<AppException, Chapter>(item);
    }

    final Either<AppException, ChapterModel> fetched = await remote
        .fetchChapter(item?.remoteId ?? id);
    final ChapterModel? remoteItem = fetched.valueOrNull;

    if (remoteItem == null) {
      if (item != null) return Right<AppException, Chapter>(item);
      return Left<AppException, Chapter>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown chapter failure'),
              identifier: '$_identifier.getChapter',
            ),
      );
    }

    if (item != null) {
      final ConflictResult resolution = _conflicts.resolve(
        local: item.toJson(),
        remote: remoteItem.toJson(),
      );
      if (resolution.shouldPushLocal) return Right<AppException, Chapter>(item);
      if (resolution.shouldDeleteLocal) {
        await local.delete(item.id);
        return Right<AppException, Chapter>(remoteItem.markSynced());
      }
    }

    final ChapterModel stored = remoteItem.markSynced();
    await local.save(stored);
    return Right<AppException, Chapter>(stored);
  }

  @override
  Stream<List<Chapter>> watchChapters({String? bookId}) {
    return local
        .watchChapters(bookId: bookId)
        .map((List<ChapterModel> items) => _asEntities(items));
  }

  @override
  Future<Either<AppException, List<Chapter>>> refreshChapters({
    String? bookId,
  }) {
    return getChapters(bookId: bookId, forceRefresh: true);
  }

  @override
  Future<Either<AppException, Chapter>> refreshChapter(String id) async {
    final Either<AppException, ChapterModel?> cached = await local.getChapter(
      id,
    );
    final ChapterModel? item = cached.valueOrNull;

    final Either<AppException, ChapterModel> fetched = await remote
        .fetchChapter(item?.remoteId ?? id);
    final ChapterModel? remoteItem = fetched.valueOrNull;

    if (remoteItem == null) {
      return Left<AppException, Chapter>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown chapter failure'),
              identifier: '$_identifier.refreshChapter',
            ),
      );
    }

    if (item != null) {
      final ConflictResult resolution = _conflicts.resolve(
        local: item.toJson(),
        remote: remoteItem.toJson(),
      );
      if (resolution.shouldPushLocal) return Right<AppException, Chapter>(item);
      if (resolution.shouldDeleteLocal) {
        await local.delete(item.id);
      }
    }

    final ChapterModel stored = remoteItem.markSynced();
    await local.save(stored);
    return Right<AppException, Chapter>(stored);
  }

  @override
  Future<Either<AppException, Chapter>> saveLocal(Chapter chapter) async {
    final ChapterModel model = ChapterModel.fromEntity(chapter).markDirty();

    final Either<AppException, ChapterModel> saved = await local.save(model);
    final ChapterModel? stored = saved.valueOrNull;

    if (stored == null) {
      return Left<AppException, Chapter>(
        saved.errorOrNull ??
            FailureMapper.local(
              StateError('Chapter could not be saved'),
              identifier: '$_identifier.saveLocal',
              statusCode: LocalErrorCodes.databaseFailure,
            ),
      );
    }

    final Map<String, dynamic> data = stored.toRemoteJson();
    // The sync reference resolver translates the local parent id when online.
    data['book_id'] = stored.bookId;

    await queue.enqueue(
      SyncTaskBuilder.metadata(
        entityType: SyncEntityType.chapter,
        entityId: stored.id,
        operation: stored.remoteId == null
            ? SyncOperation.create
            : SyncOperation.update,
        remoteId: stored.remoteId,
        payload: <String, dynamic>{
          'entity': SyncEntityType.chapter.value,
          'data': data,
        },
      ),
    );

    requestBus.request();
    return Right<AppException, Chapter>(stored);
  }

  @override
  Future<Either<AppException, Chapter>> markSynced(
    String id, {
    String? remoteId,
  }) async {
    final Either<AppException, ChapterModel?> cached = await local.getChapter(
      id,
    );
    final ChapterModel? item = cached.valueOrNull;

    if (item == null) {
      return Left<AppException, Chapter>(
        FailureMapper.local(
          StateError('Chapter $id not found in the local store'),
          identifier: '$_identifier.markSynced',
          message: 'The chapter could not be found on this device.',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    final ChapterModel synced = item.markSynced(remoteId: remoteId);
    final Either<AppException, ChapterModel> saved = await local.save(synced);

    return saved.fold(
      (AppException exception) => Left<AppException, Chapter>(exception),
      (ChapterModel value) => Right<AppException, Chapter>(value),
    );
  }

  @override
  Future<Either<AppException, Chapter>> updateProgress({
    required String chapterId,
    required int currentWords,
    ChapterStatus? status,
  }) async {
    final Either<AppException, ChapterModel?> cached = await local.getChapter(
      chapterId,
    );
    final ChapterModel? chapter = cached.valueOrNull;

    if (chapter == null) {
      return Left<AppException, Chapter>(
        FailureMapper.local(
          StateError('Chapter $chapterId not found in the local store'),
          identifier: '$_identifier.updateProgress',
          message: 'The chapter could not be found on this device.',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    final ChapterModel updated = chapter.markDirty().copyWith(
      currentWords: currentWords,
      status: status ?? chapter.status,
    );

    final Either<AppException, ChapterModel> saved = await local.save(updated);
    if (saved.isFailure) {
      return Left<AppException, Chapter>(
        saved.errorOrNull ??
            FailureMapper.local(
              StateError('Chapter progress could not be saved'),
              identifier: '$_identifier.updateProgress',
              statusCode: LocalErrorCodes.databaseFailure,
            ),
      );
    }

    await queue.enqueue(
      SyncTaskBuilder.progress(
        chapterId: updated.id,
        currentWords: currentWords,
        remoteId: updated.remoteId,
      ),
    );

    requestBus.request();
    return Right<AppException, Chapter>(updated);
  }

  @override
  Future<Either<AppException, Chapter>> updateSourceCounts({
    required String chapterId,
    required int sourceCount,
    required int pendingSourceCount,
  }) async {
    final Either<AppException, ChapterModel?> cached = await local.getChapter(
      chapterId,
    );
    final ChapterModel? chapter = cached.valueOrNull;

    if (chapter == null) {
      return Left<AppException, Chapter>(
        FailureMapper.local(
          StateError('Chapter $chapterId not found in the local store'),
          identifier: '$_identifier.updateSourceCounts',
          message: 'The chapter could not be found on this device.',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    final ChapterModel updated = chapter.withCounts(
      sourceCount: sourceCount,
      pendingSourceCount: pendingSourceCount,
      at: DateTime.now(),
    );

    final Either<AppException, ChapterModel> saved = await local.save(updated);
    return saved.fold(
      (AppException exception) => Left<AppException, Chapter>(exception),
      (ChapterModel value) => Right<AppException, Chapter>(value),
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  List<Chapter> _asEntities(List<ChapterModel> items) =>
      items.map<Chapter>((ChapterModel item) => item).toList();

  Future<Either<AppException, List<ChapterModel>>> _readCache(String? bookId) {
    if (bookId == null || bookId.isEmpty) {
      return local.getChapters();
    }
    return local.getChaptersByBook(bookId);
  }

  Future<String?> _remoteParentId(String localBookId) async {
    final Either<AppException, BookModel?> result = await bookLocal.getBook(
      localBookId,
    );

    final BookModel? book = result.valueOrNull;

    if (book == null) return null;

    final String? remoteId = book.remoteId;

    if (remoteId == null || remoteId.isEmpty) {
      return null;
    }

    return remoteId;
  }

  Future<Either<AppException, List<ChapterModel>>> _fetchRemote(
    String? bookId,
  ) async {
    String? parentRemoteId;
    if (bookId != null && bookId.isNotEmpty) {
      parentRemoteId = await _remoteParentId(bookId);
      if (parentRemoteId == null) {
        // The parent has never been online, so the server cannot know its
        // children yet: the local cache is the only valid answer.
        return await _readCache(bookId);
      }
    }
    return remote.fetchChapters(parentRemoteId: parentRemoteId);
  }

  Future<List<ChapterModel>> _mergeIntoCache(
    List<ChapterModel> remoteItems,
  ) async {
    final Either<AppException, List<ChapterModel>> cachedResult = await local
        .getChapters();
    final List<ChapterModel> cached = cachedResult.valuesOrEmpty;

    final Map<String, ChapterModel> byRemoteId = <String, ChapterModel>{
      for (final ChapterModel item in cached)
        if (item.remoteId != null && item.remoteId!.isNotEmpty)
          item.remoteId!: item,
    };

    final List<ChapterModel> toStore = <ChapterModel>[];

    for (final ChapterModel remoteItem in remoteItems) {
      final ChapterModel? existing = byRemoteId[remoteItem.remoteId];

      if (existing == null) {
        toStore.add(remoteItem.markSynced());
        continue;
      }

      final ConflictResult resolution = _conflicts.resolve(
        local: existing.toJson(),
        remote: remoteItem.toJson(),
      );

      if (resolution.shouldApplyRemote) {
        toStore.add(remoteItem.markSynced());
      } else if (resolution.shouldDeleteLocal) {
        await local.delete(existing.id);
      }
    }

    if (toStore.isNotEmpty) {
      await local.saveAll(toStore);
    }

    final Either<AppException, List<ChapterModel>> refreshed = await local
        .getChapters();
    return refreshed.valuesOrEmpty.isEmpty ? toStore : refreshed.valuesOrEmpty;
  }
}
