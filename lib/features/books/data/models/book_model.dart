import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';

/// Serialisation for [Book] (local document + API record).
class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.remoteId,
    super.author,
    super.genre,
    super.summary,
    super.targetWords,
    super.currentWords,
    super.status,
    super.driveFolderId,
    super.coverImageUrl,
    super.chapterCount,
    super.lastSyncedAt,
    super.isDirty,
    super.isDeleted,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = JsonUtils.asMap(json);
    final DateTime created =
        JsonUtils.asDateTime(data[DatabaseTables.fieldCreatedAt]) ??
            DateTime.now();

    return BookModel(
      id: JsonUtils.asString(data[DatabaseTables.fieldId]),
      remoteId: JsonUtils.asStringOrNull(data[DatabaseTables.fieldRemoteId]),
      projectId: JsonUtils.asString(data['project_id']),
      title: JsonUtils.asString(data['title']),
      author: JsonUtils.asString(data['author']),
      genre: JsonUtils.asString(data['genre']),
      summary: JsonUtils.asString(data['summary']),
      targetWords: JsonUtils.asInt(data['target_words']),
      currentWords: JsonUtils.asInt(data['current_words']),
      status: BookStatus.fromString(JsonUtils.asStringOrNull(data['status'])),
      driveFolderId: JsonUtils.asStringOrNull(
        data[DatabaseTables.fieldDriveFolderId],
      ),
      coverImageUrl: JsonUtils.asStringOrNull(data['cover_image_url']),
      chapterCount: JsonUtils.asInt(data['chapter_count']),
      createdAt: created,
      updatedAt:
          JsonUtils.asDateTime(data[DatabaseTables.fieldUpdatedAt]) ?? created,
      lastSyncedAt: JsonUtils.asDateTime(data[DatabaseTables.fieldLastSyncedAt]),
      isDirty: JsonUtils.asBool(data[DatabaseTables.fieldIsDirty]),
      isDeleted: JsonUtils.asBool(data[DatabaseTables.fieldIsDeleted]),
    );
  }

  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      remoteId: book.remoteId,
      projectId: book.projectId,
      title: book.title,
      author: book.author,
      genre: book.genre,
      summary: book.summary,
      targetWords: book.targetWords,
      currentWords: book.currentWords,
      status: book.status,
      driveFolderId: book.driveFolderId,
      coverImageUrl: book.coverImageUrl,
      chapterCount: book.chapterCount,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
      lastSyncedAt: book.lastSyncedAt,
      isDirty: book.isDirty,
      isDeleted: book.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DatabaseTables.fieldId: id,
      DatabaseTables.fieldRemoteId: remoteId,
      'project_id': projectId,
      'title': title,
      'author': author,
      'genre': genre,
      'summary': summary,
      'target_words': targetWords,
      'current_words': currentWords,
      'status': status.value,
      DatabaseTables.fieldDriveFolderId: driveFolderId,
      'cover_image_url': coverImageUrl,
      'chapter_count': chapterCount,
      DatabaseTables.fieldCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.fieldUpdatedAt: updatedAt.toIso8601String(),
      DatabaseTables.fieldLastSyncedAt: lastSyncedAt?.toIso8601String(),
      DatabaseTables.fieldIsDirty: isDirty,
      DatabaseTables.fieldIsDeleted: isDeleted,
    };
  }

  /// Field set the backend expects. The project is referenced by its *remote*
  /// id, so a book can only be pushed after its project has been accepted.
  Map<String, dynamic> toRemoteJson({String? projectRemoteId}) {
    return <String, dynamic>{
      'title': title,
      'author': author,
      'genre': genre,
      'summary': summary,
      'target_words': targetWords,
      'current_words': currentWords,
      'status': status.value,
      if (projectRemoteId != null) 'project_id': projectRemoteId,
    };
  }

  BookModel markDirty({DateTime? at}) {
    final DateTime stamp = at ?? DateTime.now();
    return copyWith(updatedAt: stamp, isDirty: true);
  }

  BookModel markSynced({String? remoteId, DateTime? at}) {
    final DateTime stamp = at ?? DateTime.now();
    return BookModel(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      projectId: projectId,
      title: title,
      author: author,
      genre: genre,
      summary: summary,
      targetWords: targetWords,
      currentWords: currentWords,
      status: status,
      driveFolderId: driveFolderId,
      coverImageUrl: coverImageUrl,
      chapterCount: chapterCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: stamp,
      isDirty: false,
      isDeleted: isDeleted,
    );
  }

  @override
  BookModel copyWith({
    String? id,
    String? remoteId,
    String? projectId,
    String? title,
    String? author,
    String? genre,
    String? summary,
    int? targetWords,
    int? currentWords,
    BookStatus? status,
    String? driveFolderId,
    String? coverImageUrl,
    int? chapterCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return BookModel(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      summary: summary ?? this.summary,
      targetWords: targetWords ?? this.targetWords,
      currentWords: currentWords ?? this.currentWords,
      status: status ?? this.status,
      driveFolderId: driveFolderId ?? this.driveFolderId,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      chapterCount: chapterCount ?? this.chapterCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
