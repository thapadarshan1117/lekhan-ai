import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class BookRemoteDataSource {
  /// All books of the account, or only those belonging to [parentRemoteId].
  Future<Either<AppException, List<BookModel>>> fetchBooks({
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  });

  Future<Either<AppException, BookModel>> fetchBook(String remoteId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  const BookRemoteDataSourceImpl({required this.networkService});

  final NetworkService networkService;

  static const String _identifier = 'BookRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<BookModel>>> fetchBooks({
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final String endpoint = parentRemoteId == null || parentRemoteId.isEmpty
          ? ApiConstants.books
          : ApiConstants.projectBooks(parentRemoteId);
      final Either<AppException, Response> result = await networkService.get(
        endpoint,
        queryParameters: <String, dynamic>{
          'page': page,
          'page_size': pageSize,
          if (parentRemoteId != null && parentRemoteId.isNotEmpty)
            'project_id': parentRemoteId,
        },
      );

      return result.fold(
        (AppException error) => Left<AppException, List<BookModel>>(error),
        (Response response) => Right<AppException, List<BookModel>>(
          RemoteJsonUtils.records(response.data)
              .map<BookModel>(
                (Map<String, dynamic> item) =>
                    _bookFromRemote(item, parentRemoteId: parentRemoteId),
              )
              .where((BookModel item) => item.remoteId?.isNotEmpty == true)
              .toList(growable: false),
        ),
      );
    } catch (error) {
      return Left<AppException, List<BookModel>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchBooks'),
      );
    }
  }

  @override
  Future<Either<AppException, BookModel>> fetchBook(String remoteId) async {
    try {
      final Either<AppException, Response> result = await networkService.get(
        ApiConstants.bookDetail(remoteId),
      );
      return result.fold(
        (AppException error) => Left<AppException, BookModel>(error),
        (Response response) {
          final Map<String, dynamic> data =
              RemoteJsonUtils.withRemoteIdentity(
            RemoteJsonUtils.detailRecord(response.data, entityKey: 'book'),
            id: remoteId,
          );
          return Right<AppException, BookModel>(_bookFromRemote(data));
        },
      );
    } catch (error) {
      return Left<AppException, BookModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchBook'),
      );
    }
  }

  BookModel _bookFromRemote(
    Map<String, dynamic> raw, {
    String? parentRemoteId,
  }) {
    final Map<String, dynamic> data =
        RemoteJsonUtils.withRemoteIdentity(raw);
    data['project_id'] = _relationId(
      raw['project_id'] ?? raw['project'] ?? parentRemoteId,
    );
    data['title'] = JsonUtils.asString(
      raw['title'],
      fallback: JsonUtils.asString(raw['name']),
    );
    data['summary'] = JsonUtils.asString(
      raw['summary'],
      fallback: JsonUtils.asString(raw['description']),
    );
    data['cover_image_url'] = JsonUtils.asStringOrNull(
      raw['cover_image_url'] ?? raw['cover_image'],
    );
    return BookModel.fromJson(data);
  }

  static String _relationId(dynamic value) {
    if (value is Map) {
      return RemoteJsonUtils.remoteId(JsonUtils.asMap(value));
    }
    return JsonUtils.asString(value);
  }
}
