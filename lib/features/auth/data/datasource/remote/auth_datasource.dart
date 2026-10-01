import 'dart:async';
import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/otp_resend_usecase.dart';
import 'package:lekhan_ai/shared/data/local/fcm_token_service.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';

abstract class AuthDatasource {
  Future<Either<AppException, String>> register({
    required String fullName,
    required String userType,
    required String email,
    required String phone,
    required String password,
  });

  Future<Either<AppException, String>> login({
    required String email,
    required String password,
  });

  Future<Either<AppException, String>> logout();

  Future<Either<AppException, Map<String, dynamic>>> verifyOtp({
    required String otp,
    required String email,
    bool isForgot,
    bool isLogin,
    String hash,
  });
  Future<Either<AppException, String>> resendOtp({
    required OTPResendParams resendParams,
  });

  Future<Either<AppException, Map<String, dynamic>>> forgotPassword({
    required String email,
  });
  Future<Either<AppException, String>> resetPassword({
    required String otpCode,
    required String newPassword,
  });
}

/// Mock implementation for testing without backend
class AuthDataSourceImpl implements AuthDatasource {
  final TokenStorageService tokenStorageService;
  final UserRepository userRepository;

  AuthDataSourceImpl({
    required this.tokenStorageService,
    required this.userRepository,
    NetworkService? networkService, // Ignored - using mock implementation
    FCMTokenService? fcmTokenService, // Ignored - using mock implementation
  });

  static const String _mockAccessToken = 'mock_access_token_12345';
  static const String _mockRefreshToken = 'mock_refresh_token_67890';

  @override
  Future<Either<AppException, String>> register({
    required String fullName,
    required String userType,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      log("Mock Register: $email");
      const String mockOtpHash = 'mock_otp_hash_abc123';
      return const Right('Registration successful|$mockOtpHash');
    } catch (e) {
      return Left(
        AppException(
          message: "Mock registration failed",
          statusCode: 1,
          identifier: '${e.toString()}\nAuthDataSource.register',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      log("Mock Login: $email");

      // Save mock tokens
      await tokenStorageService.saveAccessToken(_mockAccessToken);
      await tokenStorageService.saveRefreshToken(_mockRefreshToken);

      // Create and save mock user
      final mockUser = User(
        userId: 'mock_user_123',
        name: email.split('@').first,
        email: email,
        phone: null,
        profileImage: null,
        isActive: true,
        whatsapp: null,
        role: 'user',
        branch: null,
        country: null,
        timezone: null,
        isTeamMember: null,
      );

      await userRepository.saveUser(user: mockUser);

      return const Right("Mock login successful");
    } catch (e) {
      return Left(
        AppException(
          message: "Something went wrong",
          statusCode: 1,
          identifier: '${e.toString()}\nAuthDataSource.login',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> logout() async {
    try {
      await tokenStorageService.deleteAccessToken();
      await tokenStorageService.deleteTokens();
      await userRepository.deleteUser();
      return const Right("Logged out successfully");
    } catch (e) {
      return Left(
        AppException(
          message: "Something went wrong",
          statusCode: 1,
          identifier: '${e.toString()}\nAuthRemoteDatasource.logOut',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> resendOtp({
    required OTPResendParams resendParams,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right("Mock OTP resent successfully");
    } catch (e) {
      return Left(
        AppException(
          message: "Something went wrong",
          statusCode: 1,
          identifier: '${e.toString()}\nAuthRemoteDatasource.resendOtp',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> verifyOtp({
    required String otp,
    required String email,
    bool isForgot = false,
    bool isLogin = false,
    String hash = '',
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      if (!isForgot) {
        // For signup OTP: save tokens and user
        await tokenStorageService.saveAccessToken(_mockAccessToken);
        await tokenStorageService.saveRefreshToken(_mockRefreshToken);

        final mockUser = User(
          userId: 'mock_user_123',
          name: email.split('@').first,
          email: email,
          phone: null,
          profileImage: null,
          isActive: true,
          whatsapp: null,
          role: 'user',
          branch: null,
          country: null,
          timezone: null,
          isTeamMember: null,
        );

        await userRepository.saveUser(user: mockUser);
      }

      return Right({
        "message": "Mock OTP verified successfully",
        "isSetup": true,
        if (isForgot) "resetToken": "mock_reset_token_xyz789",
      });
    } catch (e) {
      return Left(
        AppException(
          message: e.toString(),
          statusCode: 1,
          identifier: '${e.toString()}\nAuthRemoteDatasource.verifyOtp',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      return const Right({
        "message": "Mock forgot password OTP sent",
        "otpHash": "mock_otp_hash_forgot_123",
      });
    } catch (e) {
      return Left(
        AppException(
          message: "Something went wrong",
          statusCode: 1,
          identifier: '${e.toString()}\nAuthRemoteDatasource.forgotPassword',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> resetPassword({
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      return const Right("Mock password reset successfully");
    } catch (e) {
      return Left(
        AppException(
          message: "Something went wrong",
          statusCode: 1,
          identifier: '${e.toString()}\nAuthRemoteDatasource.resetPassword',
        ),
      );
    }
  }
}
