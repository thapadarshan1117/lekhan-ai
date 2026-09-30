import 'package:lekhan_ai/core/enums/source_type.dart';

/// Extension <-> mime type helpers.
///
/// Deliberately dependency free: a wrong mime type is recoverable, a failing
/// lookup package is not worth the risk on the upload path.
class MimeUtils {
  const MimeUtils._();

  static const String octetStream = 'application/octet-stream';

  static const Map<String, String> _byExtension = <String, String>{
    // audio
    'm4a': 'audio/mp4',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'opus': 'audio/opus',
    'flac': 'audio/flac',
    'amr': 'audio/amr',
    // video
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'mkv': 'video/x-matroska',
    'avi': 'video/x-msvideo',
    'webm': 'video/webm',
    '3gp': 'video/3gpp',
    // documents
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt': 'text/plain',
    'rtf': 'application/rtf',
    'odt': 'application/vnd.oasis.opendocument.text',
    'md': 'text/markdown',
    // images
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'heic': 'image/heic',
    'webp': 'image/webp',
    'bmp': 'image/bmp',
    'tif': 'image/tiff',
    'tiff': 'image/tiff',
  };

  /// Mime type for a file extension (with or without the leading dot).
  static String fromExtension(String? extension) {
    final String needle = normalizeExtension(extension);
    return _byExtension[needle] ?? octetStream;
  }

  /// Mime type for a file path.
  static String fromPath(String path) {
    return fromExtension(extensionOf(path));
  }

  /// Extension of a path or file name, without the dot, lower case.
  static String extensionOf(String path) {
    final String clean = path.split('?').first;
    final int slash = clean.lastIndexOf(RegExp(r'[/\\]'));
    final String name = slash >= 0 ? clean.substring(slash + 1) : clean;
    final int dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static String normalizeExtension(String? extension) {
    return (extension ?? '').trim().toLowerCase().replaceAll('.', '');
  }

  /// Coarse category used before the file is inspected further.
  static SourceType sourceTypeOfPath(String path) {
    return SourceType.fromExtension(extensionOf(path));
  }

  /// True when the extension is one of the accepted upload types.
  static bool isSupportedExtension(String? extension) {
    final String needle = normalizeExtension(extension);
    return _byExtension.containsKey(needle);
  }

  /// Whether the mime type is safe to preview inline in the app.
  static bool isPreviewable(String mimeType) {
    return mimeType.startsWith('image/') ||
        mimeType.startsWith('audio/') ||
        mimeType.startsWith('video/') ||
        mimeType == 'application/pdf';
  }
}
