import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';


class ResetPasswordUsecase
    extends UsecaseWithParam<String, ResetPasswordParams> {
  final AuthRepository authRepository;

  ResetPasswordUsecase(this.authRepository);

  @override
  Future<Either<AppException, String>> call(ResetPasswordParams params) async {
    return await authRepository.resetPassword(
      otpCode: params.otpCode,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams {
  final String otpCode;
  final String newPassword;

  ResetPasswordParams({
    required this.otpCode,
    required this.newPassword,
  });
}
