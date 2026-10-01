import 'package:fpdart/fpdart.dart';
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
  const AccountDatasourceImpl({
    NetworkService? networkService,
    TokenStorageService? tokenStorageService,
    UserLocalDataSource? userLocalDataSource,
  });

  @override
  Future<Either<AppException, String>> changePassword(
    ChangePasswordParams params,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      return const Right('Password changed successfully');
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      return const Right('Logged out successfully');
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