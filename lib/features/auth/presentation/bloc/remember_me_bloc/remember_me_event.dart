part of 'remember_me_bloc.dart';

@freezed
class RememberMeEvent with _$RememberMeEvent {
  const factory RememberMeEvent.loadEmail() = _LoadEmail;
  const factory RememberMeEvent.deleteEmail() = _DeleteEmail;
  const factory RememberMeEvent.setEmail({required String email}) = _SetEmail;
}
