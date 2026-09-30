import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/account/domain/repositories/account_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class ChangePasswordUsecase
    extends UsecaseWithParam<String, ChangePasswordParams> {
  final AccountRepository accountRepository;

  ChangePasswordUsecase(this.accountRepository);

  @override
  Future<Either<AppException, String>> call(ChangePasswordParams params) async {
    return await accountRepository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      newPasswordConfirmation: params.newPasswordConfirmation,
    );
  }
}

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    };
  }
}