import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/sync/conflict_resolver.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/local/chapter_local_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/local/chapter_source_local_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_entity_applier.dart';

/// Applies one server change to Hive while retaining device-local ids and
/// unsent edits. Parent references in the API are remote ids; the local model
/// graph continues to use its local ids.
class SyncPullApplier {
  const SyncPullApplier({
    required this.projectLocal,
    required this.bookLocal,
    required this.chapterLocal,
    required this.sourceLocal,
    required this.entityApplier,
    required this.conflicts,
  });

  final ProjectLocalDataSource projectLocal;
  final BookLocalDataSource bookLocal;
  final ChapterLocalDataSource chapterLocal;
  final ChapterSourceLocalDataSource sourceLocal;
  final SyncEntityApplier entityApplier;
  final ConflictResolver conflicts;

  /// [change] is the sync envelope; its record may be in `payload`, `data`, or
  /// inline beside `entity_type` / `remote_id`.
  Future<void> apply(Map<String, dynamic> change) async {
    final SyncEntityType? type = _entityType(
      change['entity_type'] ??
          change['entityType'] ??
          change['entity'] ??
          change['resource_type'] ??
          change['type'],
    );
    if (type == null) return;

    final Map<String, dynamic> remote = RemoteJsonUtils.record(
      change['payload'] ?? change['data'] ?? change['record'] ?? change,
    );
    final String remoteId = RemoteJsonUtils.remoteId(<String, dynamic>{
      ...change,
      ...remote,
    });
    if (remoteId.isEmpty) return;

    final String operation = JsonUtils.asString(
      change['operation'] ?? change['op'] ?? change['action'],
    ).trim().toLowerCase();
    final bool deleted = operation == SyncOperation.delete.value ||
        operation == 'deleted' ||
        JsonUtils.asBool(change['is_deleted'] ?? remote['is_deleted']);
    if (deleted) {
      await entityApplier.applyPullDelete(
        entityType: type,
        remoteId: remoteId,
      );
      return;
    }

    final DateTime now = DateTime.now();
    final Map<String, dynamic> data = RemoteJsonUtils.withRemoteIdentity(
      remote,
      id: remoteId,
    );
    data['remote_id'] = remoteId;
    data['created_at'] ??= change['created_at'] ?? change['createdAt'];
    data['updated_at'] ??= change['updated_at'] ??
        change['updatedAt'] ?? change['modified_at'] ?? change['timestamp'];
    data['last_synced_at'] = now.toIso8601String();
    data['is_dirty'] = false;
    data['is_deleted'] = false;

    switch (type) {
      case SyncEntityType.project:
        await _applyProject(remoteId, data);
        return;
      case SyncEntityType.book:
        await _applyBook(remoteId, data);
        return;
      case SyncEntityType.chapter:
      case SyncEntityType.progress:
        await _applyChapter(remoteId, data);
        return;
      case SyncEntityType.chapterSource:
      case SyncEntityType.uploadSession:
        await _applySource(remoteId, data);
        return;
    }
  }

  Future<void> _applyProject(
    String remoteId,
    Map<String, dynamic> data,
  ) async {
    final ProjectModel? existing =
        (await projectLocal.getProjectByRemoteId(remoteId)).valueOrNull;
    final ProjectModel candidate = ProjectModel.fromJson(<String, dynamic>{
      ...data,
      'id': existing?.id ?? IdGenerator.projectId(),
      'remote_id': remoteId,
      'name': data['name'] ?? data['title'],
      'is_dirty': false,
      'is_deleted': false,
    });
    if (!_acceptRemote(existing?.toJson(), candidate.toJson())) return;
    await projectLocal.save(candidate);
  }

  Future<void> _applyBook(
    String remoteId,
    Map<String, dynamic> data,
  ) async {
    final BookModel? existing =
        (await bookLocal.getBookByRemoteId(remoteId)).valueOrNull;
    final String projectReference = _referenceId(
      data['project_id'] ?? data['project'] ?? existing?.projectId,
    );
    final String projectId = await _localProjectId(projectReference);
    final BookModel candidate = BookModel.fromJson(<String, dynamic>{
      ...data,
      'id': existing?.id ?? IdGenerator.bookId(),
      'remote_id': remoteId,
      'project_id': projectId,
      'title': data['title'] ?? data['name'],
      'is_dirty': false,
      'is_deleted': false,
    });
    if (!_acceptRemote(existing?.toJson(), candidate.toJson())) return;
    await bookLocal.save(candidate);
  }

  Future<void> _applyChapter(
    String remoteId,
    Map<String, dynamic> data,
  ) async {
    final ChapterModel? existing =
        (await chapterLocal.getChapterByRemoteId(remoteId)).valueOrNull;
    final String bookReference = _referenceId(
      data['book_id'] ?? data['book'] ?? existing?.bookId,
    );
    final String bookId = await _localBookId(bookReference);
    final BookModel? parent = (await bookLocal.getBook(bookId)).valueOrNull;
    final String projectId = _referenceId(
      data['project_id'] ?? data['project'] ?? parent?.projectId,
    );
    final ChapterModel candidate = ChapterModel.fromJson(<String, dynamic>{
      ...data,
      'id': existing?.id ?? IdGenerator.chapterId(),
      'remote_id': remoteId,
      'book_id': bookId,
      'project_id': await _localProjectId(projectId),
      'number': data['number'] ?? data['order'] ?? data['chapter_number'],
      'title': data['title'] ?? data['name'],
      'is_dirty': false,
      'is_deleted': false,
    });
    if (!_acceptRemote(existing?.toJson(), candidate.toJson())) return;
    await chapterLocal.save(candidate);
  }

  Future<void> _applySource(
    String remoteId,
    Map<String, dynamic> data,
  ) async {
    final ChapterSourceModel? existing =
        (await sourceLocal.getSourceByRemoteId(remoteId)).valueOrNull;
    final String chapterReference = _referenceId(
      data['chapter_id'] ?? data['chapter'] ?? existing?.chapterId,
    );
    final String chapterId = await _localChapterId(chapterReference);
    final ChapterModel? chapter =
        (await chapterLocal.getChapter(chapterId)).valueOrNull;
    final String bookReference = _referenceId(
      data['book_id'] ?? data['book'] ?? chapter?.bookId ?? existing?.bookId,
    );
    final String bookId = await _localBookId(bookReference);
    final BookModel? book = (await bookLocal.getBook(bookId)).valueOrNull;
    final String projectReference = _referenceId(
      data['project_id'] ?? data['project'] ?? book?.projectId ?? existing?.projectId,
    );
    final Map<String, dynamic> sourceData = <String, dynamic>{
      ...data,
      'id': existing?.id ?? IdGenerator.sourceId(),
      'remote_id': remoteId,
      'chapter_id': chapterId,
      'book_id': bookId,
      'project_id': await _localProjectId(projectReference),
      'name': data['name'] ?? data['title'] ?? 'Source file',
      'local_path': existing?.localPath ?? '',
      'file_size': data['file_size'] ?? data['size'] ?? data['size_bytes'],
      // A record pulled from the server already exists remotely. Bytes remain
      // app-owned locally only when this device uploaded them.
      'upload_status': data['upload_status'] ?? 'uploaded',
      'is_dirty': false,
      'is_deleted': false,
    };
    final ChapterSourceModel candidate =
        ChapterSourceModel.fromJson(sourceData);
    if (!_acceptRemote(existing?.toJson(), candidate.toJson())) return;

    // A pull must not overwrite local upload progress/path on an existing
    // source, even when its metadata came from a newer server revision.
    final ChapterSourceModel merged = existing == null
        ? candidate
        : candidate.copyWith(
            localPath: existing.localPath,
            uploadStatus: existing.uploadStatus,
            uploadProgress: existing.uploadProgress,
            remoteFileId: candidate.remoteFileId ?? existing.remoteFileId,
            driveFileId: candidate.driveFileId ?? existing.driveFileId,
          );
    await sourceLocal.save(merged);
  }

  bool _acceptRemote(
    Map<String, dynamic>? local,
    Map<String, dynamic> remote,
  ) {
    if (local == null) return true;
    final ConflictResult result = conflicts.resolve(local: local, remote: remote);
    return result.shouldApplyRemote;
  }

  Future<String> _localProjectId(String reference) async {
    if (reference.isEmpty) return '';
    final ProjectModel? byRemote =
        (await projectLocal.getProjectByRemoteId(reference)).valueOrNull;
    if (byRemote != null) return byRemote.id;
    final ProjectModel? byLocal =
        (await projectLocal.getProject(reference)).valueOrNull;
    return byLocal?.id ?? reference;
  }

  Future<String> _localBookId(String reference) async {
    if (reference.isEmpty) return '';
    final BookModel? byRemote =
        (await bookLocal.getBookByRemoteId(reference)).valueOrNull;
    if (byRemote != null) return byRemote.id;
    final BookModel? byLocal = (await bookLocal.getBook(reference)).valueOrNull;
    return byLocal?.id ?? reference;
  }

  Future<String> _localChapterId(String reference) async {
    if (reference.isEmpty) return '';
    final ChapterModel? byRemote =
        (await chapterLocal.getChapterByRemoteId(reference)).valueOrNull;
    if (byRemote != null) return byRemote.id;
    final ChapterModel? byLocal =
        (await chapterLocal.getChapter(reference)).valueOrNull;
    return byLocal?.id ?? reference;
  }

  static String _referenceId(dynamic value) {
    if (value is Map) return RemoteJsonUtils.remoteId(JsonUtils.asMap(value));
    return JsonUtils.asString(value);
  }

  static SyncEntityType? _entityType(dynamic value) {
    final String raw = value is Map
        ? JsonUtils.asString(
            JsonUtils.asMap(value)['type'] ?? JsonUtils.asMap(value)['name'],
          )
        : JsonUtils.asString(value);
    final String normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'project':
      case 'projects':
        return SyncEntityType.project;
      case 'book':
      case 'books':
        return SyncEntityType.book;
      case 'chapter':
      case 'chapters':
        return SyncEntityType.chapter;
      case 'chapter_source':
      case 'chapter-source':
      case 'source':
      case 'sources':
        return SyncEntityType.chapterSource;
      case 'progress':
        return SyncEntityType.progress;
      default:
        return null;
    }
  }
}
