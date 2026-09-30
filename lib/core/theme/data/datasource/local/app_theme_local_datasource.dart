import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/globals.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';

abstract class AppThemeLocalDataSource {
  Future<Either<AppException, AppThemeConfig?>> getCachedTheme();
  Future<Either<AppException, DateTime?>> getCachedAt();
  Future<Either<AppException, bool>> saveTheme(AppThemeConfig theme);
  Future<Either<AppException, bool>> clearTheme();
}

class AppThemeLocalDataSourceImpl implements AppThemeLocalDataSource {
  final StorageService storageService;

  const AppThemeLocalDataSourceImpl({required this.storageService});

  @override
  Future<Either<AppException, AppThemeConfig?>> getCachedTheme() async {
    try {
      final data = await storageService.get(appThemeLocalDataSourceKey);
      if (data == null) return const Right(null);

      final decoded = jsonDecode(data.toString());
      if (decoded is! Map<String, dynamic>) return const Right(null);

      return Right(AppThemeConfig.fromJson(decoded));
    } catch (e) {
      return Left(
        AppException(
          message: 'Error while reading cached theme',
          statusCode: 1,
          identifier: 'AppThemeLocalDataSourceImpl.getCachedTheme',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, DateTime?>> getCachedAt() async {
    try {
      final raw = await storageService.get(appThemeCachedAtKey);
      if (raw == null) return const Right(null);
      return Right(DateTime.tryParse(raw.toString()));
    } catch (e) {
      return Left(
        AppException(
          message: 'Error while reading cached theme timestamp',
          statusCode: 1,
          identifier: 'AppThemeLocalDataSourceImpl.getCachedAt',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> saveTheme(AppThemeConfig theme) async {
    try {
      final ok = await storageService.set(
        appThemeLocalDataSourceKey,
        jsonEncode(theme.toJson()),
      );
      if (ok) {
        await storageService.set(
          appThemeCachedAtKey,
          DateTime.now().toIso8601String(),
        );
      }
      return Right(ok);
    } catch (e) {
      return Left(
        AppException(
          message: 'Error while saving theme',
          statusCode: 1,
          identifier: 'AppThemeLocalDataSourceImpl.saveTheme',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> clearTheme() async {
    try {
      final a = await storageService.remove(appThemeLocalDataSourceKey);
      final b = await storageService.remove(appThemeCachedAtKey);
      return Right(a && b);
    } catch (e) {
      return Left(
        AppException(
          message: 'Error while clearing theme cache',
          statusCode: 1,
          identifier: 'AppThemeLocalDataSourceImpl.clearTheme',
        ),
      );
    }
  }
}
