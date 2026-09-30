import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/services/app_timezone_service.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';
import 'package:lekhan_ai/shared/user/domain/usecase/get_remote_user_usecase.dart';

part 'user_bloc.freezed.dart';
part 'user_state.dart';
part 'user_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final GetRemoteUserUsecase remoteUserUsecase;

  UserBloc(this.userRepository, this.remoteUserUsecase)
      : super(const UserState.initial()) {
    on<GetUser>(_onGetUser);
    on<CheckUser>(_onCheckUser);
    on<GetRemoteUser>(_onGetRemoteUser);
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<UserState> emit,
  ) async {
    // 1) Try local first (fast).
    final local = await userRepository.getUser();
    User? cached;
    local.fold(
      (_) {},
      (user) {
        cached = user;
        AppTimezoneService.instance.setFromUser(user);
        emit(UserState.loaded(user));
      },
    );

    // 2) Refresh from remote.
    final remote = await remoteUserUsecase();
    remote.fold(
      (exception) {
        // If we already showed cached user, don't override UI with an error.
        if (cached != null) return;
        emit(UserState.error(exception.message));
      },
      (user) {
        AppTimezoneService.instance.setFromUser(user);
        emit(UserState.loaded(user));
      },
    );
  }

  Future<void> _onGetUser(
    GetUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());
    final result = await userRepository.getUser();

    result.fold(
      (exception) {
        return emit(UserState.error(exception.message));
      },
      (user) {
        AppTimezoneService.instance.setFromUser(user);
        if (kDebugMode) {}
        return emit(UserState.loaded(user));
      },
    );
  }

  Future<void> _onGetRemoteUser(
    GetRemoteUser event,
    Emitter<UserState> emit,
  ) async {
    debugPrint('UserBloc: _onGetRemoteUser called');
    emit(const UserState.loading());
    final result = await remoteUserUsecase();
    
    result.fold(
      (exception) {
        debugPrint('UserBloc: _onGetRemoteUser failed: ${exception.message}');
        return emit(UserState.error(exception.message));
      },
      (user) {
        debugPrint('UserBloc: _onGetRemoteUser success: ${user.toJson()}');
        if (kDebugMode) {}
        return emit(UserState.loaded(user));
      },
    );
  }

  Future<void> _onCheckUser(
    CheckUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());
    final result = await userRepository.hasUser();
    result.fold(
      (exception) => emit(UserState.error(exception.message)),
      (haveUser) => emit(UserState.hasUser(haveUser)),
    );
  }
}
