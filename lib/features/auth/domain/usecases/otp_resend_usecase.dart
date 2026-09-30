import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';


class OtpResendUsecase extends UsecaseWithParam<String, OTPResendParams> {
  final AuthRepository authRepository;

  OtpResendUsecase(this.authRepository);

  @override
  Future<Either<AppException, String>> call(OTPResendParams params) async {
    return await authRepository.resendOtp(resendParams: params);
  }
}


class OTPResendParams{
  final String email;
  final bool isForgot;

  OTPResendParams({required this.email, this.isForgot=false});
}

