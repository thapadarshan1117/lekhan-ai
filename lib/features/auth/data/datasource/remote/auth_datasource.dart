import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/config/api/api_configs.dart';
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

class AuthDataSourceImpl implements AuthDatasource {
  final NetworkService networkService;
  final TokenStorageService tokenStorageService;
  final UserRepository userRepository;
  final FCMTokenService fcmTokenService;

  AuthDataSourceImpl({
    required this.networkService,
    required this.userRepository,
    required this.tokenStorageService,
    required this.fcmTokenService,
  });

  @override
  Future<Either<AppException, String>> register({
    required String fullName,
    required String userType,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      
      final requestData = {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      };
      

      final response = await networkService.post(
        ApiConfigs.register,
        data: requestData,
      );
      return response.fold(
        (exception) => Left(exception),
      (result) async {
          log("Register result: ${result.data}");
          final otpHash = result.data["data"]?["otpHash"] as String? ?? '';
          return Right('${result.data["message"]}|$otpHash');
        },
      );
    } catch (e) {
      return Left(
        AppException(
          message: "Something went wrong",
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
    final requestData = <String, dynamic>{
      'email': email,
      'password': password,
    };

    final response = await networkService.post(
      ApiConfigs.login,
      data: requestData,
    );

    return response.fold(
      (exception) {
        return Left(exception);
      },
      (result) async {
        try {
          // Handle both wrapped and unwrapped response formats
          final responseData = result.data is Map ? result.data : {};
          final data = responseData["data"] is Map ? responseData["data"] : responseData;

          // Extract tokens from response
          final accessToken = data["access_token"] ?? data["accessToken"];
          final refreshToken = data["refresh_token"] ?? data["refreshToken"];
          final userId = data["user_id"] as String? ?? '';

          if (accessToken != null) {
            tokenStorageService.saveAccessToken(accessToken as String);
          }
          if (refreshToken != null) {
            tokenStorageService.saveRefreshToken(refreshToken as String);
          }

          // Temporarily handle null user data - save if available
          final userJson = data["user"];
          if (userJson != null) {
            userRepository.saveUser(
              user: User.fromJson(
                Map<String, dynamic>.from(userJson as Map),
              ),
            );
          } else if (userId.isNotEmpty) {
            // TODO: Remove this temporary workaround once API returns user data
            // For now, create a minimal user with just the user_id from response
            userRepository.saveUser(
              user: User(
                userId: userId,
                name: email,
                email: email,
                phone: null,
                profileImage: null,
                isActive: true,
                whatsapp: null,
                role: null,
                branch: null,
                country: null,
                timezone: null,
                isTeamMember: null,
              ),
            );
          }

          return Right(data["message"] as String? ?? "Login successful");
        } catch (e) {
          return Left(
            AppException(
              message: "Error processing login response: ${e.toString()}",
              statusCode: 1,
              identifier: 'AuthDataSource.login',
            ),
          );
        }
      },
    );
  } catch (e) {
    return Left(
      AppException(
        message: "Something went wrong",
        statusCode: 1,
        identifier: '${e.toString()}\nAuthDataSource.loginUser',
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
      final response = await networkService.post(
        resendParams.isForgot
            ? ApiConfigs.forgotPasswordResend
            : ApiConfigs.resendOtp,
        data: {'email': resendParams.email},
      );
      return response.fold((exception) => Left(exception), (result) async {
        return Right(result.data["message"]);
      });
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
   
      
      final requestData = {
        'otp': otp,
        'email': email,
        'hash': hash,
      };
      

      
      final response = await networkService.post(
        isForgot
            ? ApiConfigs.verifyForgotPasswordOtp
            : ApiConfigs.verifyOtp,
        data: requestData,
      );
      return response.fold((exception) => Left(exception), (result) async {
        // For signup OTP: tokens are returned
        if (!isForgot) {
          final tokens = result.data["data"]?["tokens"];
          if (tokens != null) {
            tokenStorageService.saveAccessToken(tokens["access"]);
            tokenStorageService.saveRefreshToken(tokens["refresh"]);
          }

          final userJson = result.data["data"]?["user"];
          if (userJson != null) {
            userRepository.saveUser(user: User.fromJson(userJson));
          }
        }

        return Right({
          "message": result.data["message"],
          "isSetup": result.data["data"]?["user"]?["is_verified"] ?? true,
          // For forgot-password OTP: resetToken is needed for the reset step
          if (isForgot)
            "resetToken": result.data["data"]?["resetToken"] ?? '',
        });
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
  //IF FCM TOKEN IS NULL DONR USE ON MAP
  Future<Either<AppException, Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await networkService.post(
        ApiConfigs.forgotPassword,
        data: {'email': email},
      );
      return response.fold((exception) => Left(exception), (result) async {
        final otpHash = result.data["data"]?["otpHash"] as String? ?? '';
        return Right({
          "message": result.data["message"],
          "otpHash": otpHash,
        });
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
      final response = await networkService.post(
        ApiConfigs.resetPassword,
        data: {
          'resetToken': otpCode,
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        },
      );
      return response.fold((exception) => Left(exception), (result) async {
        return Right(result.data["message"]);
      });
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
