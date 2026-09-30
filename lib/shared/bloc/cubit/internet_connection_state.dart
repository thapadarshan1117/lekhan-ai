part of 'internet_connection_cubit.dart';

enum ConnectivityStatus {
  connected,
  disconnected
}

@freezed
class InternetConnectionState with _$InternetConnectionState {
  const factory InternetConnectionState({
    @Default(ConnectivityStatus.disconnected) ConnectivityStatus status,
  }) = _InternetConnectionState;
}
