part of 'notification_bloc.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = _Initial;
  const factory NotificationState.loading() = _Loading;
  const factory NotificationState.loaded({
    required List<NotificationModel> notifications,
    required String currentFilter,
    required bool isLoading,
    required int totalCount,
    required int currentPage,
    required bool hasReachedEnd,
  }) = _Loaded;
  const factory NotificationState.error(String message) = _Error;
}