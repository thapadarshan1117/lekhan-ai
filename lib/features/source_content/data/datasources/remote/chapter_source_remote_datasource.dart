import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Read/delete side of source content. Creating a source happens through the
/// upload session endpoints (`/uploads/...`), because the backend must create
/// the Drive location before the bytes can be placed.
abstract class ChapterSourceRemoteDataSource {
  Future<Either<AppException, List<ChapterSourceModel>>> fetchSources({
    required String chapterRemoteId,
    int page,
    int pageSize,
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
      final Either<AppException, Response> response = await networkService.get(
        ApiConstants.chapterSources(chapterRemoteId),
        queryParameters: <String, dynamic>{'p': page, 'page_size': pageSize},
      );

      return response.fold(
        (AppException exception) =>
            Left<AppException, List<ChapterSourceModel>>(exception),
        (Response result) {
          final List<Map<String, dynamic>> records =
              JsonUtils.asMapList(result.data);
          return Right<AppException, List<ChapterSourceModel>>(
            records
                .map<ChapterSourceModel>(ChapterSourceModel.fromJson)
                .where((ChapterSourceModel source) => source.id.isNotEmpty)
                .toList(),
          );
        },
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
      final Either<AppException, Response> response =
          await networkService.get(ApiConstants.sourceDetail(remoteId));

      return response.fold(
        (AppException exception) =>
            Left<AppException, ChapterSourceModel>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.unwrap(result.data);
          if (data.isEmpty) {
            return Left<AppException, ChapterSourceModel>(
              AppException(
                message: 'The source could not be found.',
                statusCode: 404,
                identifier: '$_identifier.fetchSource.empty',
              ),
            );
          }
          return Right<AppException, ChapterSourceModel>(
            ChapterSourceModel.fromJson(data),
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
      final Either<AppException, Response> response =
          await networkService.delete(ApiConstants.sourceDetail(remoteId));

      return response.fold(
        (AppException exception) => Left<AppException, bool>(exception),
        (Response result) => const Right<AppException, bool>(true),
      );
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.deleteSource'),
      );
    }
  }
}
