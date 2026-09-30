import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/local/chapter_local_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/local/chapter_source_local_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Turns the local references inside a queued change into the ids the server
/// understands.
///
/// The device creates records offline, so a chapter refers to a book that may
/// itself still be queued. The server, however, needs `book_id: <remote id>`.
/// Doing that translation here keeps every repository free of cross-feature
/// knowledge, and turns "parent not pushed yet" into a normal, retryable
/// condition instead of a failed upload.
class SyncReferenceResolver {
  const SyncReferenceResolver({
    required this.projectLocal,
    required this.bookLocal,
    required this.chapterLocal,
    required this.sourceLocal,
  });

  final ProjectLocalDataSource projectLocal;
  final BookLocalDataSource bookLocal;
  final ChapterLocalDataSource chapterLocal;
  final ChapterSourceLocalDataSource sourceLocal;

  static const String _identifier = 'SyncReferenceResolver';

  /// The remote id of the record itself (null when it only exists locally).
  Future<String?> selfRemoteId({
    required SyncEntityType entityType,
    required String entityId,
  }) async {
    switch (entityType) {
      case SyncEntityType.project:
        final Either<AppException, ProjectModel?> found =
            await projectLocal.getProject(entityId);
        return found.valueOrNull?.remoteId;
      case SyncEntityType.book:
        final Either<AppException, BookModel?> found =
            await bookLocal.getBook(entityId);
        return found.valueOrNull?.remoteId;
      case SyncEntityType.chapter:
      case SyncEntityType.progress:
        final Either<AppException, ChapterModel?> found =
            await chapterLocal.getChapter(entityId);
        return found.valueOrNull?.remoteId;
      case SyncEntityType.chapterSource:
      case SyncEntityType.uploadSession:
        final Either<AppException, ChapterSourceModel?> found =
            await sourceLocal.getSource(entityId);
        return found.valueOrNull?.remoteId;
    }
  }

  /// Rewrites the parent references of [data] to remote ids.
  ///
  /// Fails with a retryable error while a parent is still waiting in the queue;
  /// the scheduler's priorities put metadata (P0) ahead of bytes, so in practice
  /// the parent is already done by the time a file is uploaded.
  Future<Either<AppException, Map<String, dynamic>>> resolve({
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final Map<String, dynamic> resolved = Map<String, dynamic>.of(data);

    switch (entityType) {
      case SyncEntityType.project:
        return Right<AppException, Map<String, dynamic>>(resolved);

      case SyncEntityType.book:
        final String localProjectId = JsonUtils.asString(resolved['project_id']);
        final String? projectRemoteId = await _projectRemoteId(localProjectId);
        if (projectRemoteId == null) {
          return _pendingParent('project', localProjectId);
        }
        resolved['project_id'] = projectRemoteId;
        return Right<AppException, Map<String, dynamic>>(resolved);

      case SyncEntityType.chapter:
        final String localBookId = JsonUtils.asString(resolved['book_id']);
        final String? bookRemoteId = await _bookRemoteId(localBookId);
        if (bookRemoteId == null) {
          return _pendingParent('book', localBookId);
        }
        resolved['book_id'] = bookRemoteId;
        resolved.remove('project_id');
        return Right<AppException, Map<String, dynamic>>(resolved);

      case SyncEntityType.chapterSource:
      case SyncEntityType.uploadSession:
        final String localChapterId =
            JsonUtils.asString(resolved['chapter_id']);
        final String? chapterRemoteId = await _chapterRemoteId(localChapterId);
        if (chapterRemoteId == null) {
          return _pendingParent('chapter', localChapterId);
        }
        resolved['chapter_id'] = chapterRemoteId;
        resolved.remove('local_path');
        return Right<AppException, Map<String, dynamic>>(resolved);

      case SyncEntityType.progress:
        final String? chapterRemoteId = await _chapterRemoteId(entityId);
        if (chapterRemoteId == null) {
          return _pendingParent('chapter', entityId);
        }
        resolved['chapter_id'] = chapterRemoteId;
        return Right<AppException, Map<String, dynamic>>(resolved);
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<String?> _projectRemoteId(String localId) async {
    if (localId.isEmpty) return null;
    final Either<AppException, ProjectModel?> found =
        await projectLocal.getProject(localId);
    return found.valueOrNull?.remoteId;
  }

  Future<String?> _bookRemoteId(String localId) async {
    if (localId.isEmpty) return null;
    final Either<AppException, BookModel?> found = await bookLocal.getBook(localId);
    return found.valueOrNull?.remoteId;
  }

  Future<String?> _chapterRemoteId(String localId) async {
    if (localId.isEmpty) return null;
    final Either<AppException, ChapterModel?> found =
        await chapterLocal.getChapter(localId);
    return found.valueOrNull?.remoteId;
  }

  Either<AppException, Map<String, dynamic>> _pendingParent(
    String parentName,
    String localId,
  ) {
    return Left<AppException, Map<String, dynamic>>(
      FailureMapper.local(
        StateError('$parentName $localId is not on the server yet'),
        identifier: '$_identifier.resolve.pendingParent',
        message:
            'Waiting for the $parentName to be saved on the server before this change can follow.',
        statusCode: LocalErrorCodes.noConnection,
      ),
    );
  }
}
