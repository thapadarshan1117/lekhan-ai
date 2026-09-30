abstract class NotificationPermissionState {}

class NotificationPermissionInitial extends NotificationPermissionState {}

class NotificationPermissionLoading extends NotificationPermissionState {}

class NotificationPermissionStatus extends NotificationPermissionState {
  final bool authorized;
  final bool tokenSynced;
  NotificationPermissionStatus(
      {required this.authorized, this.tokenSynced = false});
}

class NotificationPermissionAuthorized extends NotificationPermissionState {}

class NotificationPermissionDenied extends NotificationPermissionState {}

class NotificationPermissionError extends NotificationPermissionState {
  final String message;
  NotificationPermissionError(this.message);
}
