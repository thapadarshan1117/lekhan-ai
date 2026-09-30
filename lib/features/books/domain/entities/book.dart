import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';

/// A book inside a project ("My Life Journey").
class Book extends Equatable {
  const Book({
    required this.id,
    required this.projectId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.author = '',
    this.genre = '',
    this.summary = '',
    this.targetWords = 0,
    this.currentWords = 0,
    this.status = BookStatus.planning,
    this.driveFolderId,
    this.coverImageUrl,
    this.chapterCount = 0,
    this.lastSyncedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  final String id;
  final String? remoteId;

  /// Local id of the owning project.
  final String projectId;

  final String title;
  final String author;
  final String genre;
  final String summary;

  final int targetWords;
  final int currentWords;

  final BookStatus status;

  /// Drive folder created by the backend for this book.
  final String? driveFolderId;
  final String? coverImageUrl;

  final int chapterCount;

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

  Book copyWith({
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
    return Book(
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

  @override
  List<Object?> get props => <Object?>[
        id,
        remoteId,
        projectId,
        title,
        author,
        genre,
        summary,
        targetWords,
        currentWords,
        status,
        driveFolderId,
        coverImageUrl,
        chapterCount,
        createdAt,
        updatedAt,
        lastSyncedAt,
        isDirty,
        isDeleted,
      ];
}
