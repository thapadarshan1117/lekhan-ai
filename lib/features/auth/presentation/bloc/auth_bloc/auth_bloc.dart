import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/forgot_password_usecase.dart';

import 'package:lekhan_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/otp_resend_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/register_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/exceptions/validation_exception.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUsecase registerUsecase;
  final LoginUsecase loginUsecase;

  final LogoutUsecase logoutUsecase;
  final OtpResendUsecase otpResendUsecase;
  final VerifyOtpUsecase verifyOtpUsecase;
  final ForgotPasswordUsecase forgotPasswordUseCase;
  final ResetPasswordUsecase resetPasswordUseCase;

  AuthBloc({
    required this.registerUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.otpResendUsecase,
    required this.verifyOtpUsecase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
  }) : super(const AuthState.initial()) {
    on<RegisterEvent>(_onRegisterEvent);
    on<LoginEvent>(_onLoginEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<ResendOtpEvent>(_onResendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onRegisterEvent(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await registerUsecase.call(
      RegisterParams(
        fullName: event.fullName,
        userType: event.userType,
        email: event.email,
        phone: event.phone,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (success) {
        // success format: "message|otpHash"
        final parts = success.split('|');
        final message = parts.first;
        final hash = parts.length > 1 ? parts.sublist(1).join('|') : '';
        emit(AuthState.registerSuccess(message, event.email, hash));
      },
    );
  }

  Future<void> _onLoginEvent(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await loginUsecase.call(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (success) => emit(AuthState.success(success)),
    );
  }

  Future<void> _onLogoutEvent(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await logoutUsecase.call();
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (success) => emit(const AuthState.logout()),
    );
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await otpResendUsecase
        .call(OTPResendParams(email: event.email, isForgot: event.isForgot));
    result.fold(
      (failure) => emit(AuthState.otpResendFailure(failure.message)),
      (success) => emit(AuthState.otpResendSuccess(success)),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await verifyOtpUsecase.call(
      OTPParams(
          otp: event.otp,
          email: event.email,
          isForgot: event.isForgot ?? false,
          isLogin: event.isLogin ?? false,
          hash: event.hash ?? ''),
    );
    result.fold(
      (failure) => emit(AuthState.otpVerifyFailed(failure.message)),
      (success) => emit(AuthState.otpVerified(
        success['message'],
        success['isSetup'] ?? true,
        success,
      )),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await forgotPasswordUseCase.call(event.email);
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (success) => emit(AuthState.otpForgotResendSuccess(
          '${success['message']}|${success['otpHash'] ?? ''}')),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await resetPasswordUseCase.call(
      ResetPasswordParams(
          otpCode: event.otpCode, newPassword: event.newPassword),
    );
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (success) => emit(AuthState.success(success)),
    );
  }
}
