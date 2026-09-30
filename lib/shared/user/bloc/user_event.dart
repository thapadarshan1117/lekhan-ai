part of 'user_bloc.dart';

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent.getUserInfo() = GetUser;
  const factory UserEvent.checkUser() = CheckUser;
  const factory UserEvent.getRemoteUser() = GetRemoteUser;

  /// Loads local user first (if available) then refreshes from remote.
  const factory UserEvent.loadProfile() = LoadProfile;
}
