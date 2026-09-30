import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';

/// Serialisation for [Project]: local store shape *and* API shape.
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    super.remoteId,
    super.description,
    super.type,
    super.status,
    super.assignedAt,
    super.driveFolderId,
    super.coverImageUrl,
    super.totalChapters,
    super.completedChapters,
    super.lastSyncedAt,
    super.isDirty,
    super.isDeleted,
  });

  /// Reads a document from the local box *or* a record from the API.
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = JsonUtils.asMap(json);
    final DateTime created =
        JsonUtils.asDateTime(data[DatabaseTables.fieldCreatedAt]) ??
            DateTime.now();

    return ProjectModel(
      id: JsonUtils.asString(data[DatabaseTables.fieldId]),
      remoteId: JsonUtils.asStringOrNull(data[DatabaseTables.fieldRemoteId]),
      name: JsonUtils.asString(data['name']),
      description: JsonUtils.asString(data['description']),
      type: JsonUtils.asString(data['type'], fallback: 'biography'),
      status: ProjectStatus.fromString(
        JsonUtils.asStringOrNull(data['status']),
      ),
      assignedAt: JsonUtils.asDateTime(data['assigned_at']),
      driveFolderId: JsonUtils.asStringOrNull(
        data[DatabaseTables.fieldDriveFolderId],
      ),
      coverImageUrl: JsonUtils.asStringOrNull(data['cover_image_url']),
      totalChapters: JsonUtils.asInt(data['total_chapters']),
      completedChapters: JsonUtils.asInt(data['completed_chapters']),
      createdAt: created,
      updatedAt:
          JsonUtils.asDateTime(data[DatabaseTables.fieldUpdatedAt]) ?? created,
      lastSyncedAt: JsonUtils.asDateTime(data[DatabaseTables.fieldLastSyncedAt]),
      isDirty: JsonUtils.asBool(data[DatabaseTables.fieldIsDirty]),
      isDeleted: JsonUtils.asBool(data[DatabaseTables.fieldIsDeleted]),
    );
  }

  /// Adapts a plain entity (e.g. coming back out of the repository) for storage.
  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      remoteId: project.remoteId,
      name: project.name,
      description: project.description,
      type: project.type,
      status: project.status,
      assignedAt: project.assignedAt,
      driveFolderId: project.driveFolderId,
      coverImageUrl: project.coverImageUrl,
      totalChapters: project.totalChapters,
      completedChapters: project.completedChapters,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      lastSyncedAt: project.lastSyncedAt,
      isDirty: project.isDirty,
      isDeleted: project.isDeleted,
    );
  }

  /// Local store document.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DatabaseTables.fieldId: id,
      DatabaseTables.fieldRemoteId: remoteId,
      'name': name,
      'description': description,
      'type': type,
      'status': status.value,
      'assigned_at': assignedAt?.toIso8601String(),
      DatabaseTables.fieldDriveFolderId: driveFolderId,
      'cover_image_url': coverImageUrl,
      'total_chapters': totalChapters,
      'completed_chapters': completedChapters,
      DatabaseTables.fieldCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.fieldUpdatedAt: updatedAt.toIso8601String(),
      DatabaseTables.fieldLastSyncedAt: lastSyncedAt?.toIso8601String(),
      DatabaseTables.fieldIsDirty: isDirty,
      DatabaseTables.fieldIsDeleted: isDeleted,
    };
  }

  /// Field set the backend expects for create/update. Local-only bookkeeping
  /// (`is_dirty`, `last_synced_at`, `id`) is never sent.
  Map<String, dynamic> toRemoteJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'type': type,
      'status': status.value,
      if (assignedAt != null) 'assigned_at': assignedAt!.toIso8601String(),
    };
  }

  ProjectModel markDirty({DateTime? at}) {
    final DateTime stamp = at ?? DateTime.now();
    return ProjectModel(
      id: id,
      remoteId: remoteId,
      name: name,
      description: description,
      type: type,
      status: status,
      assignedAt: assignedAt,
      driveFolderId: driveFolderId,
      coverImageUrl: coverImageUrl,
      totalChapters: totalChapters,
      completedChapters: completedChapters,
      createdAt: createdAt,
      updatedAt: stamp,
      lastSyncedAt: lastSyncedAt,
      isDirty: true,
      isDeleted: isDeleted,
    );
  }

  ProjectModel markSynced({String? remoteId, DateTime? at}) {
    final DateTime stamp = at ?? DateTime.now();
    return ProjectModel(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      name: name,
      description: description,
      type: type,
      status: status,
      assignedAt: assignedAt,
      driveFolderId: driveFolderId,
      coverImageUrl: coverImageUrl,
      totalChapters: totalChapters,
      completedChapters: completedChapters,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: stamp,
      isDirty: false,
      isDeleted: isDeleted,
    );
  }

  @override
  ProjectModel copyWith({
    String? id,
    String? remoteId,
    String? name,
    String? description,
    String? type,
    ProjectStatus? status,
    DateTime? assignedAt,
    String? driveFolderId,
    String? coverImageUrl,
    int? totalChapters,
    int? completedChapters,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      driveFolderId: driveFolderId ?? this.driveFolderId,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      totalChapters: totalChapters ?? this.totalChapters,
      completedChapters: completedChapters ?? this.completedChapters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
