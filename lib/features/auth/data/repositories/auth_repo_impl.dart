import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/data/datasource/remote/auth_datasource.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/otp_resend_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource authDatasource;

  AuthRepositoryImpl(this.authDatasource);

  @override
  Future<Either<AppException, String>> register({
    required String fullName,
    required String userType,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await authDatasource.register(
      fullName: fullName,
      userType: userType,
      email: email,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<Either<AppException, String>> login(
      {required String email, required String password}) async {
    return await authDatasource.login(email: email, password: password);
  }

  @override
  Future<Either<AppException, String>> logout() async {
    return await authDatasource.logout();
  }






  // @override
  // Future<Either<AppException, String>> setUpAccount({
  //   required String firstName,
  //   required String lastName,
  //   required String gender,
  //   required String dob,
  // }) async {
  //   return await authDatasource.setUpAccount(
  //       firstName: firstName, lastName: lastName,
  //       gender: gender, dob: dob);
  // }

  @override
  Future<Either<AppException, String>> resendOtp(
      {required OTPResendParams resendParams}) async {
    return await authDatasource.resendOtp(resendParams: resendParams);
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> verifyOtp(
      {required String otp,
      required String email,
      bool isForgot = false,
      bool isLogin = false,
      String hash = ''}) async {
    return await authDatasource.verifyOtp(
        otp: otp, email: email, isForgot: isForgot, isLogin: isLogin, hash: hash);
  }
 @override
  Future<Either<AppException, Map<String, dynamic>>> forgotPassword(
      {required String email}) async {
    return await authDatasource.forgotPassword(email: email);
  }

  @override
  Future<Either<AppException, String>> resetPassword({
    required String otpCode,
    required String newPassword,
  }) async {
    return await authDatasource.resetPassword(
      otpCode: otpCode,
      newPassword: newPassword,
    );
  }


  // @override
  // Future<Either<AppException, String>> setPassword({required String password}) {
  //   return authDatasource.setPassword(password: password);
  // }
  

}

