import 'dart:io';

import 'package:lekhan_ai/core/constants/file_constants.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/storage/local_file_storage.dart';
import 'package:lekhan_ai/core/utils/checksum_utils.dart';
import 'package:lekhan_ai/core/utils/file_utils.dart';
import 'package:lekhan_ai/core/utils/mime_utils.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// Result of handing a file to the app: everything the database needs to store
/// about a source, and nothing about the file's bytes.
class StoredFileInfo {
  const StoredFileInfo({
    required this.localPath,
    required this.fileName,
    required this.extension,
    required this.mimeType,
    required this.sizeBytes,
    required this.checksum,
    required this.type,
  });

  final String localPath;
  final String fileName;
  final String extension;
  final String mimeType;
  final int sizeBytes;
  final String checksum;
  final SourceType type;

  String get readableSize => FileUtils.formatBytes(sizeBytes);
}

/// High level file operations for features.
///
/// Feature repositories talk to this instead of touching `dart:io`, which keeps
/// validation, checksumming and the folder layout in one place.
class StorageManager {
  StorageManager({
    required this.localFileStorage,
    Future<String> Function(File file)? checksumBuilder,
  }) : _checksumBuilder = checksumBuilder ?? ChecksumUtils.sha256OfFile;

  final LocalFileStorage localFileStorage;
  final Future<String> Function(File file) _checksumBuilder;

  /// Validates, copies into the store and hashes [source].
  ///
  /// Throws [AppException] when the file is missing, empty, too large or of an
  /// unsupported type - the caller is expected to surface that message as is.
  Future<StoredFileInfo> storeChapterSource({
    required File source,
    required String projectId,
    required String bookId,
    required String chapterId,
    required SourceType type,
    String? preferredFileName,
    bool deleteSource = false,
  }) async {
    final AppException? invalid = await FileUtils.validateForUpload(source);
    if (invalid != null) throw invalid;

    final String localPath = await localFileStorage.importFile(
      source: source,
      projectId: projectId,
      bookId: bookId,
      chapterId: chapterId,
      type: type,
      preferredFileName: preferredFileName,
      deleteSource: deleteSource,
    );

    final File stored = File(localPath);
    final String checksum = await _checksumBuilder(stored);

    return StoredFileInfo(
      localPath: localPath,
      fileName: FileUtils.nameOf(localPath),
      extension: FileUtils.extensionOf(localPath),
      mimeType: MimeUtils.fromPath(localPath),
      sizeBytes: await stored.length(),
      checksum: checksum,
      type: type,
    );
  }

  /// Registers a file the recorder plugin just wrote (no copy needed: the
  /// plugin already wrote it inside the chapter folder).
  Future<StoredFileInfo> registerRecordingFile({
    required String localPath,
    required SourceType type,
  }) async {
    final File file = File(localPath);
    final AppException? invalid = await FileUtils.validateForUpload(file);
    if (invalid != null) throw invalid;

    return StoredFileInfo(
      localPath: localPath,
      fileName: FileUtils.nameOf(localPath),
      extension: FileUtils.extensionOf(localPath),
      mimeType: MimeUtils.fromPath(localPath),
      sizeBytes: await file.length(),
      checksum: await _checksumBuilder(file),
      type: type,
    );
  }

  /// True when a large file may be sent over the current connection class.
  bool shouldDeferForNetwork({
    required int sizeBytes,
    required bool onWifi,
    required bool wifiOnly,
  }) {
    if (!wifiOnly) return false;
    if (sizeBytes < FileConstants.largeFileThresholdBytes) return false;
    return !onWifi;
  }

  Future<void> deleteFile(String? localPath) =>
      localFileStorage.deleteFile(localPath);

  Future<void> deleteChapterFiles({
    required String projectId,
    required String bookId,
    required String chapterId,
  }) {
    return localFileStorage.deleteChapterDirectory(
      projectId: projectId,
      bookId: bookId,
      chapterId: chapterId,
    );
  }

  Future<int> chapterSize({
    required String projectId,
    required String bookId,
    required String chapterId,
  }) async {
    final Directory directory = await localFileStorage.chapterDirectory(
      projectId: projectId,
      bookId: bookId,
      chapterId: chapterId,
    );
    return localFileStorage.directorySize(directory);
  }

  Future<int> totalSize() => localFileStorage.totalSize();

  /// Clears media owned by the app when the local account cache is removed.
  Future<void> clearUserFiles() => localFileStorage.clearAll();

  /// Startup housekeeping: drop abandoned staging/temp files.
  Future<void> cleanUp() async {
    await localFileStorage.cleanTemp();
    await localFileStorage.cleanStagingFiles();
  }
}
