import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/sync/conflict_resolver.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_request_bus.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/sync/sync_task_builder.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/datasources/remote/book_remote_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/repositories/book_repository.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({
    required this.local,
    required this.remote,
    required this.queue,
    required this.requestBus,
    required this.projectLocal,
    ConflictResolver? conflictResolver,
  }) : _conflicts = conflictResolver ?? const ConflictResolver();

  final BookLocalDataSource local;
  final BookRemoteDataSource remote;
  final SyncQueue queue;
  final SyncRequestBus requestBus;

  /// Used to translate a local parent id into the remote id the API expects.
  final ProjectLocalDataSource projectLocal;

  final ConflictResolver _conflicts;

  static const String _identifier = 'BookRepositoryImpl';

  @override
  Future<Either<AppException, List<Book>>> getBooks({
    String? projectId,
    bool forceRefresh = false,
  }) async {
    final Either<AppException, List<BookModel>> cached = await _readCache(
      projectId,
    );
    final List<BookModel> cachedItems = cached.valuesOrEmpty;

    if (!forceRefresh && cachedItems.isNotEmpty) {
      return Right<AppException, List<Book>>(_asEntities(cachedItems));
    }

    final Either<AppException, List<BookModel>> fetched =
        await _fetchRemote(projectId);
    final List<BookModel>? remoteItems = fetched.valueOrNull;

    if (remoteItems == null) {
      if (cachedItems.isNotEmpty) return Right<AppException, List<Book>>(_asEntities(cachedItems));
      return Left<AppException, List<Book>>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown book fetch failure'),
              identifier: '$_identifier.getBooks',
            ),
      );
    }

    final List<BookModel> merged = await _mergeIntoCache(remoteItems);
    return Right<AppException, List<Book>>(_asEntities(merged));
  }

  @override
  Future<Either<AppException, Book>> getBook(String id) async {
    final Either<AppException, BookModel?> cached = await local.getBook(id);
    final BookModel? item = cached.valueOrNull;

    if (item != null && (!item.isDirty || item.remoteId == null)) {
      return Right<AppException, Book>(item);
    }

    final Either<AppException, BookModel> fetched =
        await remote.fetchBook(item?.remoteId ?? id);
    final BookModel? remoteItem = fetched.valueOrNull;

    if (remoteItem == null) {
      if (item != null) return Right<AppException, Book>(item);
      return Left<AppException, Book>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown book failure'),
              identifier: '$_identifier.getBook',
            ),
      );
    }

    if (item != null) {
      final ConflictResult resolution = _conflicts.resolve(
        local: item.toJson(),
        remote: remoteItem.toJson(),
      );
      if (resolution.shouldPushLocal) return Right<AppException, Book>(item);
      if (resolution.shouldDeleteLocal) {
        await local.delete(item.id);
        return Right<AppException, Book>(remoteItem.markSynced());
      }
    }

    final BookModel stored = remoteItem.markSynced();
    await local.save(stored);
    return Right<AppException, Book>(stored);
  }

  @override
  Stream<List<Book>> watchBooks({String? projectId}) {
    return local
        .watchBooks(projectId: projectId)
        .map((List<BookModel> items) => _asEntities(items));
  }

  @override
  Future<Either<AppException, List<Book>>> refreshBooks({
    String? projectId,
  }) {
    return getBooks(projectId: projectId, forceRefresh: true);
  }

  @override
  Future<Either<AppException, Book>> refreshBook(String id) async {
    final Either<AppException, BookModel?> cached = await local.getBook(id);
    final BookModel? item = cached.valueOrNull;

    final Either<AppException, BookModel> fetched =
        await remote.fetchBook(item?.remoteId ?? id);
    final BookModel? remoteItem = fetched.valueOrNull;

    if (remoteItem == null) {
      return Left<AppException, Book>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown book failure'),
              identifier: '$_identifier.refreshBook',
            ),
      );
    }

    if (item != null) {
      final ConflictResult resolution = _conflicts.resolve(
        local: item.toJson(),
        remote: remoteItem.toJson(),
      );
      if (resolution.shouldPushLocal) return Right<AppException, Book>(item);
      if (resolution.shouldDeleteLocal) {
        await local.delete(item.id);
      }
    }

    final BookModel stored = remoteItem.markSynced();
    await local.save(stored);
    return Right<AppException, Book>(stored);
  }

  @override
  Future<Either<AppException, Book>> saveLocal(Book book) async {
    final BookModel model = BookModel.fromEntity(book).markDirty();

    final Either<AppException, BookModel> saved = await local.save(model);
    final BookModel? stored = saved.valueOrNull;

    if (stored == null) {
      return Left<AppException, Book>(
        saved.errorOrNull ??
            FailureMapper.local(
              StateError('Book could not be saved'),
              identifier: '$_identifier.saveLocal',
              statusCode: LocalErrorCodes.databaseFailure,
            ),
      );
    }

    final Map<String, dynamic> data = stored.toRemoteJson();
    // Parents are referenced by their *local* id here; the sync layer swaps in
    // the remote id right before the record is pushed.
    data['project_id'] = stored.projectId;

    await queue.enqueue(
      SyncTaskBuilder.metadata(
        entityType: SyncEntityType.book,
        entityId: stored.id,
        operation:
            stored.remoteId == null ? SyncOperation.create : SyncOperation.update,
        remoteId: stored.remoteId,
        payload: <String, dynamic>{
          'entity': SyncEntityType.book.value,
          'data': data,
        },
      ),
    );

    requestBus.request();
    return Right<AppException, Book>(stored);
  }

  @override
  Future<Either<AppException, Book>> markSynced(
    String id, {
    String? remoteId,
  }) async {
    final Either<AppException, BookModel?> cached = await local.getBook(id);
    final BookModel? item = cached.valueOrNull;

    if (item == null) {
      return Left<AppException, Book>(
        FailureMapper.local(
          StateError('Book $id not found in the local store'),
          identifier: '$_identifier.markSynced',
          message: 'The book could not be found on this device.',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    final BookModel synced = item.markSynced(remoteId: remoteId);
    final Either<AppException, BookModel> saved = await local.save(synced);

    return saved.fold(
      (AppException exception) => Left<AppException, Book>(exception),
      (BookModel value) => Right<AppException, Book>(value),
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  List<Book> _asEntities(List<BookModel> items) =>
      items.map<Book>((BookModel item) => item).toList();

  Future<Either<AppException, List<BookModel>>> _readCache(
    String? projectId,
  ) {
    if (projectId == null || projectId.isEmpty) {
      return local.getBooks();
    }
    return local.getBooksByProject(projectId);
  }

  Future<Either<AppException, List<BookModel>>> _fetchRemote(
    String? projectId,
  ) async {
    String? parentRemoteId;
    if (projectId != null && projectId.isNotEmpty) {
      parentRemoteId = await _remoteParentId(projectId);
      if (parentRemoteId == null) {
        // The parent has never been online, so the server cannot know its
        // children yet: the local cache is the only valid answer.
        return await _readCache(projectId);
      }
    }
    return remote.fetchBooks(parentRemoteId: parentRemoteId);
  }

  Future<List<BookModel>> _mergeIntoCache(List<BookModel> remoteItems) async {
    final Either<AppException, List<BookModel>> cachedResult =
        await local.getBooks();
    final List<BookModel> cached = cachedResult.valuesOrEmpty;

    final Map<String, BookModel> byRemoteId = <String, BookModel>{
      for (final BookModel item in cached)
        if (item.remoteId != null && item.remoteId!.isNotEmpty) item.remoteId!: item,
    };

    final List<BookModel> toStore = <BookModel>[];

    for (final BookModel remoteItem in remoteItems) {
      final BookModel? existing = byRemoteId[remoteItem.remoteId];

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

    final Either<AppException, List<BookModel>> refreshed = await local.getBooks();
    return refreshed.valuesOrEmpty.isEmpty ? toStore : refreshed.valuesOrEmpty;
  }

  /// Resolves the local parent id to its remote id, when one exists.
  Future<String?> _remoteParentId(String projectId) async {
    final Either<AppException, ProjectModel?> parent =
        await projectLocal.getProject(projectId);
    return parent.valueOrNull?.remoteId;
  }
}
