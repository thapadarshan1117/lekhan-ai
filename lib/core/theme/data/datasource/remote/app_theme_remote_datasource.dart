import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';

abstract class AppThemeRemoteDataSource {
  Future<Either<AppException, AppThemeConfig>> fetchActiveTheme();
}

class AppThemeRemoteDataSourceImpl implements AppThemeRemoteDataSource {
  const AppThemeRemoteDataSourceImpl({NetworkService? networkService});

  @override
  Future<Either<AppException, AppThemeConfig>> fetchActiveTheme() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Return default theme - user will use built-in theme
      return Left(
        AppException(
          message: 'Using default theme',
          statusCode: 200,
          identifier: 'AppThemeRemoteDataSourceImpl.fetchActiveTheme',
        ),
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to fetch theme',
          statusCode: 500,
          identifier: 'AppThemeRemoteDataSourceImpl.fetchActiveTheme',
        ),
      );
    }
  }
}
