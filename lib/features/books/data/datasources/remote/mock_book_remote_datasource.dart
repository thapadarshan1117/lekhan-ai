import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/mock/mock_lekhan_backend.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/books/data/datasources/remote/book_remote_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// UI-only books remote backed by the shared in-memory mock server.
class MockBookRemoteDataSource implements BookRemoteDataSource {
  const MockBookRemoteDataSource({required this.backend});

  final MockLekhanBackend backend;
  static const String _identifier = 'MockBookRemoteDataSource';

  @override
  Future<Either<AppException, List<BookModel>>> fetchBooks({
    int page = 1,
    int pageSize = 50,
    String? parentRemoteId,
  }) async {
    try {
      await Future<void>.delayed(backend.latency);
      return Right<AppException, List<BookModel>>(
        backend
            .fetchRecords(
              'book',
              parentField: 'project_id',
              page: page,
              pageSize: pageSize,
              parentRemoteId: parentRemoteId,
            )
            .map<BookModel>(
              (Map<String, dynamic> record) =>
                  _toModel(record, parentRemoteId: parentRemoteId),
            )
            .toList(growable: false),
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
      await Future<void>.delayed(backend.latency);
      final Map<String, dynamic>? record = backend.fetchRecord('book', remoteId);
      if (record == null) {
        return Left<AppException, BookModel>(
          AppException(
            message: 'Book not found in the mock workspace.',
            statusCode: 404,
            identifier: '$_identifier.fetchBook.notFound',
          ),
        );
      }
      return Right<AppException, BookModel>(_toModel(record));
    } catch (error) {
      return Left<AppException, BookModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchBook'),
      );
    }
  }

  BookModel _toModel(
    Map<String, dynamic> record, {
    String? parentRemoteId,
  }) {
    final Map<String, dynamic> json = RemoteJsonUtils.withRemoteIdentity(record);
    json['project_id'] = JsonUtils.asString(
      record['project_id'],
      fallback: JsonUtils.asString(record['project'], fallback: parentRemoteId ?? ''),
    );
    json['name'] = JsonUtils.asString(
      record['name'],
      fallback: JsonUtils.asString(record['title']),
    );
    json['description'] = JsonUtils.asString(record['description']);
    return BookModel.fromJson(json);
  }
}
