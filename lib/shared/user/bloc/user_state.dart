part of 'user_bloc.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = Initial;
  const factory UserState.loading() = Loading;
  const factory UserState.loaded(User user) = Loaded;
  const factory UserState.hasUser(bool haveUser) = HasUser;
  const factory UserState.error(String message) = Error;
}
