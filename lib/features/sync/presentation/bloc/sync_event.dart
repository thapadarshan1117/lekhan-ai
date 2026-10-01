part of 'sync_bloc.dart';

@freezed
class SyncEvent with _$SyncEvent {
  const factory SyncEvent.started() = _Started;
  const factory SyncEvent.refreshed() = _Refreshed;
  const factory SyncEvent.retryFailed() = _RetryFailed;
}
