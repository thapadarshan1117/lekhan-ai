import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/onboarding/domain/repositories/splash_repository.dart';
import 'package:lekhan_ai/onboarding/domain/usecases/check_splash_status_usecase.dart';

part 'splash_event.dart';
part 'splash_state.dart';
part 'splash_bloc.freezed.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckSplashStatusUsecase checkSplashStatusUsecase;

  SplashBloc({CheckSplashStatusUsecase? checkSplashStatusUsecase})
      : checkSplashStatusUsecase =
            checkSplashStatusUsecase ?? sl<CheckSplashStatusUsecase>(),
        super(const SplashState.initial()) {
    on<CheckStatus>(_onCheckStatus);
  }

  Future<void> _onCheckStatus(
      CheckStatus event, Emitter<SplashState> emit) async {
    emit(const SplashState.checking());

    final result = await checkSplashStatusUsecase();

    result.fold(
      (error) {
        // Fallback: if anything unexpected happens, go to onboarding.
        emit(const SplashState.needsOnboarding());
      },
      (decision) {
        switch (decision) {
          case SplashDecision.authenticated:
            emit(const SplashState.authenticated());
            return;
          case SplashDecision.unauthenticated:
            emit(const SplashState.unauthenticated());
            return;
          case SplashDecision.needsOnboarding:
            emit(const SplashState.needsOnboarding());
            return;
          case SplashDecision.firstLaunch:
            emit(const SplashState.firstLaunch());
            return;
        }
      },
    );
  }
}
