// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'internet_connection_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$InternetConnectionState {
  ConnectivityStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of InternetConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InternetConnectionStateCopyWith<InternetConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InternetConnectionStateCopyWith<$Res> {
  factory $InternetConnectionStateCopyWith(
    InternetConnectionState value,
    $Res Function(InternetConnectionState) then,
  ) = _$InternetConnectionStateCopyWithImpl<$Res, InternetConnectionState>;
  @useResult
  $Res call({ConnectivityStatus status});
}

/// @nodoc
class _$InternetConnectionStateCopyWithImpl<
  $Res,
  $Val extends InternetConnectionState
>
    implements $InternetConnectionStateCopyWith<$Res> {
  _$InternetConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InternetConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ConnectivityStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InternetConnectionStateImplCopyWith<$Res>
    implements $InternetConnectionStateCopyWith<$Res> {
  factory _$$InternetConnectionStateImplCopyWith(
    _$InternetConnectionStateImpl value,
    $Res Function(_$InternetConnectionStateImpl) then,
  ) = __$$InternetConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ConnectivityStatus status});
}

/// @nodoc
class __$$InternetConnectionStateImplCopyWithImpl<$Res>
    extends
        _$InternetConnectionStateCopyWithImpl<
          $Res,
          _$InternetConnectionStateImpl
        >
    implements _$$InternetConnectionStateImplCopyWith<$Res> {
  __$$InternetConnectionStateImplCopyWithImpl(
    _$InternetConnectionStateImpl _value,
    $Res Function(_$InternetConnectionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InternetConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _$InternetConnectionStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ConnectivityStatus,
      ),
    );
  }
}

/// @nodoc

class _$InternetConnectionStateImpl implements _InternetConnectionState {
  const _$InternetConnectionStateImpl({
    this.status = ConnectivityStatus.disconnected,
  });

  @override
  @JsonKey()
  final ConnectivityStatus status;

  @override
  String toString() {
    return 'InternetConnectionState(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InternetConnectionStateImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status);

  /// Create a copy of InternetConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InternetConnectionStateImplCopyWith<_$InternetConnectionStateImpl>
  get copyWith =>
      __$$InternetConnectionStateImplCopyWithImpl<
        _$InternetConnectionStateImpl
      >(this, _$identity);
}

abstract class _InternetConnectionState implements InternetConnectionState {
  const factory _InternetConnectionState({final ConnectivityStatus status}) =
      _$InternetConnectionStateImpl;

  @override
  ConnectivityStatus get status;

  /// Create a copy of InternetConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InternetConnectionStateImplCopyWith<_$InternetConnectionStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
