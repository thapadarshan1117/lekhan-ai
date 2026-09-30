part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.register({
    required String fullName,
    required String userType,
    required String email,
    required String phone,
    required String password,
  }) = RegisterEvent;

  const factory AuthEvent.login({
    required String email,
    required String password,
  }) = LoginEvent;

  const factory AuthEvent.logout() = LogoutEvent;

  const factory AuthEvent.resendOtp({
    required String email,
    required bool isForgot,
  }) = ResendOtpEvent;

  const factory AuthEvent.verifyOtp(
      {required String otp,
      required String email,
      bool? isLogin,
      bool? isForgot,
      String? hash}) = VerifyOtpEvent;

  const factory AuthEvent.forgotPassword({
    required String email,
  }) = ForgotPasswordEvent;

  const factory AuthEvent.resetPassword({
    required String otpCode,
    required String newPassword,
  }) = ResetPasswordEvent;
}
