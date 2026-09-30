import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/features/account/domain/usecases/change_password_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

part 'account_bloc.freezed.dart';
part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final ChangePasswordUsecase changePasswordUsecase;

  AccountBloc({
    required this.changePasswordUsecase,
  }) : super(const AccountState.initial()) {
    on<ChangePasswordEvent>(_onChangePassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountState.loading());
    final result = await changePasswordUsecase.call(
      ChangePasswordParams(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
        newPasswordConfirmation: event.newPasswordConfirmation,
      ),
    );
    result.fold(
      (failure) => emit(AccountState.failure(failure)),
      (success) => emit(AccountState.success(success)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AccountState> emit,
  ) async {
    // Implement logout logic if needed
    emit(const AccountState.success('Logged out successfully'));
  }
}