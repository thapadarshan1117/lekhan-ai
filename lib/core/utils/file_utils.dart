import 'dart:io';

import 'package:lekhan_ai/core/constants/file_constants.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/utils/mime_utils.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// File system conveniences shared by the storage layer and the upload queue.
class FileUtils {
  const FileUtils._();

  /// `12.4 MB`, `840 KB`, ...
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    const List<String> units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final String value = unit == 0
        ? size.toStringAsFixed(0)
        : size.toStringAsFixed(decimals);
    return '$value ${units[unit]}';
  }

  /// `48 min`, `1 h 12 min`, `34 s`.
  static String formatDuration(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    if (totalSeconds < 60) return '$totalSeconds s';
    final int minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes min';
    final int hours = duration.inHours;
    final int remainingMinutes = minutes - hours * 60;
    if (remainingMinutes == 0) return '$hours h';
    return '$hours h $remainingMinutes min';
  }

  static String extensionOf(String path) => MimeUtils.extensionOf(path);

  static String nameOf(String path) {
    final String clean = path.split('?').first;
    final int slash = clean.lastIndexOf(RegExp(r'[/\\]'));
    return slash >= 0 ? clean.substring(slash + 1) : clean;
  }

  /// Extension-less name, used to build "{name}_v2.pdf" style file names.
  static String baseNameOf(String path) {
    final String name = nameOf(path);
    final int dot = name.lastIndexOf('.');
    if (dot <= 0) return name;
    return name.substring(0, dot);
  }

  /// Strips characters that are illegal (or merely annoying) on either mobile
  /// file system and shortens the result so long names stay openable.
  static String sanitizeFileName(
    String name, {
    int maxLength = 120,
    String fallback = 'file',
  }) {
    String clean = name.trim().replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1F]'), '_');
    clean = clean.replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) clean = fallback;
    if (clean.startsWith('.')) clean = '${fallback}_$clean';
    if (clean.length > maxLength) {
      final String extension = MimeUtils.extensionOf(clean);
      final int keep = maxLength - (extension.isEmpty ? 0 : extension.length + 1);
      final String head = clean.substring(0, keep < 1 ? 1 : keep);
      clean = extension.isEmpty ? head : '$head.$extension';
    }
    return clean;
  }

  static Future<bool> exists(String? path) async {
    if (path == null || path.isEmpty) return false;
    return File(path).exists();
  }

  static Future<int> sizeOf(String? path) async {
    if (path == null || path.isEmpty) return 0;
    final File file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  /// Deletes silently: a missing file is not an error for the caller.
  static Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Nothing useful to do: the record is removed from the database anyway.
    }
  }

  static bool isAudio(String path) =>
      FileConstants.audioExtensions.contains(extensionOf(path));

  static bool isVideo(String path) =>
      FileConstants.videoExtensions.contains(extensionOf(path));

  static bool isImage(String path) =>
      FileConstants.imageExtensions.contains(extensionOf(path));

  static bool isDocument(String path) =>
      FileConstants.documentExtensions.contains(extensionOf(path));

  /// Validates size and extension before a file enters the store.
  ///
  /// Returns `null` when the file is acceptable, otherwise the [AppException]
  /// the caller should surface.
  static Future<AppException?> validateForUpload(
    File file, {
    String identifier = 'FileUtils.validateForUpload',
    int maxBytes = FileConstants.maxFileSizeBytes,
  }) async {
    if (!await file.exists()) {
      return AppException(
        message: 'The selected file could not be found on this device.',
        statusCode: LocalErrorCodes.notFound,
        identifier: identifier,
      );
    }

    final int size = await file.length();
    if (size <= 0) {
      return AppException(
        message: 'The selected file is empty.',
        statusCode: LocalErrorCodes.invalidPayload,
        identifier: identifier,
      );
    }
    if (size > maxBytes) {
      return AppException(
        message:
            'This file is ${formatBytes(size)}. The limit is ${formatBytes(maxBytes)} per source file.',
        statusCode: LocalErrorCodes.fileTooLarge,
        identifier: identifier,
      );
    }

    final String extension = extensionOf(file.path);
    if (!MimeUtils.isSupportedExtension(extension)) {
      return AppException(
        message:
            'Files of type ".$extension" are not supported yet. Please pick an audio, video, document or image file.',
        statusCode: LocalErrorCodes.unsupportedMedia,
        identifier: identifier,
      );
    }

    return null;
  }
}
