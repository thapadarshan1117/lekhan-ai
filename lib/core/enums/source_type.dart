import 'package:lekhan_ai/core/constants/file_constants.dart';
import 'package:lekhan_ai/core/constants/storage_constants.dart';

/// What kind of content a chapter source actually is.
///
/// The folder name and the sync priority hang off the type so that neither the
/// file store nor the scheduler needs its own mapping table.
enum SourceType {
  audio('audio', StorageConstants.audioFolder, 'Audio'),
  video('video', StorageConstants.videoFolder, 'Video'),
  document('document', StorageConstants.documentsFolder, 'Document'),
  image('image', StorageConstants.scansFolder, 'Scan / image'),
  recording('recording', StorageConstants.recordingsFolder, 'Voice recording');

  const SourceType(this.value, this.folderName, this.label);

  /// API value.
  final String value;

  /// Folder inside the chapter directory.
  final String folderName;

  /// Human readable label for the UI.
  final String label;

  static SourceType fromString(String? raw) {
    if (raw == null) return SourceType.document;
    final String needle = raw.trim().toLowerCase();
    for (final SourceType type in SourceType.values) {
      if (type.value == needle) return type;
    }
    return SourceType.document;
  }

  /// Best-effort classification from a file extension.
  static SourceType fromExtension(String? extension) {
    final String needle = (extension ?? '').trim().toLowerCase().replaceAll('.', '');
    if (FileConstants.audioExtensions.contains(needle)) {
      return SourceType.audio;
    }
    if (FileConstants.videoExtensions.contains(needle)) {
      return SourceType.video;
    }
    if (FileConstants.imageExtensions.contains(needle)) {
      return SourceType.image;
    }
    if (FileConstants.documentExtensions.contains(needle)) {
      return SourceType.document;
    }
    return SourceType.document;
  }

  /// Fallback classification from a mime type.
  static SourceType fromMimeType(String? mimeType) {
    final String needle = (mimeType ?? '').trim().toLowerCase();
    if (needle.startsWith('audio/')) return SourceType.audio;
    if (needle.startsWith('video/')) return SourceType.video;
    if (needle.startsWith('image/')) return SourceType.image;
    return SourceType.document;
  }

  /// Short, product-facing emoji used by the source cards.
  String get icon {
    switch (this) {
      case SourceType.audio:
        return '🎙';
      case SourceType.video:
        return '🎥';
      case SourceType.document:
        return '📄';
      case SourceType.image:
        return '🖼';
      case SourceType.recording:
        return '🎙';
    }
  }
}
