import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/utils/date_time_utils.dart';

/// A ghost-writing engagement ("Project - Ramesh Koirala").
///
/// The entity is the domain's view of the record: no JSON, no Hive, no HTTP.
/// `ProjectModel` in the data layer adds the serialisation.
class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    this.remoteId,
    this.description = '',
    this.type = 'biography',
    this.status = ProjectStatus.draft,
    this.assignedAt,
    this.driveFolderId,
    this.coverImageUrl,
    this.totalChapters = 0,
    this.completedChapters = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  /// Local id, created on device.
  final String id;

  /// Server id, null until the backend has accepted the record.
  final String? remoteId;

  final String name;
  final String description;

  /// `biography`, `autobiography`, `memoir`, ...
  final String type;

  final ProjectStatus status;
  final DateTime? assignedAt;

  /// Drive folder the backend created for this project, if it is linked.
  final String? driveFolderId;
  final String? coverImageUrl;

  final int totalChapters;
  final int completedChapters;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;

  /// True while the local copy has changes the server has not seen.
  final bool isDirty;

  /// Soft delete: kept until the server confirms the delete.
  final bool isDeleted;

  bool get isLinked => remoteId != null && remoteId!.isNotEmpty;

  /// 0..1 across all chapters of the project.
  double get progress {
    if (totalChapters <= 0) return 0;
    return (completedChapters / totalChapters).clamp(0, 1).toDouble();
  }

  /// True when the record has never reached the server.
  bool get isLocalOnly => !isLinked;

  String get readableUpdatedAt => DateTimeUtils.readableDate(updatedAt);

  Project copyWith({
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
    return Project(
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

  @override
  List<Object?> get props => <Object?>[
        id,
        remoteId,
        name,
        description,
        type,
        status,
        assignedAt,
        driveFolderId,
        coverImageUrl,
        totalChapters,
        completedChapters,
        createdAt,
        updatedAt,
        lastSyncedAt,
        isDirty,
        isDeleted,
      ];
}
