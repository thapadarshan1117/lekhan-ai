import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lekhan_ai/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:lekhan_ai/onboarding/domain/repositories/splash_repository.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class SplashRepositoryImpl implements SplashRepository {
  final OnboardingRepository onboardingRepository;
  final TokenStorageService tokenStorageService;
  final StorageService storageService;

  // Flag to track first launch
  static const String _firstLaunchKey = 'app_first_launch_after_install';

  SplashRepositoryImpl({
    required this.onboardingRepository,
    required this.tokenStorageService,
    required this.storageService,
  });

  @override
  Future<Either<AppException, SplashDecision>> checkStatus() async {
    // Start timing - ensure minimum display time
    final startTime = DateTime.now();

    // Check if this is first launch after installation
    final isFirstLaunch = !(await storageService.has(_firstLaunchKey));

    if (isFirstLaunch) {
      // On first launch after install, clear any potentially persisted data
      await storageService.clear();
      await storageService.set(_firstLaunchKey, 'launched');

      // Always show onboarding on fresh install
      final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
      const minDisplayTimeMs = 2000;

      if (elapsedMs < minDisplayTimeMs) {
        await Future.delayed(
            Duration(milliseconds: minDisplayTimeMs - elapsedMs));
      }

      // Mark onboarded status to avoid re-showing onboarding on next launch
      await onboardingRepository.setOnboardStatus();

      return const Right(SplashDecision.firstLaunch);
    }

    // Normal flow for subsequent launches
    final accessToken = await tokenStorageService.getAccessToken();
    
    // Check if token exists and is not expired
    final hasValidToken = _isTokenValid(accessToken);

    // Smooth transition (minimum display)
    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
    const minDisplayTimeMs = 1500;

    if (elapsedMs < minDisplayTimeMs) {
      await Future.delayed(
          Duration(milliseconds: minDisplayTimeMs - elapsedMs));
    }

    if (hasValidToken) {
      return const Right(SplashDecision.authenticated);
    }

    final isOnBoard = await onboardingRepository.isOnboard();

    return isOnBoard.fold(
      (error) {
        // Fallback behavior: if onboarding status can't be read, show onboarding.
        return const Right(SplashDecision.needsOnboarding);
      },
      (done) async {
        if (done) {
          return const Right(SplashDecision.unauthenticated);
        }

        await onboardingRepository.setOnboardStatus();
        return const Right(SplashDecision.needsOnboarding);
      },
    );
  }

  /// Check if JWT token is valid (exists and not expired)
  bool _isTokenValid(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      // JWT tokens have 3 parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      
      // Add padding if needed for base64 decoding
      final paddedPayload = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );

      final decodedBytes = _decodeBase64(paddedPayload);
      if (decodedBytes == null) {
        return false;
      }

      final decodedString = String.fromCharCodes(decodedBytes);
      final jsonMap = _parseJson(decodedString);
      
      if (jsonMap == null) {
        return false;
      }

      // Check if token has an 'exp' (expiration) claim
      final exp = jsonMap['exp'];
      if (exp == null) {
        // If no expiration claim, consider it valid
        return true;
      }

      // exp is in seconds, convert to milliseconds and compare with current time
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        (exp as int) * 1000,
      );
      
      return DateTime.now().isBefore(expirationTime);
    } catch (e) {
      debugPrint('❌ Error validating token: $e');
      return false;
    }
  }

  /// Decode base64 string safely
  List<int>? _decodeBase64(String str) {
    try {
      return base64Decode(str);
    } catch (e) {
      return null;
    }
  }

  /// Parse JSON safely
  Map<String, dynamic>? _parseJson(String jsonString) {
    try {
      // Assuming jsonDecode is available from dart:convert
      return _simpleJsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Simple JSON decoder for extracting 'exp' field
  Map<String, dynamic>? _simpleJsonDecode(String jsonString) {
    try {
      // Remove braces and split by comma
      final content = jsonString.replaceAll('{', '').replaceAll('}', '');
      final pairs = content.split(',');
      
      final result = <String, dynamic>{};
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final key = keyValue[0].replaceAll('"', '').trim();
          final value = keyValue[1].trim();
          
          if (key == 'exp') {
            result[key] = int.tryParse(value) ?? 0;
          }
        }
      }
      
      return result.isNotEmpty ? result : null;
    } catch (e) {
      return null;
    }
  }
}
