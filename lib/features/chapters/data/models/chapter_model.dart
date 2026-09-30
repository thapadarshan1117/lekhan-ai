import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';

/// Serialisation for [Chapter] (local document + API record).
class ChapterModel extends Chapter {
  const ChapterModel({
    required super.id,
    required super.bookId,
    required super.projectId,
    required super.number,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.remoteId,
    super.targetWords,
    super.currentWords,
    super.status,
    super.draftVersion,
    super.driveFolderId,
    super.summary,
    super.sourceCount,
    super.pendingSourceCount,
    super.lastSyncedAt,
    super.isDirty,
    super.isDeleted,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = JsonUtils.asMap(json);
    final DateTime created =
        JsonUtils.asDateTime(data[DatabaseTables.fieldCreatedAt]) ??
            DateTime.now();

    return ChapterModel(
      id: JsonUtils.asString(data[DatabaseTables.fieldId]),
      remoteId: JsonUtils.asStringOrNull(data[DatabaseTables.fieldRemoteId]),
      bookId: JsonUtils.asString(data['book_id']),
      projectId: JsonUtils.asString(data['project_id']),
      number: JsonUtils.asInt(data['number']),
      title: JsonUtils.asString(data['title']),
      summary: JsonUtils.asString(data['summary']),
      targetWords: JsonUtils.asInt(data['target_words']),
      currentWords: JsonUtils.asInt(data['current_words']),
      status: ChapterStatus.fromString(
        JsonUtils.asStringOrNull(data['status']),
      ),
      draftVersion: JsonUtils.asInt(data['draft_version']),
      driveFolderId: JsonUtils.asStringOrNull(
        data[DatabaseTables.fieldDriveFolderId],
      ),
      sourceCount: JsonUtils.asInt(data['source_count']),
      pendingSourceCount: JsonUtils.asInt(data['pending_source_count']),
      createdAt: created,
      updatedAt:
          JsonUtils.asDateTime(data[DatabaseTables.fieldUpdatedAt]) ?? created,
      lastSyncedAt: JsonUtils.asDateTime(data[DatabaseTables.fieldLastSyncedAt]),
      isDirty: JsonUtils.asBool(data[DatabaseTables.fieldIsDirty]),
      isDeleted: JsonUtils.asBool(data[DatabaseTables.fieldIsDeleted]),
    );
  }

  factory ChapterModel.fromEntity(Chapter chapter) {
    return ChapterModel(
      id: chapter.id,
      remoteId: chapter.remoteId,
      bookId: chapter.bookId,
      projectId: chapter.projectId,
      number: chapter.number,
      title: chapter.title,
      summary: chapter.summary,
      targetWords: chapter.targetWords,
      currentWords: chapter.currentWords,
      status: chapter.status,
      draftVersion: chapter.draftVersion,
      driveFolderId: chapter.driveFolderId,
      sourceCount: chapter.sourceCount,
      pendingSourceCount: chapter.pendingSourceCount,
      createdAt: chapter.createdAt,
      updatedAt: chapter.updatedAt,
      lastSyncedAt: chapter.lastSyncedAt,
      isDirty: chapter.isDirty,
      isDeleted: chapter.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DatabaseTables.fieldId: id,
      DatabaseTables.fieldRemoteId: remoteId,
      'book_id': bookId,
      'project_id': projectId,
      'number': number,
      'title': title,
      'summary': summary,
      'target_words': targetWords,
      'current_words': currentWords,
      'status': status.value,
      'draft_version': draftVersion,
      DatabaseTables.fieldDriveFolderId: driveFolderId,
      'source_count': sourceCount,
      'pending_source_count': pendingSourceCount,
      DatabaseTables.fieldCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.fieldUpdatedAt: updatedAt.toIso8601String(),
      DatabaseTables.fieldLastSyncedAt: lastSyncedAt?.toIso8601String(),
      DatabaseTables.fieldIsDirty: isDirty,
      DatabaseTables.fieldIsDeleted: isDeleted,
    };
  }

  Map<String, dynamic> toRemoteJson({String? bookRemoteId}) {
    return <String, dynamic>{
      'number': number,
      'title': title,
      'summary': summary,
      'target_words': targetWords,
      'current_words': currentWords,
      'status': status.value,
      'draft_version': draftVersion,
      if (bookRemoteId != null) 'book_id': bookRemoteId,
    };
  }

  /// Small payload used by the progress channel (word counts change often and
  /// must not drag the whole chapter record along).
  Map<String, dynamic> toProgressJson() {
    return <String, dynamic>{
      'title': title,
      'current_words': currentWords,
      'status': status.value,
    };
  }

  ChapterModel markDirty({DateTime? at}) {
    final DateTime stamp = at ?? DateTime.now();
    return copyWith(updatedAt: stamp, isDirty: true);
  }

  ChapterModel markSynced({String? remoteId, DateTime? at}) {
    final DateTime stamp = at ?? DateTime.now();
    return ChapterModel(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      bookId: bookId,
      projectId: projectId,
      number: number,
      title: title,
      summary: summary,
      targetWords: targetWords,
      currentWords: currentWords,
      status: status,
      draftVersion: draftVersion,
      driveFolderId: driveFolderId,
      sourceCount: sourceCount,
      pendingSourceCount: pendingSourceCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: stamp,
      isDirty: false,
      isDeleted: isDeleted,
    );
  }

  ChapterModel withCounts({
    int? sourceCount,
    int? pendingSourceCount,
    DateTime? at,
  }) {
    return ChapterModel(
      id: id,
      remoteId: remoteId,
      bookId: bookId,
      projectId: projectId,
      number: number,
      title: title,
      summary: summary,
      targetWords: targetWords,
      currentWords: currentWords,
      status: status,
      draftVersion: draftVersion,
      driveFolderId: driveFolderId,
      sourceCount: sourceCount ?? this.sourceCount,
      pendingSourceCount: pendingSourceCount ?? this.pendingSourceCount,
      createdAt: createdAt,
      updatedAt: at ?? updatedAt,
      lastSyncedAt: lastSyncedAt,
      isDirty: isDirty,
      isDeleted: isDeleted,
    );
  }

  @override
  ChapterModel copyWith({
    String? id,
    String? remoteId,
    String? bookId,
    String? projectId,
    int? number,
    String? title,
    String? summary,
    int? targetWords,
    int? currentWords,
    ChapterStatus? status,
    int? draftVersion,
    String? driveFolderId,
    int? sourceCount,
    int? pendingSourceCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      bookId: bookId ?? this.bookId,
      projectId: projectId ?? this.projectId,
      number: number ?? this.number,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      targetWords: targetWords ?? this.targetWords,
      currentWords: currentWords ?? this.currentWords,
      status: status ?? this.status,
      draftVersion: draftVersion ?? this.draftVersion,
      driveFolderId: driveFolderId ?? this.driveFolderId,
      sourceCount: sourceCount ?? this.sourceCount,
      pendingSourceCount: pendingSourceCount ?? this.pendingSourceCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
