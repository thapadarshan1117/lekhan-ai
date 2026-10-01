part of 'sync_bloc.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState.initial() = _Initial;
  const factory SyncState.loading() = _Loading;
  const factory SyncState.loaded({required SyncStats stats}) = _Loaded;
  const factory SyncState.error(String message) = _Error;
}
