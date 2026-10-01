import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

// Mock data
const List<Map<String, dynamic>> _mockChaptersData = [
  {
    'id': 'chapter_001',
    'book_id': 'book_001',
    'title': 'Chapter 1: Introduction',
    'description': 'The beginning of the story',
    'order': 1,
    'status': 'published',
    'created_at': '2024-01-01T00:00:00Z',
  },
  {
    'id': 'chapter_002',
    'book_id': 'book_001',
    'title': 'Chapter 2: Rising Action',
    'description': 'The plot thickens',
    'order': 2,
    'status': 'published',
    'created_at': '2024-01-02T00:00:00Z',
  },
  {
    'id': 'chapter_003',
    'book_id': 'book_002',
    'title': 'Chapter 1: The Party',
    'description': 'Where it all begins',
    'order': 1,
    'status': 'published',
    'created_at': '2024-01-03T00:00:00Z',
  },
];

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
  const ChapterRemoteDataSourceImpl({NetworkService? networkService});

  static const String _identifier = 'ChapterRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<ChapterModel>>> fetchChapters({
    String? parentRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Filter by parent if provided
      final chapters = parentRemoteId == null || parentRemoteId.isEmpty
          ? _mockChaptersData
          : _mockChaptersData
              .where((ch) => ch['book_id'] == parentRemoteId)
              .toList();

      return Right<AppException, List<ChapterModel>>(
        chapters
            .map<ChapterModel>(ChapterModel.fromJson)
            .where((ChapterModel item) => item.id.isNotEmpty)
            .toList(),
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      final chapterData = _mockChaptersData.firstWhere(
        (ch) => ch['id'] == remoteId,
        orElse: () => {},
      );

      if (chapterData.isEmpty) {
        return Left<AppException, ChapterModel>(
          AppException(
            message: 'The chapter could not be found.',
            statusCode: 404,
            identifier: '$_identifier.fetchChapter.empty',
          ),
        );
      }

      return Right<AppException, ChapterModel>(ChapterModel.fromJson(chapterData));
    } catch (error) {
      return Left<AppException, ChapterModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchChapter'),
      );
    }
  }
}
