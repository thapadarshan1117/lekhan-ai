part of 'remember_me_bloc.dart';

@freezed
class RememberMeState with _$RememberMeState {
  const factory RememberMeState.initial() = _Initial;
  const factory RememberMeState.loading() = _Loading;
  const factory RememberMeState.loaded({required String email}) = _Loaded;
  const factory RememberMeState.error({required String message}) = _Error;
}
