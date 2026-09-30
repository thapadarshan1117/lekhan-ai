// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sources_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SourcesEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function(File file, String? displayName) fileAdded,
    required TResult Function(String localPath) recordingAdded,
    required TResult Function(String sourceId) deleted,
    required TResult Function(String sourceId) uploadRetried,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function(File file, String? displayName)? fileAdded,
    TResult? Function(String localPath)? recordingAdded,
    TResult? Function(String sourceId)? deleted,
    TResult? Function(String sourceId)? uploadRetried,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function(File file, String? displayName)? fileAdded,
    TResult Function(String localPath)? recordingAdded,
    TResult Function(String sourceId)? deleted,
    TResult Function(String sourceId)? uploadRetried,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_FileAdded value) fileAdded,
    required TResult Function(_RecordingAdded value) recordingAdded,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_UploadRetried value) uploadRetried,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_FileAdded value)? fileAdded,
    TResult? Function(_RecordingAdded value)? recordingAdded,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_UploadRetried value)? uploadRetried,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_FileAdded value)? fileAdded,
    TResult Function(_RecordingAdded value)? recordingAdded,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_UploadRetried value)? uploadRetried,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourcesEventCopyWith<$Res> {
  factory $SourcesEventCopyWith(
    SourcesEvent value,
    $Res Function(SourcesEvent) then,
  ) = _$SourcesEventCopyWithImpl<$Res, SourcesEvent>;
}

/// @nodoc
class _$SourcesEventCopyWithImpl<$Res, $Val extends SourcesEvent>
    implements $SourcesEventCopyWith<$Res> {
  _$SourcesEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$StartedImplCopyWith<$Res> {
  factory _$$StartedImplCopyWith(
    _$StartedImpl value,
    $Res Function(_$StartedImpl) then,
  ) = __$$StartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StartedImplCopyWithImpl<$Res>
    extends _$SourcesEventCopyWithImpl<$Res, _$StartedImpl>
    implements _$$StartedImplCopyWith<$Res> {
  __$$StartedImplCopyWithImpl(
    _$StartedImpl _value,
    $Res Function(_$StartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StartedImpl implements _Started {
  const _$StartedImpl();

  @override
  String toString() {
    return 'SourcesEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function(File file, String? displayName) fileAdded,
    required TResult Function(String localPath) recordingAdded,
    required TResult Function(String sourceId) deleted,
    required TResult Function(String sourceId) uploadRetried,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function(File file, String? displayName)? fileAdded,
    TResult? Function(String localPath)? recordingAdded,
    TResult? Function(String sourceId)? deleted,
    TResult? Function(String sourceId)? uploadRetried,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function(File file, String? displayName)? fileAdded,
    TResult Function(String localPath)? recordingAdded,
    TResult Function(String sourceId)? deleted,
    TResult Function(String sourceId)? uploadRetried,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_FileAdded value) fileAdded,
    required TResult Function(_RecordingAdded value) recordingAdded,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_UploadRetried value) uploadRetried,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_FileAdded value)? fileAdded,
    TResult? Function(_RecordingAdded value)? recordingAdded,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_UploadRetried value)? uploadRetried,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_FileAdded value)? fileAdded,
    TResult Function(_RecordingAdded value)? recordingAdded,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_UploadRetried value)? uploadRetried,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class _Started implements SourcesEvent {
  const factory _Started() = _$StartedImpl;
}

/// @nodoc
abstract class _$$RefreshedImplCopyWith<$Res> {
  factory _$$RefreshedImplCopyWith(
    _$RefreshedImpl value,
    $Res Function(_$RefreshedImpl) then,
  ) = __$$RefreshedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RefreshedImplCopyWithImpl<$Res>
    extends _$SourcesEventCopyWithImpl<$Res, _$RefreshedImpl>
    implements _$$RefreshedImplCopyWith<$Res> {
  __$$RefreshedImplCopyWithImpl(
    _$RefreshedImpl _value,
    $Res Function(_$RefreshedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RefreshedImpl implements _Refreshed {
  const _$RefreshedImpl();

  @override
  String toString() {
    return 'SourcesEvent.refreshed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RefreshedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function(File file, String? displayName) fileAdded,
    required TResult Function(String localPath) recordingAdded,
    required TResult Function(String sourceId) deleted,
    required TResult Function(String sourceId) uploadRetried,
  }) {
    return refreshed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function(File file, String? displayName)? fileAdded,
    TResult? Function(String localPath)? recordingAdded,
    TResult? Function(String sourceId)? deleted,
    TResult? Function(String sourceId)? uploadRetried,
  }) {
    return refreshed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function(File file, String? displayName)? fileAdded,
    TResult Function(String localPath)? recordingAdded,
    TResult Function(String sourceId)? deleted,
    TResult Function(String sourceId)? uploadRetried,
    required TResult orElse(),
  }) {
    if (refreshed != null) {
      return refreshed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_FileAdded value) fileAdded,
    required TResult Function(_RecordingAdded value) recordingAdded,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_UploadRetried value) uploadRetried,
  }) {
    return refreshed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_FileAdded value)? fileAdded,
    TResult? Function(_RecordingAdded value)? recordingAdded,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_UploadRetried value)? uploadRetried,
  }) {
    return refreshed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_FileAdded value)? fileAdded,
    TResult Function(_RecordingAdded value)? recordingAdded,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_UploadRetried value)? uploadRetried,
    required TResult orElse(),
  }) {
    if (refreshed != null) {
      return refreshed(this);
    }
    return orElse();
  }
}

abstract class _Refreshed implements SourcesEvent {
  const factory _Refreshed() = _$RefreshedImpl;
}

/// @nodoc
abstract class _$$FileAddedImplCopyWith<$Res> {
  factory _$$FileAddedImplCopyWith(
    _$FileAddedImpl value,
    $Res Function(_$FileAddedImpl) then,
  ) = __$$FileAddedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({File file, String? displayName});
}

/// @nodoc
class __$$FileAddedImplCopyWithImpl<$Res>
    extends _$SourcesEventCopyWithImpl<$Res, _$FileAddedImpl>
    implements _$$FileAddedImplCopyWith<$Res> {
  __$$FileAddedImplCopyWithImpl(
    _$FileAddedImpl _value,
    $Res Function(_$FileAddedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? file = null, Object? displayName = freezed}) {
    return _then(
      _$FileAddedImpl(
        file: null == file
            ? _value.file
            : file // ignore: cast_nullable_to_non_nullable
                  as File,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$FileAddedImpl implements _FileAdded {
  const _$FileAddedImpl({required this.file, this.displayName});

  @override
  final File file;
  @override
  final String? displayName;

  @override
  String toString() {
    return 'SourcesEvent.fileAdded(file: $file, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileAddedImpl &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, file, displayName);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileAddedImplCopyWith<_$FileAddedImpl> get copyWith =>
      __$$FileAddedImplCopyWithImpl<_$FileAddedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function(File file, String? displayName) fileAdded,
    required TResult Function(String localPath) recordingAdded,
    required TResult Function(String sourceId) deleted,
    required TResult Function(String sourceId) uploadRetried,
  }) {
    return fileAdded(file, displayName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function(File file, String? displayName)? fileAdded,
    TResult? Function(String localPath)? recordingAdded,
    TResult? Function(String sourceId)? deleted,
    TResult? Function(String sourceId)? uploadRetried,
  }) {
    return fileAdded?.call(file, displayName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function(File file, String? displayName)? fileAdded,
    TResult Function(String localPath)? recordingAdded,
    TResult Function(String sourceId)? deleted,
    TResult Function(String sourceId)? uploadRetried,
    required TResult orElse(),
  }) {
    if (fileAdded != null) {
      return fileAdded(file, displayName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_FileAdded value) fileAdded,
    required TResult Function(_RecordingAdded value) recordingAdded,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_UploadRetried value) uploadRetried,
  }) {
    return fileAdded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_FileAdded value)? fileAdded,
    TResult? Function(_RecordingAdded value)? recordingAdded,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_UploadRetried value)? uploadRetried,
  }) {
    return fileAdded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_FileAdded value)? fileAdded,
    TResult Function(_RecordingAdded value)? recordingAdded,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_UploadRetried value)? uploadRetried,
    required TResult orElse(),
  }) {
    if (fileAdded != null) {
      return fileAdded(this);
    }
    return orElse();
  }
}

abstract class _FileAdded implements SourcesEvent {
  const factory _FileAdded({
    required final File file,
    final String? displayName,
  }) = _$FileAddedImpl;

  File get file;
  String? get displayName;

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileAddedImplCopyWith<_$FileAddedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RecordingAddedImplCopyWith<$Res> {
  factory _$$RecordingAddedImplCopyWith(
    _$RecordingAddedImpl value,
    $Res Function(_$RecordingAddedImpl) then,
  ) = __$$RecordingAddedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String localPath});
}

/// @nodoc
class __$$RecordingAddedImplCopyWithImpl<$Res>
    extends _$SourcesEventCopyWithImpl<$Res, _$RecordingAddedImpl>
    implements _$$RecordingAddedImplCopyWith<$Res> {
  __$$RecordingAddedImplCopyWithImpl(
    _$RecordingAddedImpl _value,
    $Res Function(_$RecordingAddedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? localPath = null}) {
    return _then(
      _$RecordingAddedImpl(
        localPath: null == localPath
            ? _value.localPath
            : localPath // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RecordingAddedImpl implements _RecordingAdded {
  const _$RecordingAddedImpl({required this.localPath});

  @override
  final String localPath;

  @override
  String toString() {
    return 'SourcesEvent.recordingAdded(localPath: $localPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingAddedImpl &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, localPath);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingAddedImplCopyWith<_$RecordingAddedImpl> get copyWith =>
      __$$RecordingAddedImplCopyWithImpl<_$RecordingAddedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function(File file, String? displayName) fileAdded,
    required TResult Function(String localPath) recordingAdded,
    required TResult Function(String sourceId) deleted,
    required TResult Function(String sourceId) uploadRetried,
  }) {
    return recordingAdded(localPath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function(File file, String? displayName)? fileAdded,
    TResult? Function(String localPath)? recordingAdded,
    TResult? Function(String sourceId)? deleted,
    TResult? Function(String sourceId)? uploadRetried,
  }) {
    return recordingAdded?.call(localPath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function(File file, String? displayName)? fileAdded,
    TResult Function(String localPath)? recordingAdded,
    TResult Function(String sourceId)? deleted,
    TResult Function(String sourceId)? uploadRetried,
    required TResult orElse(),
  }) {
    if (recordingAdded != null) {
      return recordingAdded(localPath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_FileAdded value) fileAdded,
    required TResult Function(_RecordingAdded value) recordingAdded,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_UploadRetried value) uploadRetried,
  }) {
    return recordingAdded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_FileAdded value)? fileAdded,
    TResult? Function(_RecordingAdded value)? recordingAdded,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_UploadRetried value)? uploadRetried,
  }) {
    return recordingAdded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_FileAdded value)? fileAdded,
    TResult Function(_RecordingAdded value)? recordingAdded,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_UploadRetried value)? uploadRetried,
    required TResult orElse(),
  }) {
    if (recordingAdded != null) {
      return recordingAdded(this);
    }
    return orElse();
  }
}

abstract class _RecordingAdded implements SourcesEvent {
  const factory _RecordingAdded({required final String localPath}) =
      _$RecordingAddedImpl;

  String get localPath;

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingAddedImplCopyWith<_$RecordingAddedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeletedImplCopyWith<$Res> {
  factory _$$DeletedImplCopyWith(
    _$DeletedImpl value,
    $Res Function(_$DeletedImpl) then,
  ) = __$$DeletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String sourceId});
}

/// @nodoc
class __$$DeletedImplCopyWithImpl<$Res>
    extends _$SourcesEventCopyWithImpl<$Res, _$DeletedImpl>
    implements _$$DeletedImplCopyWith<$Res> {
  __$$DeletedImplCopyWithImpl(
    _$DeletedImpl _value,
    $Res Function(_$DeletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sourceId = null}) {
    return _then(
      _$DeletedImpl(
        null == sourceId
            ? _value.sourceId
            : sourceId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DeletedImpl implements _Deleted {
  const _$DeletedImpl(this.sourceId);

  @override
  final String sourceId;

  @override
  String toString() {
    return 'SourcesEvent.deleted(sourceId: $sourceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeletedImpl &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sourceId);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeletedImplCopyWith<_$DeletedImpl> get copyWith =>
      __$$DeletedImplCopyWithImpl<_$DeletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function(File file, String? displayName) fileAdded,
    required TResult Function(String localPath) recordingAdded,
    required TResult Function(String sourceId) deleted,
    required TResult Function(String sourceId) uploadRetried,
  }) {
    return deleted(sourceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function(File file, String? displayName)? fileAdded,
    TResult? Function(String localPath)? recordingAdded,
    TResult? Function(String sourceId)? deleted,
    TResult? Function(String sourceId)? uploadRetried,
  }) {
    return deleted?.call(sourceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function(File file, String? displayName)? fileAdded,
    TResult Function(String localPath)? recordingAdded,
    TResult Function(String sourceId)? deleted,
    TResult Function(String sourceId)? uploadRetried,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted(sourceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_FileAdded value) fileAdded,
    required TResult Function(_RecordingAdded value) recordingAdded,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_UploadRetried value) uploadRetried,
  }) {
    return deleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_FileAdded value)? fileAdded,
    TResult? Function(_RecordingAdded value)? recordingAdded,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_UploadRetried value)? uploadRetried,
  }) {
    return deleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_FileAdded value)? fileAdded,
    TResult Function(_RecordingAdded value)? recordingAdded,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_UploadRetried value)? uploadRetried,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted(this);
    }
    return orElse();
  }
}

abstract class _Deleted implements SourcesEvent {
  const factory _Deleted(final String sourceId) = _$DeletedImpl;

  String get sourceId;

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeletedImplCopyWith<_$DeletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UploadRetriedImplCopyWith<$Res> {
  factory _$$UploadRetriedImplCopyWith(
    _$UploadRetriedImpl value,
    $Res Function(_$UploadRetriedImpl) then,
  ) = __$$UploadRetriedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String sourceId});
}

/// @nodoc
class __$$UploadRetriedImplCopyWithImpl<$Res>
    extends _$SourcesEventCopyWithImpl<$Res, _$UploadRetriedImpl>
    implements _$$UploadRetriedImplCopyWith<$Res> {
  __$$UploadRetriedImplCopyWithImpl(
    _$UploadRetriedImpl _value,
    $Res Function(_$UploadRetriedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sourceId = null}) {
    return _then(
      _$UploadRetriedImpl(
        null == sourceId
            ? _value.sourceId
            : sourceId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UploadRetriedImpl implements _UploadRetried {
  const _$UploadRetriedImpl(this.sourceId);

  @override
  final String sourceId;

  @override
  String toString() {
    return 'SourcesEvent.uploadRetried(sourceId: $sourceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadRetriedImpl &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sourceId);

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadRetriedImplCopyWith<_$UploadRetriedImpl> get copyWith =>
      __$$UploadRetriedImplCopyWithImpl<_$UploadRetriedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function(File file, String? displayName) fileAdded,
    required TResult Function(String localPath) recordingAdded,
    required TResult Function(String sourceId) deleted,
    required TResult Function(String sourceId) uploadRetried,
  }) {
    return uploadRetried(sourceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function(File file, String? displayName)? fileAdded,
    TResult? Function(String localPath)? recordingAdded,
    TResult? Function(String sourceId)? deleted,
    TResult? Function(String sourceId)? uploadRetried,
  }) {
    return uploadRetried?.call(sourceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function(File file, String? displayName)? fileAdded,
    TResult Function(String localPath)? recordingAdded,
    TResult Function(String sourceId)? deleted,
    TResult Function(String sourceId)? uploadRetried,
    required TResult orElse(),
  }) {
    if (uploadRetried != null) {
      return uploadRetried(sourceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_FileAdded value) fileAdded,
    required TResult Function(_RecordingAdded value) recordingAdded,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_UploadRetried value) uploadRetried,
  }) {
    return uploadRetried(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_FileAdded value)? fileAdded,
    TResult? Function(_RecordingAdded value)? recordingAdded,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_UploadRetried value)? uploadRetried,
  }) {
    return uploadRetried?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_FileAdded value)? fileAdded,
    TResult Function(_RecordingAdded value)? recordingAdded,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_UploadRetried value)? uploadRetried,
    required TResult orElse(),
  }) {
    if (uploadRetried != null) {
      return uploadRetried(this);
    }
    return orElse();
  }
}

abstract class _UploadRetried implements SourcesEvent {
  const factory _UploadRetried(final String sourceId) = _$UploadRetriedImpl;

  String get sourceId;

  /// Create a copy of SourcesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadRetriedImplCopyWith<_$UploadRetriedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SourcesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChapterSource> sources, bool isBusy, String? message)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourcesStateCopyWith<$Res> {
  factory $SourcesStateCopyWith(
    SourcesState value,
    $Res Function(SourcesState) then,
  ) = _$SourcesStateCopyWithImpl<$Res, SourcesState>;
}

/// @nodoc
class _$SourcesStateCopyWithImpl<$Res, $Val extends SourcesState>
    implements $SourcesStateCopyWith<$Res> {
  _$SourcesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$SourcesStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'SourcesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChapterSource> sources, bool isBusy, String? message)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements SourcesState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$SourcesStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'SourcesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChapterSource> sources, bool isBusy, String? message)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements SourcesState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ChapterSource> sources, bool isBusy, String? message});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$SourcesStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sources = null,
    Object? isBusy = null,
    Object? message = freezed,
  }) {
    return _then(
      _$LoadedImpl(
        sources: null == sources
            ? _value._sources
            : sources // ignore: cast_nullable_to_non_nullable
                  as List<ChapterSource>,
        isBusy: null == isBusy
            ? _value.isBusy
            : isBusy // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl({
    required final List<ChapterSource> sources,
    this.isBusy = false,
    this.message,
  }) : _sources = sources;

  final List<ChapterSource> _sources;
  @override
  List<ChapterSource> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  /// True while an add/delete/retry is in flight, so the UI can disable the
  /// buttons instead of letting the user queue the same file twice.
  @override
  @JsonKey()
  final bool isBusy;

  /// A line for the snackbar: either a failure or a confirmation.
  @override
  final String? message;

  @override
  String toString() {
    return 'SourcesState.loaded(sources: $sources, isBusy: $isBusy, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            (identical(other.isBusy, isBusy) || other.isBusy == isBusy) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_sources),
    isBusy,
    message,
  );

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(sources, isBusy, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(sources, isBusy, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChapterSource> sources, bool isBusy, String? message)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(sources, isBusy, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements SourcesState {
  const factory _Loaded({
    required final List<ChapterSource> sources,
    final bool isBusy,
    final String? message,
  }) = _$LoadedImpl;

  List<ChapterSource> get sources;

  /// True while an add/delete/retry is in flight, so the UI can disable the
  /// buttons instead of letting the user queue the same file twice.
  bool get isBusy;

  /// A line for the snackbar: either a failure or a confirmation.
  String? get message;

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$SourcesStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'SourcesState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<ChapterSource> sources,
      bool isBusy,
      String? message,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ChapterSource> sources, bool isBusy, String? message)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements SourcesState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of SourcesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
