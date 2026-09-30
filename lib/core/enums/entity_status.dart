/// Coarse status of a project (a ghost-writing engagement).
enum ProjectStatus {
  draft('draft'),
  assigned('assigned'),
  inProgress('in_progress'),
  onHold('on_hold'),
  completed('completed'),
  archived('archived');

  const ProjectStatus(this.value);

  final String value;

  static ProjectStatus fromString(String? raw) {
    if (raw == null) return ProjectStatus.draft;
    final String needle = raw.trim().toLowerCase();
    for (final ProjectStatus status in ProjectStatus.values) {
      if (status.value == needle) return status;
    }
    return ProjectStatus.draft;
  }

  String get label {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.assigned:
        return 'Assigned';
      case ProjectStatus.inProgress:
        return 'In progress';
      case ProjectStatus.onHold:
        return 'On hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }
}

/// Coarse status of a book inside a project.
enum BookStatus {
  planning('planning'),
  writing('writing'),
  review('review'),
  completed('completed'),
  archived('archived');

  const BookStatus(this.value);

  final String value;

  static BookStatus fromString(String? raw) {
    if (raw == null) return BookStatus.planning;
    final String needle = raw.trim().toLowerCase();
    for (final BookStatus status in BookStatus.values) {
      if (status.value == needle) return status;
    }
    return BookStatus.planning;
  }

  String get label {
    switch (this) {
      case BookStatus.planning:
        return 'Planning';
      case BookStatus.writing:
        return 'Writing';
      case BookStatus.review:
        return 'In review';
      case BookStatus.completed:
        return 'Completed';
      case BookStatus.archived:
        return 'Archived';
    }
  }
}

/// Coarse status of a single chapter.
enum ChapterStatus {
  notStarted('not_started'),
  researching('researching'),
  drafting('drafting'),
  review('review'),
  completed('completed');

  const ChapterStatus(this.value);

  final String value;

  static ChapterStatus fromString(String? raw) {
    if (raw == null) return ChapterStatus.notStarted;
    final String needle = raw.trim().toLowerCase();
    for (final ChapterStatus status in ChapterStatus.values) {
      if (status.value == needle) return status;
    }
    return ChapterStatus.notStarted;
  }

  String get label {
    switch (this) {
      case ChapterStatus.notStarted:
        return 'Not started';
      case ChapterStatus.researching:
        return 'Collecting sources';
      case ChapterStatus.drafting:
        return 'Drafting';
      case ChapterStatus.review:
        return 'In review';
      case ChapterStatus.completed:
        return 'Completed';
    }
  }
}
