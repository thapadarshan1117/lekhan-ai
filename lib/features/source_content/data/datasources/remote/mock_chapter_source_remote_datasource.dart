import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/mock/mock_lekhan_backend.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/remote/chapter_source_remote_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// UI-only source metadata remote. Binary transfers are handled by the mock
/// resumable uploader; this datasource never downloads from Drive.
class MockChapterSourceRemoteDataSource
    implements ChapterSourceRemoteDataSource {
  const MockChapterSourceRemoteDataSource({required this.backend});

  final MockLekhanBackend backend;
  static const String _identifier = 'MockChapterSourceRemoteDataSource';

  @override
  Future<Either<AppException, List<ChapterSourceModel>>> fetchSources({
    required String chapterRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      await Future<void>.delayed(backend.latency);
      return Right<AppException, List<ChapterSourceModel>>(
        backend
            .fetchRecords(
              'chapter_source',
              parentField: 'chapter_id',
              parentRemoteId: chapterRemoteId,
              page: page,
              pageSize: pageSize,
            )
            .map<ChapterSourceModel>(_toModel)
            .toList(growable: false),
      );
    } catch (error) {
      return Left<AppException, List<ChapterSourceModel>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchSources'),
      );
    }
  }

  @override
  Future<Either<AppException, ChapterSourceModel>> fetchSource(
    String remoteId,
  ) async {
    try {
      await Future<void>.delayed(backend.latency);
      final Map<String, dynamic>? record =
          backend.fetchRecord('chapter_source', remoteId);
      if (record == null) {
        return Left<AppException, ChapterSourceModel>(
          AppException(
            message: 'Source not found in the mock workspace.',
            statusCode: 404,
            identifier: '$_identifier.fetchSource.notFound',
          ),
        );
      }
      return Right<AppException, ChapterSourceModel>(_toModel(record));
    } catch (error) {
      return Left<AppException, ChapterSourceModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchSource'),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> deleteSource(String remoteId) async {
    try {
      final bool deleted =
          await backend.deleteRecord('chapter_source', remoteId);
      return Right<AppException, bool>(deleted);
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.deleteSource'),
      );
    }
  }

  ChapterSourceModel _toModel(Map<String, dynamic> record) {
    final Map<String, dynamic> json = RemoteJsonUtils.withRemoteIdentity(record);
    json['name'] = JsonUtils.asString(
      record['name'],
      fallback: JsonUtils.asString(record['title'], fallback: 'Source file'),
    );
    json['file_size'] = JsonUtils.asInt(
      record['file_size'] ?? record['size'] ?? record['size_bytes'],
    );
    json['duration_seconds'] =
        record['duration_seconds'] ?? record['duration'];
    json['local_path'] = JsonUtils.asString(record['local_path']);
    json['upload_status'] = JsonUtils.asString(
      record['upload_status'],
      fallback: 'uploaded',
    );
    json['processing_status'] = JsonUtils.asString(
      record['processing_status'],
      fallback: JsonUtils.asString(record['processing']),
    );
    json['is_dirty'] = false;
    return ChapterSourceModel.fromJson(json);
  }
}
