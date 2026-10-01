import 'dart:io';

import 'package:lekhan_ai/core/constants/storage_constants.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/utils/file_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The binary half of the offline store.
///
/// Layout (mirrors the domain so a human can recover the files by hand):
///
/// ```text
/// <documents>/lekhan_app/
///   projects/<project_id>/<book_id>/<chapter_id>/
///     audio/  video/  documents/  scans/  recordings/
///   temp/
/// ```
///
/// The database only ever stores the resulting absolute path plus size,
/// mime type and checksum - never the bytes.
class LocalFileStorage {
  Directory? _root;

  bool get isInitialized => _root != null;

  /// Creates the folder tree. Safe to call more than once.
  Future<void> init() async {
    if (_root != null) return;

    final Directory base = await getApplicationDocumentsDirectory();
    final Directory root = Directory(
      p.join(base.path, StorageConstants.appFolderName),
    );
    await _ensureDirectory(root);
    _root = root;

    await _ensureDirectory(tempDirectory);
  }

  Directory get rootDirectory {
    final Directory? root = _root;
    if (root == null) {
      throw StateError(
        'LocalFileStorage.init() must complete before it is used.',
      );
    }
    return root;
  }

  Directory get tempDirectory => Directory(
        p.join(rootDirectory.path, StorageConstants.tempFolder),
      );

  // ---------------------------------------------------------------------------
  // Directory resolution
  // ---------------------------------------------------------------------------

  Future<Directory> projectDirectory(String projectId) {
    return _ensureDirectory(
      Directory(p.join(rootDirectory.path, StorageConstants.projectsFolder, projectId)),
    );
  }

  Future<Directory> bookDirectory({
    required String projectId,
    required String bookId,
  }) async {
    final Directory project = await projectDirectory(projectId);
    return _ensureDirectory(Directory(p.join(project.path, bookId)));
  }

  /// Chapter folder, or one of its type sub folders when [type] is given.
  Future<Directory> chapterDirectory({
    required String projectId,
    required String bookId,
    required String chapterId,
    SourceType? type,
  }) async {
    final Directory book = await bookDirectory(
      projectId: projectId,
      bookId: bookId,
    );
    final Directory chapter = await _ensureDirectory(
      Directory(p.join(book.path, chapterId)),
    );
    if (type == null) return chapter;
    return _ensureDirectory(Directory(p.join(chapter.path, type.folderName)));
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  /// Copies [source] into the chapter folder and returns the stored path.
  ///
  /// The copy is written under a staging name first and renamed afterwards, so
  /// a killed app can never leave a half written file that looks complete.
  ///
  /// [source] is never modified when [deleteSource] is false (the default),
  /// because the original may live in a shared location the user still owns.
  Future<String> importFile({
    required File source,
    required String projectId,
    required String bookId,
    required String chapterId,
    required SourceType type,
    String? preferredFileName,
    bool deleteSource = false,
  }) async {
    final Directory directory = await chapterDirectory(
      projectId: projectId,
      bookId: bookId,
      chapterId: chapterId,
      type: type,
    );

    final String wanted = FileUtils.sanitizeFileName(
      preferredFileName ?? FileUtils.nameOf(source.path),
    );
    final String fileName = await _availableFileName(directory, wanted);

    final File staging = File(
      p.join(directory.path, '${StorageConstants.stagingPrefix}$fileName'),
    );
    final File target = File(p.join(directory.path, fileName));

    try {
      await source.copy(staging.path);
      await staging.rename(target.path);
    } catch (error) {
      await FileUtils.deleteIfExists(staging.path);
      rethrow;
    }

    if (deleteSource) {
      await FileUtils.deleteIfExists(source.path);
    }

    return target.path;
  }

  /// Reserves a path for a recording that is about to be written by the
  /// recorder plugin (the plugin needs the path *before* the file exists).
  Future<String> reserveRecordingPath({
    required String projectId,
    required String bookId,
    required String chapterId,
    String extension = 'm4a',
  }) async {
    final Directory directory = await chapterDirectory(
      projectId: projectId,
      bookId: bookId,
      chapterId: chapterId,
      type: SourceType.recording,
    );
    final String name = await _availableFileName(
      directory,
      'voice_memo_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    return p.join(directory.path, name);
  }

  Future<File> writeBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    await _ensureDirectory(tempDirectory);
    final String safeName = FileUtils.sanitizeFileName(fileName);
    final File file = File(p.join(tempDirectory.path, safeName));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ---------------------------------------------------------------------------
  // Reads / deletes
  // ---------------------------------------------------------------------------

  Future<bool> exists(String? path) => FileUtils.exists(path);

  Future<int> sizeOf(String? path) => FileUtils.sizeOf(path);

  Future<List<File>> listFiles(Directory directory) async {
    if (!await directory.exists()) return <File>[];
    final List<File> files = <File>[];
    await for (final FileSystemEntity entity in directory.list()) {
      if (entity is File) files.add(entity);
    }
    return files;
  }

  /// Total bytes stored under [directory] (recursively).
  Future<int> directorySize(Directory directory) async {
    if (!await directory.exists()) return 0;
    int total = 0;
    await for (final FileSystemEntity entity in directory.list(recursive: true)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {
          // File vanished mid walk; ignore it.
        }
      }
    }
    return total;
  }

  Future<int> totalSize() => directorySize(rootDirectory);

  Future<void> deleteFile(String? path) => FileUtils.deleteIfExists(path);

  Future<void> deleteDirectory(Directory directory) async {
    try {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (_) {
      // Best effort: the database record is the source of truth.
    }
  }

  Future<void> deleteChapterDirectory({
    required String projectId,
    required String bookId,
    required String chapterId,
  }) async {
    final Directory directory = await chapterDirectory(
      projectId: projectId,
      bookId: bookId,
      chapterId: chapterId,
    );
    await deleteDirectory(directory);
  }

  /// Deletes all app-owned media (used when the signed-in account is removed).
  /// Files selected from shared storage are copied into this root, so clearing
  /// it never deletes the user's originals.
  Future<void> clearAll() async {
    final Directory root = rootDirectory;
    await deleteDirectory(root);
    _root = null;
    await init();
  }

  /// Removes leftovers from interrupted imports. Called on startup.
  Future<void> cleanTemp() async {
    await deleteDirectory(tempDirectory);
    await _ensureDirectory(tempDirectory);
  }

  /// Removes staging files that were abandoned inside the project tree.
  Future<void> cleanStagingFiles() async {
    final Directory projectsRoot = Directory(
      p.join(rootDirectory.path, StorageConstants.projectsFolder),
    );
    if (!await projectsRoot.exists()) return;

    try {
      await for (final FileSystemEntity entity
          in projectsRoot.list(recursive: true)) {
        if (entity is File &&
            FileUtils.nameOf(entity.path).startsWith(StorageConstants.stagingPrefix)) {
          await FileUtils.deleteIfExists(entity.path);
        }
      }
    } catch (_) {
      // Nothing critical: staging files are ignored by every reader.
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<Directory> _ensureDirectory(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// `notes.pdf` -> `notes (2).pdf` when the first name is taken.
  Future<String> _availableFileName(Directory directory, String fileName) async {
    if (!await File(p.join(directory.path, fileName)).exists()) {
      return fileName;
    }

    final String base = FileUtils.baseNameOf(fileName);
    final String extension = FileUtils.extensionOf(fileName);

    for (int index = 2; index < 1000; index++) {
      final String candidate =
          extension.isEmpty ? '$base ($index)' : '$base ($index).$extension';
      if (!await File(p.join(directory.path, candidate)).exists()) {
        return candidate;
      }
    }

    return extension.isEmpty
        ? '$base ${DateTime.now().millisecondsSinceEpoch}'
        : '$base ${DateTime.now().millisecondsSinceEpoch}.$extension';
  }
}
