import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';

abstract class AppThemeRemoteDataSource {
  Future<Either<AppException, AppThemeConfig>> fetchActiveTheme();
}

class AppThemeRemoteDataSourceImpl implements AppThemeRemoteDataSource {
  final NetworkService networkService;

  const AppThemeRemoteDataSourceImpl({required this.networkService});

  @override
  Future<Either<AppException, AppThemeConfig>> fetchActiveTheme() async {
    final res = await networkService.get(ApiConfigs.appThemes);

    return res.fold(
      (l) => Left(l),
      (r) {
        final data = r.data;
        if (data is! Map) {
          return Left(
            AppException(
              message: 'Unexpected response for themes',
              statusCode: r.statusCode,
              identifier: 'AppThemeRemoteDataSourceImpl.fetchActiveTheme',
            ),
          );
        }

        final dynamic listNode = data['data'];
        if (listNode is! List) {
          return Left(
            AppException(
              message: 'Theme list missing',
              statusCode: r.statusCode,
              identifier: 'AppThemeRemoteDataSourceImpl.fetchActiveTheme',
            ),
          );
        }

        final themes = listNode
            .whereType<Map>()
            .map((e) => AppThemeConfig.fromJson(e.cast<String, dynamic>()))
            .toList();

        if (themes.isEmpty) {
          return Left(
            AppException(
              message: 'No themes found',
              statusCode: r.statusCode,
              identifier: 'AppThemeRemoteDataSourceImpl.fetchActiveTheme',
            ),
          );
        }

        final active = themes.where((t) => t.isActive).toList();
        if (active.isNotEmpty) return Right(active.first);

        final defaults = themes.where((t) => t.isDefault).toList();
        if (defaults.isNotEmpty) return Right(defaults.first);

        return Right(themes.first);
      },
    );
  }
}
