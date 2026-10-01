import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Reads remote source metadata. The binary is never downloaded from Drive
/// directly; the backend may expose an authorized download URL when an online
/// preview is needed.
abstract class ChapterSourceRemoteDataSource {
  Future<Either<AppException, List<ChapterSourceModel>>> fetchSources({
    required String chapterRemoteId,
    int page = 1,
    int pageSize = 50,
  });

  Future<Either<AppException, ChapterSourceModel>> fetchSource(
    String remoteId,
  );

  Future<Either<AppException, bool>> deleteSource(String remoteId);
}

class ChapterSourceRemoteDataSourceImpl
    implements ChapterSourceRemoteDataSource {
  const ChapterSourceRemoteDataSourceImpl({required this.networkService});

  final NetworkService networkService;

  static const String _identifier = 'ChapterSourceRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<ChapterSourceModel>>> fetchSources({
    required String chapterRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final Either<AppException, Response> result = await networkService.get(
        ApiConstants.chapterSources(chapterRemoteId),
        queryParameters: <String, dynamic>{'page': page, 'page_size': pageSize},
      );
      return result.fold(
        (AppException error) =>
            Left<AppException, List<ChapterSourceModel>>(error),
        (Response response) => Right<AppException, List<ChapterSourceModel>>(
          RemoteJsonUtils.records(response.data)
              .map<ChapterSourceModel>(
                (Map<String, dynamic> item) => _sourceFromRemote(item),
              )
              .where((ChapterSourceModel item) => item.remoteId?.isNotEmpty == true)
              .toList(growable: false),
        ),
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
      final Either<AppException, Response> result = await networkService.get(
        ApiConstants.sourceDetail(remoteId),
      );
      return result.fold(
        (AppException error) => Left<AppException, ChapterSourceModel>(error),
        (Response response) {
          final Map<String, dynamic> data =
              RemoteJsonUtils.withRemoteIdentity(
            RemoteJsonUtils.detailRecord(response.data, entityKey: 'source'),
            id: remoteId,
          );
          return Right<AppException, ChapterSourceModel>(
            _sourceFromRemote(data),
          );
        },
      );
    } catch (error) {
      return Left<AppException, ChapterSourceModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchSource'),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> deleteSource(String remoteId) async {
    try {
      final Either<AppException, Response> result =
          await networkService.delete(ApiConstants.sourceDetail(remoteId));
      return result.fold(
        (AppException error) => Left<AppException, bool>(error),
        (Response _) => const Right<AppException, bool>(true),
      );
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.deleteSource'),
      );
    }
  }

  ChapterSourceModel _sourceFromRemote(Map<String, dynamic> raw) {
    final Map<String, dynamic> data =
        RemoteJsonUtils.withRemoteIdentity(raw);
    data['name'] = JsonUtils.asString(
      raw['name'],
      fallback: JsonUtils.asString(raw['title'], fallback: 'Source file'),
    );
    data['file_size'] = JsonUtils.asInt(
      raw['file_size'] ?? raw['size'] ?? raw['size_bytes'],
    );
    data['duration_seconds'] = raw['duration_seconds'] ?? raw['duration'];
    data['local_path'] = JsonUtils.asString(raw['local_path']);
    data['upload_status'] = JsonUtils.asString(
      raw['upload_status'],
      fallback: UploadStatus.uploaded.value,
    );
    data['processing_status'] = JsonUtils.asString(
      raw['processing_status'],
      fallback: JsonUtils.asString(raw['processing']),
    );
    data['is_dirty'] = false;
    return ChapterSourceModel.fromJson(data);
  }
}
