import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChapterRemoteDataSource {
  /// All chapters of the account, or only those of one project/book when
  /// [parentRemoteId] is given.
  Future<Either<AppException, List<ChapterModel>>> fetchChapters({
    String? parentRemoteId,
    int page,
    int pageSize,
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

      final Either<AppException, Response> response = await networkService.get(
        endpoint,
        queryParameters: <String, dynamic>{
          'p': page,
          'page_size': pageSize,
        },
      );

      return response.fold(
        (AppException exception) => Left<AppException, List<ChapterModel>>(exception),
        (Response result) {
          final List<Map<String, dynamic>> records =
              JsonUtils.asMapList(result.data);
          return Right<AppException, List<ChapterModel>>(
            records
                .map<ChapterModel>(ChapterModel.fromJson)
                .where((ChapterModel item) => item.id.isNotEmpty)
                .toList(),
          );
        },
      );
    } catch (error) {
      return Left<AppException, List<ChapterModel>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchChapters'),
      );
    }
  }

  @override
  Future<Either<AppException, ChapterModel>> fetchChapter(String remoteId) async {
    try {
      final Either<AppException, Response> response =
          await networkService.get(ApiConstants.chapterDetail(remoteId));

      return response.fold(
        (AppException exception) => Left<AppException, ChapterModel>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.unwrap(result.data);
          if (data.isEmpty) {
            return Left<AppException, ChapterModel>(
              AppException(
                message: 'The chapter could not be found.',
                statusCode: 404,
                identifier: '$_identifier.fetchChapter.empty',
              ),
            );
          }
          return Right<AppException, ChapterModel>(ChapterModel.fromJson(data));
        },
      );
    } catch (error) {
      return Left<AppException, ChapterModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchChapter'),
      );
    }
  }
}
