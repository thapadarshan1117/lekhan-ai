import 'dart:developer';

import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/local/chapter_local_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/local/chapter_source_local_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';

/// Writes the server's verdict back into the local store.
///
/// This is the "mark synced" half of the push: once the backend accepts a
/// change it returns the record's remote id, and that id has to land on the
/// local record (and clear `is_dirty`) before the queue item is completed.
class SyncEntityApplier {
  const SyncEntityApplier({
    required this.projectLocal,
    required this.bookLocal,
    required this.chapterLocal,
    required this.sourceLocal,
  });

  final ProjectLocalDataSource projectLocal;
  final BookLocalDataSource bookLocal;
  final ChapterLocalDataSource chapterLocal;
  final ChapterSourceLocalDataSource sourceLocal;

  Future<void> markSynced({
    required SyncEntityType entityType,
    required String entityId,
    String? remoteId,
  }) async {
    switch (entityType) {
      case SyncEntityType.project:
        final ProjectModel? project =
            (await projectLocal.getProject(entityId)).valueOrNull;
        if (project != null) {
          await projectLocal.save(project.markSynced(remoteId: remoteId));
        }
        return;

      case SyncEntityType.book:
        final BookModel? book = (await bookLocal.getBook(entityId)).valueOrNull;
        if (book != null) {
          await bookLocal.save(book.markSynced(remoteId: remoteId));
        }
        return;

      case SyncEntityType.chapter:
      case SyncEntityType.progress:
        final ChapterModel? chapter =
            (await chapterLocal.getChapter(entityId)).valueOrNull;
        if (chapter != null) {
          await chapterLocal.save(chapter.markSynced(remoteId: remoteId));
        }
        return;

      case SyncEntityType.chapterSource:
      case SyncEntityType.uploadSession:
        final ChapterSourceModel? source =
            (await sourceLocal.getSource(entityId)).valueOrNull;
        if (source != null) {
          await sourceLocal.save(
            source.markSynced(remoteId: remoteId).copyWith(isDirty: false),
          );
        }
        return;
    }
  }

  /// A delete the server accepted is now safe to apply locally.
  Future<void> applyRemoteDelete({
    required SyncEntityType entityType,
    required String entityId,
  }) async {
    switch (entityType) {
      case SyncEntityType.project:
        await projectLocal.delete(entityId);
        return;
      case SyncEntityType.book:
        await bookLocal.delete(entityId);
        return;
      case SyncEntityType.chapter:
      case SyncEntityType.progress:
        await chapterLocal.delete(entityId);
        return;
      case SyncEntityType.chapterSource:
      case SyncEntityType.uploadSession:
        await sourceLocal.delete(entityId);
        return;
    }
  }

  /// Records a remote delete that arrived during a pull.
  Future<void> applyPullDelete({
    required SyncEntityType entityType,
    required String remoteId,
  }) async {
    try {
      switch (entityType) {
        case SyncEntityType.project:
          final ProjectModel? project =
              (await projectLocal.getProjectByRemoteId(remoteId)).valueOrNull;
          if (project != null) await projectLocal.delete(project.id);
          return;
        case SyncEntityType.book:
          final BookModel? book =
              (await bookLocal.getBookByRemoteId(remoteId)).valueOrNull;
          if (book != null) await bookLocal.delete(book.id);
          return;
        case SyncEntityType.chapter:
        case SyncEntityType.progress:
          final ChapterModel? chapter =
              (await chapterLocal.getChapterByRemoteId(remoteId)).valueOrNull;
          if (chapter != null) await chapterLocal.delete(chapter.id);
          return;
        case SyncEntityType.chapterSource:
        case SyncEntityType.uploadSession:
          final ChapterSourceModel? source =
              (await sourceLocal.getSourceByRemoteId(remoteId)).valueOrNull;
          if (source != null) await sourceLocal.delete(source.id);
          return;
      }
    } catch (error) {
      log('SyncEntityApplier.applyPullDelete failed: $error');
    }
  }
}
