import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/otp_resend_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

abstract class AuthRepository {
  Future<Either<AppException, String>> register({
    required String fullName,
    required String userType,
    required String email,
    required String phone,
    required String password,
  });

  Future<Either<AppException, String>> login(
      {required String email, required String password});

  Future<Either<AppException, String>> logout();

  // Future<Either<AppException, String>> setUpAccount({
  //   required String firstName,
  //   required String lastName,
  //   required String gender,
  //   required String dob,
  // });
  // Future<Either<AppException, String>> setPassword({
  //   required String password,
  // });

  Future<Either<AppException, String>> resendOtp(
      {required OTPResendParams resendParams});
  Future<Either<AppException, Map<String, dynamic>>> verifyOtp(
      {required String otp, required String email, bool isForgot = false,
      bool isLogin = false, String hash = ''});
  Future<Either<AppException, Map<String, dynamic>>> forgotPassword(
      {required String email});
    Future<Either<AppException, String>> resetPassword({
    required String otpCode,
    required String newPassword,

  }); 




 

}
