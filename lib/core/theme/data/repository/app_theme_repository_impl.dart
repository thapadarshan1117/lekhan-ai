import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';
import 'package:lekhan_ai/core/theme/domain/repository/app_theme_repository.dart';
import 'package:lekhan_ai/core/theme/data/datasource/local/app_theme_local_datasource.dart';
import 'package:lekhan_ai/core/theme/data/datasource/remote/app_theme_remote_datasource.dart';

class AppThemeRepositoryImpl implements AppThemeRepository {
  final AppThemeLocalDataSource local;
  final AppThemeRemoteDataSource remote;

  const AppThemeRepositoryImpl({required this.local, required this.remote});

  @override
  Future<Either<AppException, AppThemeConfig?>> getCachedActiveTheme() async {
    return local.getCachedTheme();
  }

  @override
  Future<Either<AppException, AppThemeConfig>>
      fetchAndCacheActiveTheme() async {
    final fetched = await remote.fetchActiveTheme();
    return fetched.fold(
      (l) => Left(l),
      (theme) async {
        await local.saveTheme(theme);
        return Right(theme);
      },
    );
  }

  @override
  Future<Either<AppException, AppThemeConfig?>> getActiveTheme({
    required bool forceRefresh,
    required Duration maxCacheAge,
  }) async {
    if (forceRefresh) {
      final refreshed = await fetchAndCacheActiveTheme();
      return refreshed.map((r) => r);
    }

    final cached = await local.getCachedTheme();
    final cachedAt = await local.getCachedAt();

    final cachedTheme = cached.getOrElse((_) => null);
    final cachedTime = cachedAt.getOrElse((_) => null);

    if (cachedTheme != null && cachedTime != null) {
      final age = DateTime.now().difference(cachedTime);
      if (age <= maxCacheAge) {
        return Right(cachedTheme);
      }
    }

    final refreshed = await fetchAndCacheActiveTheme();
    return refreshed.fold(
      (l) {
        // Network error? return cache if we have it.
        if (cachedTheme != null) return Right(cachedTheme);
        return Left(l);
      },
      (r) => Right(r),
    );
  }
}
