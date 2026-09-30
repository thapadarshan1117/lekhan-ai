part of 'splash_bloc.dart';

@freezed
class SplashState with _$SplashState {
  const factory SplashState.initial() = _Initial;
  const factory SplashState.checking() = _Checking;
  const factory SplashState.authenticated() = _Authenticated;
  const factory SplashState.unauthenticated() = _Unauthenticated;
  const factory SplashState.needsOnboarding() = _NeedsOnboarding;
  const factory SplashState.firstLaunch() = _FirstLaunch;
}
