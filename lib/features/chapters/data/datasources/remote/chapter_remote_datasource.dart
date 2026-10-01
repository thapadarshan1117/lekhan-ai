import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChapterRemoteDataSource {
  /// All chapters of the account, or only those belonging to [parentRemoteId].
  Future<Either<AppException, List<ChapterModel>>> fetchChapters({
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  });

  Future<Either<AppException, ChapterModel>> fetchChapter(String remoteId);
}

class ChapterRemoteDataSourceImpl implements ChapterRemoteDataSource {
  const ChapterRemoteDataSourceImpl({required this.networkService});

  final NetworkService networkService;

  static const String _identifier = 'ChapterRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<ChapterModel>>> fetchChapters({
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final String endpoint = parentRemoteId == null || parentRemoteId.isEmpty
          ? ApiConstants.chapters
          : ApiConstants.bookChapters(parentRemoteId);
      final Either<AppException, Response> result = await networkService.get(
        endpoint,
        queryParameters: <String, dynamic>{
          'page': page,
          'page_size': pageSize,
          if (parentRemoteId != null && parentRemoteId.isNotEmpty)
            'book_id': parentRemoteId,
        },
      );

      return result.fold(
        (AppException error) => Left<AppException, List<ChapterModel>>(error),
        (Response response) => Right<AppException, List<ChapterModel>>(
          RemoteJsonUtils.records(response.data)
              .map<ChapterModel>(
                (Map<String, dynamic> item) => _chapterFromRemote(
                  item,
                  parentRemoteId: parentRemoteId,
                ),
              )
              .where((ChapterModel item) => item.remoteId?.isNotEmpty == true)
              .toList(growable: false),
        ),
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
      final Either<AppException, Response> result = await networkService.get(
        ApiConstants.chapterDetail(remoteId),
      );
      return result.fold(
        (AppException error) => Left<AppException, ChapterModel>(error),
        (Response response) {
          final Map<String, dynamic> data =
              RemoteJsonUtils.withRemoteIdentity(
            RemoteJsonUtils.detailRecord(response.data, entityKey: 'chapter'),
            id: remoteId,
          );
          return Right<AppException, ChapterModel>(_chapterFromRemote(data));
        },
      );
    } catch (error) {
      return Left<AppException, ChapterModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchChapter'),
      );
    }
  }

  ChapterModel _chapterFromRemote(
    Map<String, dynamic> raw, {
    String? parentRemoteId,
  }) {
    final Map<String, dynamic> data =
        RemoteJsonUtils.withRemoteIdentity(raw);
    data['book_id'] = _relationId(
      raw['book_id'] ?? raw['book'] ?? parentRemoteId,
    );
    data['title'] = JsonUtils.asString(
      raw['title'],
      fallback: JsonUtils.asString(raw['name']),
    );
    data['summary'] = JsonUtils.asString(
      raw['summary'],
      fallback: JsonUtils.asString(raw['description']),
    );
    data['number'] = JsonUtils.asInt(
      raw['number'] ?? raw['order'] ?? raw['chapter_number'],
    );
    data['target_words'] = JsonUtils.asInt(raw['target_words']);
    data['current_words'] = JsonUtils.asInt(raw['current_words']);
    return ChapterModel.fromJson(data);
  }

  static String _relationId(dynamic value) {
    if (value is Map) {
      return RemoteJsonUtils.remoteId(JsonUtils.asMap(value));
    }
    return JsonUtils.asString(value);
  }
}
