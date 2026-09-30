part of 'sources_bloc.dart';

@freezed
class SourcesEvent with _$SourcesEvent {
  const factory SourcesEvent.started() = _Started;

  const factory SourcesEvent.refreshed() = _Refreshed;

  /// A file the user picked from the device.
  const factory SourcesEvent.fileAdded({
    required File file,
    String? displayName,
  }) = _FileAdded;

  /// A recording that has just been stopped (already inside the store).
  const factory SourcesEvent.recordingAdded({required String localPath}) =
      _RecordingAdded;

  const factory SourcesEvent.deleted(String sourceId) = _Deleted;

  const factory SourcesEvent.uploadRetried(String sourceId) = _UploadRetried;
}
