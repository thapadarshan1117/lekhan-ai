part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.success(String message,
      [Map<String, dynamic>? data]) = _Success;
  const factory AuthState.failure(AppException exception) = _Failure;
  const factory AuthState.registerSuccess(String message, String email, String hash) =
      _RegisterSuccess;
  const factory AuthState.otpResendFailure(String message) = _OtpResendFailed;
  const factory AuthState.otpResendSuccess(String message) = _OtpResendSuccess;
  const factory AuthState.otpVerifyFailed(String message) = _OtpVerifyFailed;
  const factory AuthState.otpVerified(String message, bool isSetup,
      [Map<String, dynamic>? data]) = _OtpVerified;
  const factory AuthState.logout() = _Logout;
  const factory AuthState.otpForgotResendSuccess(String message) =
      _OtpForgotResendSuccess;

  const factory AuthState.validationError(ValidationError? validationError) =
      _ValidationError;
}
