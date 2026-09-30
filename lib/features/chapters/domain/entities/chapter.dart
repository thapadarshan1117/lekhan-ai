import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';

/// A chapter of a book. Also the anchor of the local file tree:
/// `projects/<projectId>/<bookId>/<chapterId>/<type>/`.
class Chapter extends Equatable {
  const Chapter({
    required this.id,
    required this.bookId,
    required this.projectId,
    required this.number,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.targetWords = 0,
    this.currentWords = 0,
    this.status = ChapterStatus.notStarted,
    this.draftVersion = 0,
    this.driveFolderId,
    this.summary = '',
    this.sourceCount = 0,
    this.pendingSourceCount = 0,
    this.lastSyncedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  final String id;
  final String? remoteId;

  /// Local ids of the parents - denormalised on purpose so the offline layer
  /// never has to join boxes to build a file path.
  final String bookId;
  final String projectId;

  /// 1-based position in the book.
  final int number;

  final String title;
  final String summary;

  final int targetWords;
  final int currentWords;

  final ChapterStatus status;

  /// Incremented every time the draft is regenerated from new sources.
  final int draftVersion;

  /// Drive folder the backend created for this chapter's media.
  final String? driveFolderId;

  final int sourceCount;

  /// Sources stored locally that have not reached the server yet.
  final int pendingSourceCount;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isDirty;
  final bool isDeleted;

  bool get isLinked => remoteId != null && remoteId!.isNotEmpty;

  double get progress {
    if (targetWords <= 0) return 0;
    return (currentWords / targetWords).clamp(0, 1).toDouble();
  }

  int get remainingWords =>
      targetWords - currentWords > 0 ? targetWords - currentWords : 0;

  bool get hasPendingSources => pendingSourceCount > 0;

  Chapter copyWith({
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
    return Chapter(
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

  @override
  List<Object?> get props => <Object?>[
        id,
        remoteId,
        bookId,
        projectId,
        number,
        title,
        summary,
        targetWords,
        currentWords,
        status,
        draftVersion,
        driveFolderId,
        sourceCount,
        pendingSourceCount,
        createdAt,
        updatedAt,
        lastSyncedAt,
        isDirty,
        isDeleted,
      ];
}
