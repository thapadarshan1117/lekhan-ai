import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';

abstract class AppThemeRepository {
  Future<Either<AppException, AppThemeConfig?>> getCachedActiveTheme();

  /// Fetches active theme from server and updates cache.
  Future<Either<AppException, AppThemeConfig>> fetchAndCacheActiveTheme();

  /// Returns cached theme if it's fresh enough, otherwise refreshes.
  Future<Either<AppException, AppThemeConfig?>> getActiveTheme({
    required bool forceRefresh,
    required Duration maxCacheAge,
  });
}
