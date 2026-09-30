/// Rules about the files the app accepts and how they are transferred.
class FileConstants {
  const FileConstants._();

  /// Hard ceiling per source file (product rule: 500 MB).
  static const int maxFileSizeBytes = 500 * 1024 * 1024;

  /// Files above this size are only synced on Wi-Fi by default.
  static const int largeFileThresholdBytes = 25 * 1024 * 1024;

  /// Chunk used by the resumable uploader. Small enough to survive a dropped
  /// connection, large enough to keep the request count sane.
  static const int uploadChunkSizeBytes = 4 * 1024 * 1024;

  /// How long a resumable session is considered usable before the app
  /// re-initiates it.
  static const Duration uploadSessionTtl = Duration(hours: 12);

  /// Size of the buffer used while hashing a file for its checksum.
  static const int checksumChunkSizeBytes = 1024 * 1024;

  static const List<String> audioExtensions = <String>[
    'm4a',
    'mp3',
    'wav',
    'aac',
    'ogg',
    'opus',
    'flac',
    'amr',
  ];

  static const List<String> videoExtensions = <String>[
    'mp4',
    'mov',
    'mkv',
    'avi',
    'webm',
    '3gp',
  ];

  static const List<String> documentExtensions = <String>[
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
    'odt',
    'md',
  ];

  static const List<String> imageExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'heic',
    'webp',
    'bmp',
    'tif',
    'tiff',
  ];

  /// Everything the picker should offer, in one list.
  static List<String> get allExtensions => <String>[
        ...audioExtensions,
        ...videoExtensions,
        ...documentExtensions,
        ...imageExtensions,
      ];
}
