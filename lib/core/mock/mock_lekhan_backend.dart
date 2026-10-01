import 'package:lekhan_ai/core/config/backend_mode.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';

/// In-memory stand-in for the Lekhan API used by the UI-only build.
///
/// It has the same broad behaviours as the future backend: stable remote ids,
/// parent relationships, push/pull change records, and resumable upload offsets.
/// No HTTP client, credentials, or Drive SDK is used here. Switch
/// [BackendMode.useMockBackend] off in DI when the server contract is ready.
class MockLekhanBackend {
  MockLekhanBackend({this.latency = const Duration(milliseconds: 180)}) {
    _seedDemoRecords();
  }

  final Duration latency;

  final Map<String, Map<String, Map<String, dynamic>>> _records =
      <String, Map<String, Map<String, dynamic>>>{
    for (final String type in <String>[
      'project',
      'book',
      'chapter',
      'chapter_source',
    ])
      type: <String, Map<String, dynamic>>{},
  };
  final Map<String, String> _remoteIdByLocalKey = <String, String>{};
  final List<Map<String, dynamic>> _changeLog = <Map<String, dynamic>>[];
  final Map<String, MockUploadSession> _uploads =
      <String, MockUploadSession>{};

  int _uploadSequence = 0;
  int _fileSequence = 0;

  Future<void> _wait() => Future<void>.delayed(latency);

  List<Map<String, dynamic>> fetchRecords(
    String entityType, {
    String? parentField,
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  }) {
    final List<Map<String, dynamic>> all =
        (_records[entityType]?.values ?? const <Map<String, dynamic>>[])
            .where((Map<String, dynamic> record) =>
                parentRemoteId == null ||
                parentRemoteId.isEmpty ||
                JsonUtils.asString(record[parentField]) == parentRemoteId)
            .map<Map<String, dynamic>>(
              (Map<String, dynamic> record) => Map<String, dynamic>.of(record),
            )
            .toList()
          ..sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
              JsonUtils.asString(b['updated_at'])
                  .compareTo(JsonUtils.asString(a['updated_at'])));

    final int safePage = page < 1 ? 1 : page;
    final int safePageSize = pageSize < 1 ? 50 : pageSize;
    final int start = (safePage - 1) * safePageSize;
    if (start >= all.length) return const <Map<String, dynamic>>[];
    return all.skip(start).take(safePageSize).toList(growable: false);
  }

  Map<String, dynamic>? fetchRecord(String entityType, String remoteId) {
    final Map<String, dynamic>? record = _records[entityType]?[remoteId];
    return record == null ? null : Map<String, dynamic>.of(record);
  }

  Future<bool> deleteRecord(String entityType, String remoteId) async {
    await _wait();
    if (_records[entityType]?[remoteId] == null) return false;
    _deleteRecordCascade(entityType, remoteId);
    return true;
  }

  /// Mirrors the parent/child cleanup expected from the future backend. In
  /// production the API owns any corresponding Google Drive cleanup.
  void _deleteRecordCascade(String entityType, String remoteId) {
    final String? childType;
    final String? parentField;
    switch (entityType) {
      case 'project':
        childType = 'book';
        parentField = 'project_id';
        break;
      case 'book':
        childType = 'chapter';
        parentField = 'book_id';
        break;
      case 'chapter':
        childType = 'chapter_source';
        parentField = 'chapter_id';
        break;
      default:
        childType = null;
        parentField = null;
    }

    if (childType != null && parentField != null) {
      final List<String> childIds = (_records[childType]?.values ??
              const <Map<String, dynamic>>[])
          .where((Map<String, dynamic> record) =>
              JsonUtils.asString(record[parentField]) == remoteId)
          .map<String>((Map<String, dynamic> record) =>
              JsonUtils.asString(record['remote_id'] ?? record['id']))
          .where((String id) => id.isNotEmpty)
          .toList(growable: false);
      for (final String childId in childIds) {
        _deleteRecordCascade(childType, childId);
      }
    }

    final Map<String, dynamic>? removed = _records[entityType]?.remove(remoteId);
    if (removed == null) return;

    final List<String> mappingKeys = _remoteIdByLocalKey.entries
        .where((MapEntry<String, String> entry) =>
            entry.key.startsWith('$entityType:') && entry.value == remoteId)
        .map<String>((MapEntry<String, String> entry) => entry.key)
        .toList(growable: false);
    for (final String key in mappingKeys) {
      _remoteIdByLocalKey.remove(key);
    }

    if (entityType == 'chapter_source') {
      _uploads.removeWhere((String _, MockUploadSession session) =>
          session.sourceRemoteId == remoteId);
    }
    _appendChange(
      entityType,
      'delete',
      remoteId,
      <String, dynamic>{'id': remoteId, 'remote_id': remoteId, 'is_deleted': true},
    );
  }

  Future<List<Map<String, dynamic>>> pushChanges(
    List<Map<String, dynamic>> changes,
  ) async {
    await _wait();
    final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];

    for (final Map<String, dynamic> change in changes) {
      final String entityType = JsonUtils.asString(
        change['entity_type'] ?? change['entityType'],
      );
      final String localId = JsonUtils.asString(
        change['local_id'] ?? change['localId'],
      );
      final String operation = JsonUtils.asString(change['operation'])
          .toLowerCase();
      final Map<String, dynamic> payload =
          JsonUtils.asMap(change['payload']);

      if (entityType == 'progress') {
        final String chapterId = JsonUtils.asString(
          change['remote_id'] ?? payload['chapter_id'],
        );
        final Map<String, dynamic>? chapter =
            _records['chapter']?[chapterId];
        if (chapter != null) {
          chapter.addAll(payload);
          chapter['updated_at'] = DateTime.now().toUtc().toIso8601String();
          _appendChange('chapter', 'update', chapterId, chapter);
        }
        results.add(<String, dynamic>{
          'local_id': localId,
          'remote_id': chapterId,
          'status': 'success',
        });
        continue;
      }

      if (!_records.containsKey(entityType)) {
        results.add(<String, dynamic>{
          'local_id': localId,
          'status': 'rejected',
          'error': 'Unsupported mock entity type: $entityType',
        });
        continue;
      }

      final String localKey = '$entityType:$localId';
      String? remoteId = JsonUtils.asStringOrNull(change['remote_id']) ??
          _remoteIdByLocalKey[localKey];
      if (operation == 'delete') {
        remoteId ??= localId;
        _deleteRecordCascade(entityType, remoteId);
        _remoteIdByLocalKey.remove(localKey);
        results.add(<String, dynamic>{
          'local_id': localId,
          'remote_id': remoteId,
          'status': 'success',
        });
        continue;
      }

      remoteId ??= 'mock_${entityType}_${IdGenerator.newUuid()}';
      _remoteIdByLocalKey[localKey] = remoteId;
      final Map<String, dynamic>? existing = _records[entityType]![remoteId];
      final String stamp = DateTime.now().toUtc().toIso8601String();
      final Map<String, dynamic> record = <String, dynamic>{
        ...?existing,
        ...payload,
        'id': remoteId,
        'remote_id': remoteId,
        'created_at': existing?['created_at'] ?? payload['created_at'] ?? stamp,
        'updated_at': stamp,
        'is_deleted': false,
      };
      _records[entityType]![remoteId] = record;
      _appendChange(
        entityType,
        existing == null ? 'create' : 'update',
        remoteId,
        record,
      );
      results.add(<String, dynamic>{
        'local_id': localId,
        'remote_id': remoteId,
        'status': 'success',
      });
    }

    return results;
  }

  Future<Map<String, dynamic>> pullChanges({
    DateTime? since,
    int page = 1,
    int pageSize = 100,
  }) async {
    await _wait();
    final List<Map<String, dynamic>> matching = _changeLog.where((
      Map<String, dynamic> change,
    ) {
      if (since == null) return true;
      final DateTime? changedAt = JsonUtils.asDateTime(change['updated_at']);
      return changedAt != null && changedAt.isAfter(since);
    }).toList(growable: false);

    final int safePage = page < 1 ? 1 : page;
    final int safePageSize = pageSize < 1 ? 100 : pageSize;
    final int start = (safePage - 1) * safePageSize;
    final List<Map<String, dynamic>> items = matching
        .skip(start)
        .take(safePageSize)
        .map<Map<String, dynamic>>(
          (Map<String, dynamic> item) => Map<String, dynamic>.of(item),
        )
        .toList(growable: false);
    final bool hasMore = start + items.length < matching.length;

    return <String, dynamic>{
      'changes': items,
      'has_more': hasMore,
      if (hasMore) 'next_page': safePage + 1,
      'server_time': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> fetchStatus() async {
    await _wait();
    return <String, dynamic>{
      'queue_size': 0,
      'last_sync': DateTime.now().toUtc().toIso8601String(),
      'mode': 'mock',
    };
  }

  Future<MockUploadSession> initiateUpload({
    required String sourceLocalId,
    required String chapterRemoteId,
    required int sizeBytes,
    required int chunkSize,
    required String checksum,
  }) async {
    await _wait();
    final String uploadId = 'mock_upload_${++_uploadSequence}';
    final String sourceRemoteId =
        _remoteIdByLocalKey['chapter_source:$sourceLocalId'] ?? sourceLocalId;
    final MockUploadSession session = MockUploadSession(
      uploadId: uploadId,
      uploadUrl: 'mock-upload://$uploadId',
      sourceLocalId: sourceLocalId,
      sourceRemoteId: sourceRemoteId,
      chapterRemoteId: chapterRemoteId,
      sizeBytes: sizeBytes,
      chunkSize: chunkSize,
      checksum: checksum,
    );
    _uploads[uploadId] = session;
    return session;
  }

  MockUploadSession? uploadSession(String uploadId) => _uploads[uploadId];

  Future<MockUploadSession?> saveUploadOffset(
    String uploadId,
    int offset,
  ) async {
    await _wait();
    final MockUploadSession? current = _uploads[uploadId];
    if (current == null) return null;
    final MockUploadSession updated = current.copyWith(
      offset: offset.clamp(0, current.sizeBytes).toInt(),
    );
    _uploads[uploadId] = updated;
    return updated;
  }

  Future<Map<String, dynamic>?> completeUpload(String uploadId) async {
    await _wait();
    final MockUploadSession? session = _uploads[uploadId];
    if (session == null) return null;
    _fileSequence++;
    final String remoteFileId = 'mock_file_$_fileSequence';
    final String driveFileId = 'mock_drive_file_$_fileSequence';
    final Map<String, dynamic>? source =
        _records['chapter_source']?[session.sourceRemoteId];
    if (source != null) {
      source['upload_status'] = 'uploaded';
      source['remote_file_id'] = remoteFileId;
      source['drive_file_id'] = driveFileId;
      source['processing_status'] = 'queued';
      source['updated_at'] = DateTime.now().toUtc().toIso8601String();
      _appendChange('chapter_source', 'update', session.sourceRemoteId, source);
    }
    return <String, dynamic>{
      'source_id': session.sourceRemoteId,
      'remote_file_id': remoteFileId,
      'drive_file_id': driveFileId,
      'processing_status': 'queued',
    };
  }

  Future<void> cancelUpload(String uploadId) async {
    await _wait();
    _uploads.remove(uploadId);
  }

  void _appendChange(
    String entityType,
    String operation,
    String remoteId,
    Map<String, dynamic> record,
  ) {
    final String stamp = DateTime.now().toUtc().toIso8601String();
    _changeLog.add(<String, dynamic>{
      'entity_type': entityType,
      'operation': operation,
      'remote_id': remoteId,
      'payload': Map<String, dynamic>.of(record),
      'updated_at': stamp,
    });
  }

  void _seedDemoRecords() {
    final DateTime now = DateTime.now().toUtc();
    final String created = now.subtract(const Duration(days: 14)).toIso8601String();
    final String updated = now.subtract(const Duration(days: 1)).toIso8601String();

    final List<Map<String, dynamic>> demoRecords = <Map<String, dynamic>>[
      <String, dynamic>{
        'entity_type': 'project',
        'id': 'demo_project_1',
        'remote_id': 'demo_project_1',
        'name': 'My Writing Project',
        'description': 'A space for stories, research, and drafts.',
        'type': 'biography',
        'status': 'in_progress',
        'created_at': created,
        'updated_at': updated,
      },
      <String, dynamic>{
        'entity_type': 'project',
        'id': 'demo_project_2',
        'remote_id': 'demo_project_2',
        'name': 'Travel Memories',
        'description': 'Notes and stories from the road.',
        'type': 'memoir',
        'status': 'draft',
        'created_at': created,
        'updated_at': updated,
      },
      <String, dynamic>{
        'entity_type': 'book',
        'id': 'demo_book_1',
        'remote_id': 'demo_book_1',
        'project_id': 'demo_project_1',
        'title': 'The Story So Far',
        'author': '',
        'genre': 'Memoir',
        'summary': 'A first collection of memories and milestones.',
        'target_words': 30000,
        'current_words': 6200,
        'status': 'writing',
        'created_at': created,
        'updated_at': updated,
      },
      <String, dynamic>{
        'entity_type': 'book',
        'id': 'demo_book_2',
        'remote_id': 'demo_book_2',
        'project_id': 'demo_project_2',
        'title': 'Kathmandu to the Hills',
        'author': '',
        'genre': 'Travel',
        'summary': 'Small observations from a changing landscape.',
        'target_words': 20000,
        'current_words': 1800,
        'status': 'planning',
        'created_at': created,
        'updated_at': updated,
      },
      <String, dynamic>{
        'entity_type': 'chapter',
        'id': 'demo_chapter_1',
        'remote_id': 'demo_chapter_1',
        'book_id': 'demo_book_1',
        'project_id': 'demo_project_1',
        'number': 1,
        'title': 'A Beginning',
        'summary': 'The place where this story opens.',
        'target_words': 4000,
        'current_words': 2500,
        'status': 'drafting',
        'created_at': created,
        'updated_at': updated,
      },
      <String, dynamic>{
        'entity_type': 'chapter',
        'id': 'demo_chapter_2',
        'remote_id': 'demo_chapter_2',
        'book_id': 'demo_book_1',
        'project_id': 'demo_project_1',
        'number': 2,
        'title': 'The First Turning Point',
        'summary': 'A moment that changed the direction of the story.',
        'target_words': 4500,
        'current_words': 3700,
        'status': 'not_started',
        'created_at': created,
        'updated_at': updated,
      },
      <String, dynamic>{
        'entity_type': 'chapter',
        'id': 'demo_chapter_3',
        'remote_id': 'demo_chapter_3',
        'book_id': 'demo_book_2',
        'project_id': 'demo_project_2',
        'number': 1,
        'title': 'The Road Out of the Valley',
        'summary': 'A first note from the journey.',
        'target_words': 3500,
        'current_words': 1800,
        'status': 'researching',
        'created_at': created,
        'updated_at': updated,
      },
    ];

    for (final Map<String, dynamic> record in demoRecords) {
      final String type = JsonUtils.asString(record['entity_type']);
      final String remoteId = JsonUtils.asString(record['remote_id']);
      final Map<String, dynamic> data = Map<String, dynamic>.of(record)
        ..remove('entity_type');
      _records[type]![remoteId] = data;
      _appendChange(type, 'update', remoteId, data);
    }
  }
}

/// Durable upload-session values held by the mock backend during this app run.
class MockUploadSession {
  const MockUploadSession({
    required this.uploadId,
    required this.uploadUrl,
    required this.sourceLocalId,
    required this.sourceRemoteId,
    required this.chapterRemoteId,
    required this.sizeBytes,
    required this.chunkSize,
    required this.checksum,
    this.offset = 0,
  });

  final String uploadId;
  final String uploadUrl;
  final String sourceLocalId;
  final String sourceRemoteId;
  final String chapterRemoteId;
  final int sizeBytes;
  final int chunkSize;
  final String checksum;
  final int offset;

  MockUploadSession copyWith({int? offset}) => MockUploadSession(
        uploadId: uploadId,
        uploadUrl: uploadUrl,
        sourceLocalId: sourceLocalId,
        sourceRemoteId: sourceRemoteId,
        chapterRemoteId: chapterRemoteId,
        sizeBytes: sizeBytes,
        chunkSize: chunkSize,
        checksum: checksum,
        offset: offset ?? this.offset,
      );
}
