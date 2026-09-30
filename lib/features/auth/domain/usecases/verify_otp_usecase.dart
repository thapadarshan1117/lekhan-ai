import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class VerifyOtpUsecase
    extends UsecaseWithParam<Map<String, dynamic>, OTPParams> {
  final AuthRepository authRepository;

  VerifyOtpUsecase(this.authRepository);

  @override
  Future<Either<AppException, Map<String, dynamic>>> call(
      OTPParams params) async {
    return await authRepository.verifyOtp(
        otp: params.otp,
        email: params.email,
        isForgot: params.isForgot,
        isLogin: params.isLogin,
        hash: params.hash);
  }
}

class OTPParams {
  final String otp;
  final String email;
  final bool isForgot;
  final bool isLogin;
  final String hash;

  OTPParams(
      {required this.otp,
      required this.email,
      this.isForgot = false,
      this.isLogin = false,
      this.hash = ''});
}
