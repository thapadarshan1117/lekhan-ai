import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class BookRemoteDataSource {
  /// All books of the account, or only those of one project/book when
  /// [parentRemoteId] is given.
  Future<Either<AppException, List<BookModel>>> fetchBooks({
    String? parentRemoteId,
    int page,
    int pageSize,
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

      final Either<AppException, Response> response = await networkService.get(
        endpoint,
        queryParameters: <String, dynamic>{
          'p': page,
          'page_size': pageSize,
        },
      );

      return response.fold(
        (AppException exception) => Left<AppException, List<BookModel>>(exception),
        (Response result) {
          final List<Map<String, dynamic>> records =
              JsonUtils.asMapList(result.data);
          return Right<AppException, List<BookModel>>(
            records
                .map<BookModel>(BookModel.fromJson)
                .where((BookModel item) => item.id.isNotEmpty)
                .toList(),
          );
        },
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
      final Either<AppException, Response> response =
          await networkService.get(ApiConstants.bookDetail(remoteId));

      return response.fold(
        (AppException exception) => Left<AppException, BookModel>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.unwrap(result.data);
          if (data.isEmpty) {
            return Left<AppException, BookModel>(
              AppException(
                message: 'The book could not be found.',
                statusCode: 404,
                identifier: '$_identifier.fetchBook.empty',
              ),
            );
          }
          return Right<AppException, BookModel>(BookModel.fromJson(data));
        },
      );
    } catch (error) {
      return Left<AppException, BookModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchBook'),
      );
    }
  }
}
