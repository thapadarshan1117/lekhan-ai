import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

// Mock data
const List<Map<String, dynamic>> _mockBooksData = [
  {
    'id': 'book_001',
    'title': 'The Great Gatsby',
    'description': 'A classic novel about dreams and ambition',
    'author': 'F. Scott Fitzgerald',
    'cover_image': 'https://via.placeholder.com/300x400?text=Gatsby',
    'status': 'published',
    'created_at': '2024-01-01T00:00:00Z',
    'updated_at': '2024-01-15T00:00:00Z',
  },
  {
    'id': 'book_002',
    'title': '1984',
    'description': 'A dystopian novel about totalitarianism',
    'author': 'George Orwell',
    'cover_image': 'https://via.placeholder.com/300x400?text=1984',
    'status': 'published',
    'created_at': '2024-01-02T00:00:00Z',
    'updated_at': '2024-01-14T00:00:00Z',
  },
  {
    'id': 'book_003',
    'title': 'To Kill a Mockingbird',
    'description': 'A story of racial injustice and moral growth',
    'author': 'Harper Lee',
    'cover_image': 'https://via.placeholder.com/300x400?text=Mockingbird',
    'status': 'published',
    'created_at': '2024-01-03T00:00:00Z',
    'updated_at': '2024-01-13T00:00:00Z',
  },
];

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
  const BookRemoteDataSourceImpl({NetworkService? networkService});

  static const String _identifier = 'BookRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<BookModel>>> fetchBooks({
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      return Right<AppException, List<BookModel>>(
        _mockBooksData
            .map<BookModel>(BookModel.fromJson)
            .where((BookModel item) => item.id.isNotEmpty)
            .toList(),
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      final bookData = _mockBooksData.firstWhere(
        (book) => book['id'] == remoteId,
        orElse: () => {},
      );

      if (bookData.isEmpty) {
        return Left<AppException, BookModel>(
          AppException(
            message: 'The book could not be found.',
            statusCode: 404,
            identifier: '$_identifier.fetchBook.empty',
          ),
        );
      }

      return Right<AppException, BookModel>(BookModel.fromJson(bookData));
    } catch (error) {
      return Left<AppException, BookModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchBook'),
      );
    }
  }
}
