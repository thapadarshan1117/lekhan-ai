import 'dart:io';

import 'package:lekhan_ai/core/enums/processing_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/storage/storage_manager.dart';
import 'package:lekhan_ai/core/sync/conflict_resolver.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_request_bus.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/sync/sync_task_builder.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/file_utils.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/local/chapter_source_local_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/remote/chapter_source_remote_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class ChapterSourceRepositoryImpl implements ChapterSourceRepository {
  ChapterSourceRepositoryImpl({
    required this.local,
    required this.remote,
    required this.queue,
    required this.requestBus,
    required this.storageManager,
    ConflictResolver? conflictResolver,
  }) : _conflicts = conflictResolver ?? const ConflictResolver();

  final ChapterSourceLocalDataSource local;
  final ChapterSourceRemoteDataSource remote;
  final SyncQueue queue;
  final SyncRequestBus requestBus;
  final StorageManager storageManager;
  final ConflictResolver _conflicts;

  static const String _identifier = 'ChapterSourceRepositoryImpl';

  @override
  Future<Either<AppException, List<ChapterSource>>> getSources({
    required String chapterId,
    String? chapterRemoteId,
    bool forceRefresh = false,
  }) async {
    final Either<AppException, List<ChapterSourceModel>> cached =
        await local.getSourcesByChapter(chapterId);
    final List<ChapterSourceModel> cachedItems = cached.valuesOrEmpty;

    final bool canAskServer =
        chapterRemoteId != null && chapterRemoteId.isNotEmpty;

    if (!forceRefresh || !canAskServer) {
      return Right<AppException, List<ChapterSource>>(_asEntities(cachedItems));
    }

    final Either<AppException, List<ChapterSourceModel>> fetched =
        await remote.fetchSources(chapterRemoteId: chapterRemoteId);
    final List<ChapterSourceModel>? remoteItems = fetched.valueOrNull;

    if (remoteItems == null) {
      if (cachedItems.isNotEmpty) {
        return Right<AppException, List<ChapterSource>>(_asEntities(cachedItems));
      }
      return Left<AppException, List<ChapterSource>>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown source fetch failure'),
              identifier: '$_identifier.getSources',
            ),
      );
    }

    await _mergeIntoCache(remoteItems);

    final Either<AppException, List<ChapterSourceModel>> refreshed =
        await local.getSourcesByChapter(chapterId);
    return Right<AppException, List<ChapterSource>>(
      _asEntities(refreshed.valuesOrEmpty),
    );
  }

  @override
  Future<Either<AppException, ChapterSource>> getSource(String id) async {
    final Either<AppException, ChapterSourceModel?> cached =
        await local.getSource(id);
    final ChapterSourceModel? source = cached.valueOrNull;

    if (source == null) {
      return Left<AppException, ChapterSource>(
        FailureMapper.local(
          StateError('Source $id not found'),
          identifier: '$_identifier.getSource',
          message: 'This source is no longer available on this device.',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    return Right<AppException, ChapterSource>(source);
  }

  @override
  Stream<List<ChapterSource>> watchSources({required String chapterId}) {
    return local
        .watchSources(chapterId: chapterId)
        .map((List<ChapterSourceModel> items) => _asEntities(items));
  }

  @override
  Future<Either<AppException, ChapterSource>> addSource({
    required File file,
    required Chapter chapter,
    SourceType? sourceType,
    String? displayName,
    Duration? duration,
    String? createdBy,
  }) async {
    final SourceType type = sourceType ??
        SourceType.fromExtension(FileUtils.extensionOf(file.path));

    try {
      final StoredFileInfo stored = await storageManager.storeChapterSource(
        source: file,
        projectId: chapter.projectId,
        bookId: chapter.bookId,
        chapterId: chapter.id,
        type: type,
        preferredFileName: displayName,
      );

      return _createRecord(
        stored: stored,
        chapter: chapter,
        sourceType: type,
        displayName: displayName,
        duration: duration,
        createdBy: createdBy,
      );
    } on AppException catch (error) {
      return Left<AppException, ChapterSource>(error);
    } catch (error) {
      return Left<AppException, ChapterSource>(
        FailureMapper.local(
          error,
          identifier: '$_identifier.addSource',
          message: 'The file could not be stored on this device.',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ChapterSource>> addExistingFile({
    required String localPath,
    required Chapter chapter,
    required SourceType sourceType,
    String? displayName,
    Duration? duration,
    String? createdBy,
  }) async {
    try {
      final StoredFileInfo stored = await storageManager.registerRecordingFile(
        localPath: localPath,
        type: sourceType,
      );

      return _createRecord(
        stored: stored,
        chapter: chapter,
        sourceType: sourceType,
        displayName: displayName,
        duration: duration,
        createdBy: createdBy,
      );
    } on AppException catch (error) {
      return Left<AppException, ChapterSource>(error);
    } catch (error) {
      return Left<AppException, ChapterSource>(
        FailureMapper.local(
          error,
          identifier: '$_identifier.addExistingFile',
          message: 'The recording could not be registered.',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> deleteSource(String id) async {
    final Either<AppException, ChapterSourceModel?> cached =
        await local.getSource(id);
    final ChapterSourceModel? source = cached.valueOrNull;

    if (source == null) return const Right<AppException, bool>(true);

    // 1. Drop queued work first, so nothing can upload a file that is going
    //    away in the next statement.
    final SyncTask? uploadTask = await queue.findPending(
      entityType: SyncEntityType.chapterSource,
      entityId: id,
    );
    if (uploadTask != null) {
      await queue.remove(uploadTask.id);
    }

    // 2. Remove the bytes.
    await storageManager.deleteFile(source.localPath);

    // 3. Remove the record (or queue its removal when the server knows it).
    if (source.remoteId == null) {
      await local.delete(id);
      return const Right<AppException, bool>(true);
    }

    await local.save(source.copyWith(isDeleted: true));
    await queue.enqueue(
      SyncTaskBuilder.metadata(
        entityType: SyncEntityType.chapterSource,
        entityId: source.id,
        operation: SyncOperation.delete,
        remoteId: source.remoteId,
      ),
    );
    requestBus.request();
    return const Right<AppException, bool>(true);
  }

  @override
  Future<Either<AppException, ChapterSource>> retryUpload(String id) async {
    final Either<AppException, ChapterSourceModel?> cached =
        await local.getSource(id);
    final ChapterSourceModel? source = cached.valueOrNull;

    if (source == null) {
      return Left<AppException, ChapterSource>(
        FailureMapper.local(
          StateError('Source $id not found'),
          identifier: '$_identifier.retryUpload',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    if (!await FileUtils.exists(source.localPath)) {
      // The bytes are gone (uninstall, cleared storage). Say so instead of
      // retrying something that can never succeed.
      final ChapterSourceModel missing = source.withUploadState(
        uploadStatus: UploadStatus.failed,
        errorMessage: 'The file is no longer on this device.',
      );
      await local.save(missing);
      return Right<AppException, ChapterSource>(missing);
    }

    final ChapterSourceModel queued = source.copyWith(
      uploadStatus: UploadStatus.pending,
      uploadProgress: 0,
    );
    await local.save(queued);

    await queue.enqueue(
      SyncTaskBuilder.upload(
        sourceId: queued.id,
        chapterId: queued.chapterId,
        sourceName: queued.name,
        sourceType: queued.sourceType,
        sizeBytes: queued.fileSize,
        remoteId: queued.remoteId,
        remoteFileId: queued.remoteFileId,
      ),
    );
    requestBus.request();
    return Right<AppException, ChapterSource>(queued);
  }

  @override
  Future<Either<AppException, ChapterSource>> updateUploadStatus(
    String id, {
    UploadStatus? uploadStatus,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    String? remoteId,
    String? remoteFileId,
    String? driveFileId,
  }) async {
    final Either<AppException, ChapterSourceModel?> cached =
        await local.getSource(id);
    final ChapterSourceModel? source = cached.valueOrNull;

    if (source == null) {
      return Left<AppException, ChapterSource>(
        FailureMapper.local(
          StateError('Source $id not found'),
          identifier: '$_identifier.updateUploadStatus',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    final ChapterSourceModel updated = source.withUploadState(
      uploadStatus: uploadStatus,
      uploadProgress: uploadProgress,
      errorMessage: errorMessage,
      clearError: clearError,
      remoteId: remoteId,
      remoteFileId: remoteFileId,
      driveFileId: driveFileId,
    );

    final Either<AppException, ChapterSourceModel> saved =
        await local.save(updated);
    return saved.fold(
      (AppException exception) => Left<AppException, ChapterSource>(exception),
      (ChapterSourceModel value) => Right<AppException, ChapterSource>(value),
    );
  }

  @override
  Future<Either<AppException, ChapterSource>> updateProcessingStatus(
    String id,
    ProcessingStatus status,
  ) async {
    final Either<AppException, ChapterSourceModel?> cached =
        await local.getSource(id);
    final ChapterSourceModel? source = cached.valueOrNull;

    if (source == null) {
      return Left<AppException, ChapterSource>(
        FailureMapper.local(
          StateError('Source $id not found'),
          identifier: '$_identifier.updateProcessingStatus',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    final ChapterSourceModel updated = source.copyWith(processingStatus: status);
    final Either<AppException, ChapterSourceModel> saved =
        await local.save(updated);
    return saved.fold(
      (AppException exception) => Left<AppException, ChapterSource>(exception),
      (ChapterSourceModel value) => Right<AppException, ChapterSource>(value),
    );
  }

  @override
  Future<Either<AppException, int>> pendingCount(String chapterId) {
    return local.pendingCount(chapterId);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<Either<AppException, ChapterSource>> _createRecord({
    required StoredFileInfo stored,
    required Chapter chapter,
    required SourceType sourceType,
    String? displayName,
    Duration? duration,
    String? createdBy,
  }) async {
    final ChapterSourceModel record = ChapterSourceModel.fromStoredFile(
      id: IdGenerator.sourceId(),
      chapterId: chapter.id,
      bookId: chapter.bookId,
      projectId: chapter.projectId,
      name: displayName ?? stored.fileName,
      localPath: stored.localPath,
      mimeType: stored.mimeType,
      extension: stored.extension,
      fileSize: stored.sizeBytes,
      checksum: stored.checksum,
      sourceType: sourceType,
      duration: duration,
      createdBy: createdBy,
    );

    final Either<AppException, ChapterSourceModel> saved = await local.save(record);
    final ChapterSourceModel? persisted = saved.valueOrNull;

    if (persisted == null) {
      return Left<AppException, ChapterSource>(
        saved.errorOrNull ??
            FailureMapper.local(
              StateError('Source record could not be saved'),
              identifier: '$_identifier._createRecord',
              statusCode: LocalErrorCodes.databaseFailure,
            ),
      );
    }

    // Metadata first (the backend creates the record and the Drive location),
    // bytes second. Their priorities (P0 vs P1..P4) make the scheduler keep
    // that order even when both are queued at once.
    await queue.enqueue(
      SyncTaskBuilder.metadata(
        entityType: SyncEntityType.chapterSource,
        entityId: persisted.id,
        operation: SyncOperation.create,
        payload: <String, dynamic>{
          'entity': SyncEntityType.chapterSource.value,
          'data': persisted.toMetadataJson(),
        },
      ),
    );

    await queue.enqueue(
      SyncTaskBuilder.upload(
        sourceId: persisted.id,
        chapterId: persisted.chapterId,
        sourceName: persisted.name,
        sourceType: persisted.sourceType,
        sizeBytes: persisted.fileSize,
      ),
    );

    requestBus.request();
    return Right<AppException, ChapterSource>(persisted);
  }

  Future<void> _mergeIntoCache(List<ChapterSourceModel> remoteItems) async {
    final Either<AppException, List<ChapterSourceModel>> cachedResult =
        await local.getSources();
    final List<ChapterSourceModel> cached = cachedResult.valuesOrEmpty;

    final Map<String, ChapterSourceModel> byRemoteId =
        <String, ChapterSourceModel>{
      for (final ChapterSourceModel item in cached)
        if (item.remoteId != null && item.remoteId!.isNotEmpty)
          item.remoteId!: item,
    };

    final List<ChapterSourceModel> toStore = <ChapterSourceModel>[];

    for (final ChapterSourceModel remoteItem in remoteItems) {
      final ChapterSourceModel? existing = byRemoteId[remoteItem.remoteId];

      if (existing == null) {
        toStore.add(remoteItem.markSynced());
        continue;
      }

      final ConflictResult resolution = _conflicts.resolve(
        local: existing.toJson(),
        remote: remoteItem.toJson(),
      );

      if (resolution.shouldApplyRemote) {
        // Server state wins, but the bytes on this device stay ours: keep the
        // local path, the checksum and the resume offset.
        toStore.add(
          remoteItem.markSynced().copyWith(
                localPath: existing.localPath,
                checksum: existing.checksum,
                uploadProgress: existing.uploadProgress,
              ),
        );
      } else if (resolution.shouldDeleteLocal) {
        await local.delete(existing.id);
      }
    }

    if (toStore.isNotEmpty) {
      await local.saveAll(toStore);
    }
  }

  List<ChapterSource> _asEntities(List<ChapterSourceModel> items) =>
      items.map<ChapterSource>((ChapterSourceModel item) => item).toList();
}
