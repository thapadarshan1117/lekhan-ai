part of 'account_bloc.dart';

@freezed
class AccountState with _$AccountState {
  const factory AccountState.initial() = _Initial;
  const factory AccountState.loading() = _Loading;
  const factory AccountState.success(String message) = _Success;
  const factory AccountState.failure(AppException exception) = _Failure;
}