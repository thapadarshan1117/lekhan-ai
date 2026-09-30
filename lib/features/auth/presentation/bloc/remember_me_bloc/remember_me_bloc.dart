import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/remember_me_repository.dart';

part 'remember_me_bloc.freezed.dart';
part 'remember_me_event.dart';
part 'remember_me_state.dart';

class RememberMeBloc extends Bloc<RememberMeEvent, RememberMeState> {
  final RememberMeRepository rememberMeRepository;

  RememberMeBloc(this.rememberMeRepository)
      : super(const RememberMeState.initial()) {
    on<_LoadEmail>(_onLoadEmail);
    on<_DeleteEmail>(_onDeleteEmail);
    on<_SetEmail>(_onSetEmail);
  }

  Future<void> _onLoadEmail(
    _LoadEmail event,
    Emitter<RememberMeState> emit,
  ) async {
    emit(const RememberMeState.loading());
    final email = await rememberMeRepository.getEmail();
    email.fold(
      (l) => emit(RememberMeState.error(message: l.message)),
      (r) => emit(RememberMeState.loaded(email: r)),
    );
  }

  Future<void> _onDeleteEmail(
    _DeleteEmail event,
    Emitter<RememberMeState> emit,
  ) async {
    emit(const RememberMeState.loading());
    final email = await rememberMeRepository.deleteEmail();
    email.fold(
      (l) => emit(RememberMeState.error(message: l.message)),
      (r) => emit(const RememberMeState.initial()),
    );
  }

  Future<void> _onSetEmail(
    _SetEmail event,
    Emitter<RememberMeState> emit,
  ) async {
    emit(const RememberMeState.loading());
    final email = await rememberMeRepository.setEmail(email: event.email);
    email.fold(
      (l) => emit(RememberMeState.error(message: l.message)),
      (r) => emit(RememberMeState.loaded(email: event.email)),
    );
  }
}
