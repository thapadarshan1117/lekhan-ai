import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:lekhan_ai/core/constants/file_constants.dart';

/// SHA-256 helpers used to identify files independent of their file name.
///
/// The checksum is what lets the backend answer "I already have this exact
/// file" instead of "I have a file with the same name" - which matters a lot
/// once an offline queue can replay an upload twice.
class ChecksumUtils {
  const ChecksumUtils._();

  /// Streams [file] through SHA-256 in 1 MB slices so a 500 MB video never has
  /// to be materialised in memory.
  static Future<String> sha256OfFile(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', file.path);
    }

    final _DigestSink sink = _DigestSink();
    final ByteConversionSink input = sha256.startChunkedConversion(sink);
    final RandomAccessFile reader = await file.open();

    try {
      while (true) {
        final List<int> chunk = await reader.read(
          FileConstants.checksumChunkSizeBytes,
        );
        if (chunk.isEmpty) break;
        input.add(chunk);
      }
    } finally {
      await reader.close();
      input.close();
    }

    final Digest? digest = sink.value;
    if (digest == null) {
      throw const FileSystemException('Checksum could not be computed');
    }
    return digest.toString();
  }

  static String sha256OfString(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  static String sha256OfBytes(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Convenience used by the UI to show progress-free identity for small files.
  static Future<String> sha256OfPath(String path) {
    return sha256OfFile(File(path));
  }
}

/// Captures the single [Digest] emitted when the chunked conversion closes.
class _DigestSink implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) {
    value = data;
  }

  @override
  void close() {}
}
