import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/mock/mock_lekhan_backend.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/remote/chapter_remote_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// UI-only chapters remote backed by the shared in-memory mock server.
class MockChapterRemoteDataSource implements ChapterRemoteDataSource {
  const MockChapterRemoteDataSource({required this.backend});

  final MockLekhanBackend backend;
  static const String _identifier = 'MockChapterRemoteDataSource';

  @override
  Future<Either<AppException, List<ChapterModel>>> fetchChapters({
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      await Future<void>.delayed(backend.latency);
      return Right<AppException, List<ChapterModel>>(
        backend
            .fetchRecords(
              'chapter',
              parentField: 'book_id',
              page: page,
              pageSize: pageSize,
              parentRemoteId: parentRemoteId,
            )
            .map<ChapterModel>(
              (Map<String, dynamic> record) =>
                  _toModel(record, parentRemoteId: parentRemoteId),
            )
            .toList(growable: false),
      );
    } catch (error) {
      return Left<AppException, List<ChapterModel>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchChapters'),
      );
    }
  }

  @override
  Future<Either<AppException, ChapterModel>> fetchChapter(
    String remoteId,
  ) async {
    try {
      await Future<void>.delayed(backend.latency);
      final Map<String, dynamic>? record =
          backend.fetchRecord('chapter', remoteId);
      if (record == null) {
        return Left<AppException, ChapterModel>(
          AppException(
            message: 'Chapter not found in the mock workspace.',
            statusCode: 404,
            identifier: '$_identifier.fetchChapter.notFound',
          ),
        );
      }
      return Right<AppException, ChapterModel>(_toModel(record));
    } catch (error) {
      return Left<AppException, ChapterModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchChapter'),
      );
    }
  }

  ChapterModel _toModel(
    Map<String, dynamic> record, {
    String? parentRemoteId,
  }) {
    final Map<String, dynamic> json = RemoteJsonUtils.withRemoteIdentity(record);
    final dynamic rawBookId = record['book_id'] ?? record['book'];
    final String bookRemoteId = rawBookId is Map
        ? RemoteJsonUtils.remoteId(JsonUtils.asMap(rawBookId))
        : JsonUtils.asString(rawBookId, fallback: parentRemoteId ?? '');
    json['book_id'] = bookRemoteId;
    final Map<String, dynamic>? parentBook =
        bookRemoteId.isEmpty ? null : backend.fetchRecord('book', bookRemoteId);
    json['project_id'] = JsonUtils.asString(
      record['project_id'],
      fallback: JsonUtils.asString(parentBook?['project_id']),
    );
    json['title'] = JsonUtils.asString(
      record['title'],
      fallback: JsonUtils.asString(record['name']),
    );
    json['summary'] = JsonUtils.asString(
      record['summary'],
      fallback: JsonUtils.asString(record['description']),
    );
    json['number'] = JsonUtils.asInt(
      record['number'] ?? record['order'] ?? record['chapter_number'],
    );
    json['target_words'] = JsonUtils.asInt(record['target_words']);
    json['current_words'] = JsonUtils.asInt(record['current_words']);
    return ChapterModel.fromJson(json);
  }
}
