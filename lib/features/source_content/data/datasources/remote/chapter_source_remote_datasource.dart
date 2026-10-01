import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

// Mock data
const List<Map<String, dynamic>> _mockSourcesData = [
  {
    'id': 'source_001',
    'chapter_id': 'chapter_001',
    'title': 'Chapter 1 Audio',
    'type': 'audio',
    'url': 'https://via.placeholder.com/audio.mp3',
    'duration': 3600,
    'created_at': '2024-01-01T00:00:00Z',
  },
  {
    'id': 'source_002',
    'chapter_id': 'chapter_001',
    'title': 'Chapter 1 Video',
    'type': 'video',
    'url': 'https://via.placeholder.com/video.mp4',
    'duration': 7200,
    'created_at': '2024-01-01T00:00:00Z',
  },
];

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
  const ChapterSourceRemoteDataSourceImpl({NetworkService? networkService});

  static const String _identifier = 'ChapterSourceRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<ChapterSourceModel>>> fetchSources({
    required String chapterRemoteId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      final sources = _mockSourcesData
          .where((source) => source['chapter_id'] == chapterRemoteId)
          .toList();

      return Right<AppException, List<ChapterSourceModel>>(
        sources
            .map<ChapterSourceModel>(ChapterSourceModel.fromJson)
            .where((ChapterSourceModel source) => source.id.isNotEmpty)
            .toList(),
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      final sourceData = _mockSourcesData.firstWhere(
        (source) => source['id'] == remoteId,
        orElse: () => {},
      );

      if (sourceData.isEmpty) {
        return Left<AppException, ChapterSourceModel>(
          AppException(
            message: 'The source could not be found.',
            statusCode: 404,
            identifier: '$_identifier.fetchSource.empty',
          ),
        );
      }

      return Right<AppException, ChapterSourceModel>(
        ChapterSourceModel.fromJson(sourceData),
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      return const Right<AppException, bool>(true);
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.deleteSource'),
      );
    }
  }
}
