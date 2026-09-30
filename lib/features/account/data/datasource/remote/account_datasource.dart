import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/features/account/domain/usecases/change_password_usecase.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/data/datasource/local/user_local_datasource.dart';

abstract class AccountDatasource {
  Future<Either<AppException, String>> changePassword(
      ChangePasswordParams params);
  Future<Either<AppException, String>> logout();
}

class AccountDatasourceImpl implements AccountDatasource {
  final NetworkService networkService;
  final TokenStorageService tokenStorageService;
  final UserLocalDataSource userLocalDataSource;

  const AccountDatasourceImpl({
    required this.networkService,
    required this.tokenStorageService,
    required this.userLocalDataSource,
  });

  @override
  Future<Either<AppException, String>> changePassword(
    ChangePasswordParams params,
  ) async {
    try {
      final response = await networkService.post(
        ApiConfigs.changePassword,
        data: params.toJson(),
      );

      return response.fold(
        (exception) => Left(exception),
        (result) {
          return Right(result.data['message']);
        },
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to change password',
          statusCode: 500,
          identifier: 'AccountDatasourceImpl.changePassword',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> logout() async {
    try {
      final userResult = await userLocalDataSource.deleteUser();

      return userResult.fold(
        (exception) => Left(exception),
        (_) async {
          await tokenStorageService.deleteTokens();
          return const Right('Logged out successfully');
        },
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to logout',
          statusCode: 500,
          identifier: 'AccountDatasourceImpl.logout',
        ),
      );
    }
  }
}