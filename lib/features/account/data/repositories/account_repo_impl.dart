import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/account/data/datasource/remote/account_datasource.dart';
import 'package:lekhan_ai/features/account/domain/repositories/account_repository.dart';
import 'package:lekhan_ai/features/account/domain/usecases/change_password_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountDatasource accountDatasource;

  AccountRepositoryImpl(this.accountDatasource);

  @override
  Future<Either<AppException, String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return await accountDatasource.changePassword(
      ChangePasswordParams(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      ),
    );
  }

  @override
  Future<Either<AppException, String>> logout() async {
    return await accountDatasource.logout();
  }
}