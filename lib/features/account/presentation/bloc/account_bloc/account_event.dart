part of 'account_bloc.dart';

@freezed
class AccountEvent with _$AccountEvent {
  const factory AccountEvent.changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) = ChangePasswordEvent;

  const factory AccountEvent.logout() = LogoutEvent;
}