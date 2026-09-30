// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RegisterEventImplCopyWith<$Res> {
  factory _$$RegisterEventImplCopyWith(
    _$RegisterEventImpl value,
    $Res Function(_$RegisterEventImpl) then,
  ) = __$$RegisterEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String fullName,
    String userType,
    String email,
    String phone,
    String password,
  });
}

/// @nodoc
class __$$RegisterEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$RegisterEventImpl>
    implements _$$RegisterEventImplCopyWith<$Res> {
  __$$RegisterEventImplCopyWithImpl(
    _$RegisterEventImpl _value,
    $Res Function(_$RegisterEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? userType = null,
    Object? email = null,
    Object? phone = null,
    Object? password = null,
  }) {
    return _then(
      _$RegisterEventImpl(
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        userType: null == userType
            ? _value.userType
            : userType // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RegisterEventImpl implements RegisterEvent {
  const _$RegisterEventImpl({
    required this.fullName,
    required this.userType,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  final String fullName;
  @override
  final String userType;
  @override
  final String email;
  @override
  final String phone;
  @override
  final String password;

  @override
  String toString() {
    return 'AuthEvent.register(fullName: $fullName, userType: $userType, email: $email, phone: $phone, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterEventImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, fullName, userType, email, phone, password);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterEventImplCopyWith<_$RegisterEventImpl> get copyWith =>
      __$$RegisterEventImplCopyWithImpl<_$RegisterEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) {
    return register(fullName, userType, email, phone, password);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) {
    return register?.call(fullName, userType, email, phone, password);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) {
    if (register != null) {
      return register(fullName, userType, email, phone, password);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) {
    return register(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) {
    return register?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) {
    if (register != null) {
      return register(this);
    }
    return orElse();
  }
}

abstract class RegisterEvent implements AuthEvent {
  const factory RegisterEvent({
    required final String fullName,
    required final String userType,
    required final String email,
    required final String phone,
    required final String password,
  }) = _$RegisterEventImpl;

  String get fullName;
  String get userType;
  String get email;
  String get phone;
  String get password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterEventImplCopyWith<_$RegisterEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoginEventImplCopyWith<$Res> {
  factory _$$LoginEventImplCopyWith(
    _$LoginEventImpl value,
    $Res Function(_$LoginEventImpl) then,
  ) = __$$LoginEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LoginEventImpl>
    implements _$$LoginEventImplCopyWith<$Res> {
  __$$LoginEventImplCopyWithImpl(
    _$LoginEventImpl _value,
    $Res Function(_$LoginEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _$LoginEventImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LoginEventImpl implements LoginEvent {
  const _$LoginEventImpl({required this.email, required this.password});

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'AuthEvent.login(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginEventImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginEventImplCopyWith<_$LoginEventImpl> get copyWith =>
      __$$LoginEventImplCopyWithImpl<_$LoginEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) {
    return login(email, password);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) {
    return login?.call(email, password);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) {
    if (login != null) {
      return login(email, password);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) {
    return login(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) {
    return login?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) {
    if (login != null) {
      return login(this);
    }
    return orElse();
  }
}

abstract class LoginEvent implements AuthEvent {
  const factory LoginEvent({
    required final String email,
    required final String password,
  }) = _$LoginEventImpl;

  String get email;
  String get password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginEventImplCopyWith<_$LoginEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LogoutEventImplCopyWith<$Res> {
  factory _$$LogoutEventImplCopyWith(
    _$LogoutEventImpl value,
    $Res Function(_$LogoutEventImpl) then,
  ) = __$$LogoutEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LogoutEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LogoutEventImpl>
    implements _$$LogoutEventImplCopyWith<$Res> {
  __$$LogoutEventImplCopyWithImpl(
    _$LogoutEventImpl _value,
    $Res Function(_$LogoutEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LogoutEventImpl implements LogoutEvent {
  const _$LogoutEventImpl();

  @override
  String toString() {
    return 'AuthEvent.logout()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LogoutEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) {
    return logout();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) {
    return logout?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) {
    return logout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) {
    return logout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout(this);
    }
    return orElse();
  }
}

abstract class LogoutEvent implements AuthEvent {
  const factory LogoutEvent() = _$LogoutEventImpl;
}

/// @nodoc
abstract class _$$ResendOtpEventImplCopyWith<$Res> {
  factory _$$ResendOtpEventImplCopyWith(
    _$ResendOtpEventImpl value,
    $Res Function(_$ResendOtpEventImpl) then,
  ) = __$$ResendOtpEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, bool isForgot});
}

/// @nodoc
class __$$ResendOtpEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$ResendOtpEventImpl>
    implements _$$ResendOtpEventImplCopyWith<$Res> {
  __$$ResendOtpEventImplCopyWithImpl(
    _$ResendOtpEventImpl _value,
    $Res Function(_$ResendOtpEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? isForgot = null}) {
    return _then(
      _$ResendOtpEventImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        isForgot: null == isForgot
            ? _value.isForgot
            : isForgot // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ResendOtpEventImpl implements ResendOtpEvent {
  const _$ResendOtpEventImpl({required this.email, required this.isForgot});

  @override
  final String email;
  @override
  final bool isForgot;

  @override
  String toString() {
    return 'AuthEvent.resendOtp(email: $email, isForgot: $isForgot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResendOtpEventImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isForgot, isForgot) ||
                other.isForgot == isForgot));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, isForgot);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResendOtpEventImplCopyWith<_$ResendOtpEventImpl> get copyWith =>
      __$$ResendOtpEventImplCopyWithImpl<_$ResendOtpEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) {
    return resendOtp(email, isForgot);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) {
    return resendOtp?.call(email, isForgot);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) {
    if (resendOtp != null) {
      return resendOtp(email, isForgot);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) {
    return resendOtp(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) {
    return resendOtp?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) {
    if (resendOtp != null) {
      return resendOtp(this);
    }
    return orElse();
  }
}

abstract class ResendOtpEvent implements AuthEvent {
  const factory ResendOtpEvent({
    required final String email,
    required final bool isForgot,
  }) = _$ResendOtpEventImpl;

  String get email;
  bool get isForgot;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResendOtpEventImplCopyWith<_$ResendOtpEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VerifyOtpEventImplCopyWith<$Res> {
  factory _$$VerifyOtpEventImplCopyWith(
    _$VerifyOtpEventImpl value,
    $Res Function(_$VerifyOtpEventImpl) then,
  ) = __$$VerifyOtpEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String otp,
    String email,
    bool? isLogin,
    bool? isForgot,
    String? hash,
  });
}

/// @nodoc
class __$$VerifyOtpEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$VerifyOtpEventImpl>
    implements _$$VerifyOtpEventImplCopyWith<$Res> {
  __$$VerifyOtpEventImplCopyWithImpl(
    _$VerifyOtpEventImpl _value,
    $Res Function(_$VerifyOtpEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otp = null,
    Object? email = null,
    Object? isLogin = freezed,
    Object? isForgot = freezed,
    Object? hash = freezed,
  }) {
    return _then(
      _$VerifyOtpEventImpl(
        otp: null == otp
            ? _value.otp
            : otp // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        isLogin: freezed == isLogin
            ? _value.isLogin
            : isLogin // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isForgot: freezed == isForgot
            ? _value.isForgot
            : isForgot // ignore: cast_nullable_to_non_nullable
                  as bool?,
        hash: freezed == hash
            ? _value.hash
            : hash // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$VerifyOtpEventImpl implements VerifyOtpEvent {
  const _$VerifyOtpEventImpl({
    required this.otp,
    required this.email,
    this.isLogin,
    this.isForgot,
    this.hash,
  });

  @override
  final String otp;
  @override
  final String email;
  @override
  final bool? isLogin;
  @override
  final bool? isForgot;
  @override
  final String? hash;

  @override
  String toString() {
    return 'AuthEvent.verifyOtp(otp: $otp, email: $email, isLogin: $isLogin, isForgot: $isForgot, hash: $hash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyOtpEventImpl &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isLogin, isLogin) || other.isLogin == isLogin) &&
            (identical(other.isForgot, isForgot) ||
                other.isForgot == isForgot) &&
            (identical(other.hash, hash) || other.hash == hash));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, otp, email, isLogin, isForgot, hash);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyOtpEventImplCopyWith<_$VerifyOtpEventImpl> get copyWith =>
      __$$VerifyOtpEventImplCopyWithImpl<_$VerifyOtpEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) {
    return verifyOtp(otp, email, isLogin, isForgot, hash);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) {
    return verifyOtp?.call(otp, email, isLogin, isForgot, hash);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) {
    if (verifyOtp != null) {
      return verifyOtp(otp, email, isLogin, isForgot, hash);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) {
    return verifyOtp(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) {
    return verifyOtp?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) {
    if (verifyOtp != null) {
      return verifyOtp(this);
    }
    return orElse();
  }
}

abstract class VerifyOtpEvent implements AuthEvent {
  const factory VerifyOtpEvent({
    required final String otp,
    required final String email,
    final bool? isLogin,
    final bool? isForgot,
    final String? hash,
  }) = _$VerifyOtpEventImpl;

  String get otp;
  String get email;
  bool? get isLogin;
  bool? get isForgot;
  String? get hash;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyOtpEventImplCopyWith<_$VerifyOtpEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ForgotPasswordEventImplCopyWith<$Res> {
  factory _$$ForgotPasswordEventImplCopyWith(
    _$ForgotPasswordEventImpl value,
    $Res Function(_$ForgotPasswordEventImpl) then,
  ) = __$$ForgotPasswordEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$ForgotPasswordEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$ForgotPasswordEventImpl>
    implements _$$ForgotPasswordEventImplCopyWith<$Res> {
  __$$ForgotPasswordEventImplCopyWithImpl(
    _$ForgotPasswordEventImpl _value,
    $Res Function(_$ForgotPasswordEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _$ForgotPasswordEventImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ForgotPasswordEventImpl implements ForgotPasswordEvent {
  const _$ForgotPasswordEventImpl({required this.email});

  @override
  final String email;

  @override
  String toString() {
    return 'AuthEvent.forgotPassword(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgotPasswordEventImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgotPasswordEventImplCopyWith<_$ForgotPasswordEventImpl> get copyWith =>
      __$$ForgotPasswordEventImplCopyWithImpl<_$ForgotPasswordEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) {
    return forgotPassword(email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) {
    return forgotPassword?.call(email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) {
    if (forgotPassword != null) {
      return forgotPassword(email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) {
    return forgotPassword(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) {
    return forgotPassword?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) {
    if (forgotPassword != null) {
      return forgotPassword(this);
    }
    return orElse();
  }
}

abstract class ForgotPasswordEvent implements AuthEvent {
  const factory ForgotPasswordEvent({required final String email}) =
      _$ForgotPasswordEventImpl;

  String get email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgotPasswordEventImplCopyWith<_$ForgotPasswordEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ResetPasswordEventImplCopyWith<$Res> {
  factory _$$ResetPasswordEventImplCopyWith(
    _$ResetPasswordEventImpl value,
    $Res Function(_$ResetPasswordEventImpl) then,
  ) = __$$ResetPasswordEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String otpCode, String newPassword});
}

/// @nodoc
class __$$ResetPasswordEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$ResetPasswordEventImpl>
    implements _$$ResetPasswordEventImplCopyWith<$Res> {
  __$$ResetPasswordEventImplCopyWithImpl(
    _$ResetPasswordEventImpl _value,
    $Res Function(_$ResetPasswordEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? otpCode = null, Object? newPassword = null}) {
    return _then(
      _$ResetPasswordEventImpl(
        otpCode: null == otpCode
            ? _value.otpCode
            : otpCode // ignore: cast_nullable_to_non_nullable
                  as String,
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ResetPasswordEventImpl implements ResetPasswordEvent {
  const _$ResetPasswordEventImpl({
    required this.otpCode,
    required this.newPassword,
  });

  @override
  final String otpCode;
  @override
  final String newPassword;

  @override
  String toString() {
    return 'AuthEvent.resetPassword(otpCode: $otpCode, newPassword: $newPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetPasswordEventImpl &&
            (identical(other.otpCode, otpCode) || other.otpCode == otpCode) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword));
  }

  @override
  int get hashCode => Object.hash(runtimeType, otpCode, newPassword);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetPasswordEventImplCopyWith<_$ResetPasswordEventImpl> get copyWith =>
      __$$ResetPasswordEventImplCopyWithImpl<_$ResetPasswordEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )
    register,
    required TResult Function(String email, String password) login,
    required TResult Function() logout,
    required TResult Function(String email, bool isForgot) resendOtp,
    required TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )
    verifyOtp,
    required TResult Function(String email) forgotPassword,
    required TResult Function(String otpCode, String newPassword) resetPassword,
  }) {
    return resetPassword(otpCode, newPassword);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult? Function(String email, String password)? login,
    TResult? Function()? logout,
    TResult? Function(String email, bool isForgot)? resendOtp,
    TResult? Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult? Function(String email)? forgotPassword,
    TResult? Function(String otpCode, String newPassword)? resetPassword,
  }) {
    return resetPassword?.call(otpCode, newPassword);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String fullName,
      String userType,
      String email,
      String phone,
      String password,
    )?
    register,
    TResult Function(String email, String password)? login,
    TResult Function()? logout,
    TResult Function(String email, bool isForgot)? resendOtp,
    TResult Function(
      String otp,
      String email,
      bool? isLogin,
      bool? isForgot,
      String? hash,
    )?
    verifyOtp,
    TResult Function(String email)? forgotPassword,
    TResult Function(String otpCode, String newPassword)? resetPassword,
    required TResult orElse(),
  }) {
    if (resetPassword != null) {
      return resetPassword(otpCode, newPassword);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterEvent value) register,
    required TResult Function(LoginEvent value) login,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(ResendOtpEvent value) resendOtp,
    required TResult Function(VerifyOtpEvent value) verifyOtp,
    required TResult Function(ForgotPasswordEvent value) forgotPassword,
    required TResult Function(ResetPasswordEvent value) resetPassword,
  }) {
    return resetPassword(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterEvent value)? register,
    TResult? Function(LoginEvent value)? login,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(ResendOtpEvent value)? resendOtp,
    TResult? Function(VerifyOtpEvent value)? verifyOtp,
    TResult? Function(ForgotPasswordEvent value)? forgotPassword,
    TResult? Function(ResetPasswordEvent value)? resetPassword,
  }) {
    return resetPassword?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterEvent value)? register,
    TResult Function(LoginEvent value)? login,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(ResendOtpEvent value)? resendOtp,
    TResult Function(VerifyOtpEvent value)? verifyOtp,
    TResult Function(ForgotPasswordEvent value)? forgotPassword,
    TResult Function(ResetPasswordEvent value)? resetPassword,
    required TResult orElse(),
  }) {
    if (resetPassword != null) {
      return resetPassword(this);
    }
    return orElse();
  }
}

abstract class ResetPasswordEvent implements AuthEvent {
  const factory ResetPasswordEvent({
    required final String otpCode,
    required final String newPassword,
  }) = _$ResetPasswordEventImpl;

  String get otpCode;
  String get newPassword;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResetPasswordEventImplCopyWith<_$ResetPasswordEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
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
    extends _$AuthStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AuthState.initial()';
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
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
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
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AuthState {
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
    extends _$AuthStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AuthState.loading()';
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
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
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
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements AuthState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
    _$SuccessImpl value,
    $Res Function(_$SuccessImpl) then,
  ) = __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, Map<String, dynamic>? data});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
    _$SuccessImpl _value,
    $Res Function(_$SuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? data = freezed}) {
    return _then(
      _$SuccessImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        freezed == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(this.message, [final Map<String, dynamic>? data])
    : _data = data;

  @override
  final String message;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AuthState.success(message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return success(message, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return success?.call(message, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(message, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements AuthState {
  const factory _Success(
    final String message, [
    final Map<String, dynamic>? data,
  ]) = _$SuccessImpl;

  String get message;
  Map<String, dynamic>? get data;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureImplCopyWith<$Res> {
  factory _$$FailureImplCopyWith(
    _$FailureImpl value,
    $Res Function(_$FailureImpl) then,
  ) = __$$FailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppException exception});
}

/// @nodoc
class __$$FailureImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$FailureImpl>
    implements _$$FailureImplCopyWith<$Res> {
  __$$FailureImplCopyWithImpl(
    _$FailureImpl _value,
    $Res Function(_$FailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? exception = null}) {
    return _then(
      _$FailureImpl(
        null == exception
            ? _value.exception
            : exception // ignore: cast_nullable_to_non_nullable
                  as AppException,
      ),
    );
  }
}

/// @nodoc

class _$FailureImpl implements _Failure {
  const _$FailureImpl(this.exception);

  @override
  final AppException exception;

  @override
  String toString() {
    return 'AuthState.failure(exception: $exception)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureImpl &&
            (identical(other.exception, exception) ||
                other.exception == exception));
  }

  @override
  int get hashCode => Object.hash(runtimeType, exception);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      __$$FailureImplCopyWithImpl<_$FailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return failure(exception);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return failure?.call(exception);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(exception);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _Failure implements AuthState {
  const factory _Failure(final AppException exception) = _$FailureImpl;

  AppException get exception;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegisterSuccessImplCopyWith<$Res> {
  factory _$$RegisterSuccessImplCopyWith(
    _$RegisterSuccessImpl value,
    $Res Function(_$RegisterSuccessImpl) then,
  ) = __$$RegisterSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String email, String hash});
}

/// @nodoc
class __$$RegisterSuccessImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$RegisterSuccessImpl>
    implements _$$RegisterSuccessImplCopyWith<$Res> {
  __$$RegisterSuccessImplCopyWithImpl(
    _$RegisterSuccessImpl _value,
    $Res Function(_$RegisterSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? email = null,
    Object? hash = null,
  }) {
    return _then(
      _$RegisterSuccessImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        null == hash
            ? _value.hash
            : hash // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RegisterSuccessImpl implements _RegisterSuccess {
  const _$RegisterSuccessImpl(this.message, this.email, this.hash);

  @override
  final String message;
  @override
  final String email;
  @override
  final String hash;

  @override
  String toString() {
    return 'AuthState.registerSuccess(message: $message, email: $email, hash: $hash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterSuccessImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.hash, hash) || other.hash == hash));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, email, hash);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterSuccessImplCopyWith<_$RegisterSuccessImpl> get copyWith =>
      __$$RegisterSuccessImplCopyWithImpl<_$RegisterSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return registerSuccess(message, email, hash);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return registerSuccess?.call(message, email, hash);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (registerSuccess != null) {
      return registerSuccess(message, email, hash);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return registerSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return registerSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (registerSuccess != null) {
      return registerSuccess(this);
    }
    return orElse();
  }
}

abstract class _RegisterSuccess implements AuthState {
  const factory _RegisterSuccess(
    final String message,
    final String email,
    final String hash,
  ) = _$RegisterSuccessImpl;

  String get message;
  String get email;
  String get hash;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterSuccessImplCopyWith<_$RegisterSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OtpResendFailedImplCopyWith<$Res> {
  factory _$$OtpResendFailedImplCopyWith(
    _$OtpResendFailedImpl value,
    $Res Function(_$OtpResendFailedImpl) then,
  ) = __$$OtpResendFailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$OtpResendFailedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$OtpResendFailedImpl>
    implements _$$OtpResendFailedImplCopyWith<$Res> {
  __$$OtpResendFailedImplCopyWithImpl(
    _$OtpResendFailedImpl _value,
    $Res Function(_$OtpResendFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$OtpResendFailedImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$OtpResendFailedImpl implements _OtpResendFailed {
  const _$OtpResendFailedImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AuthState.otpResendFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpResendFailedImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpResendFailedImplCopyWith<_$OtpResendFailedImpl> get copyWith =>
      __$$OtpResendFailedImplCopyWithImpl<_$OtpResendFailedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return otpResendFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return otpResendFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (otpResendFailure != null) {
      return otpResendFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return otpResendFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return otpResendFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (otpResendFailure != null) {
      return otpResendFailure(this);
    }
    return orElse();
  }
}

abstract class _OtpResendFailed implements AuthState {
  const factory _OtpResendFailed(final String message) = _$OtpResendFailedImpl;

  String get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpResendFailedImplCopyWith<_$OtpResendFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OtpResendSuccessImplCopyWith<$Res> {
  factory _$$OtpResendSuccessImplCopyWith(
    _$OtpResendSuccessImpl value,
    $Res Function(_$OtpResendSuccessImpl) then,
  ) = __$$OtpResendSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$OtpResendSuccessImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$OtpResendSuccessImpl>
    implements _$$OtpResendSuccessImplCopyWith<$Res> {
  __$$OtpResendSuccessImplCopyWithImpl(
    _$OtpResendSuccessImpl _value,
    $Res Function(_$OtpResendSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$OtpResendSuccessImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$OtpResendSuccessImpl implements _OtpResendSuccess {
  const _$OtpResendSuccessImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AuthState.otpResendSuccess(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpResendSuccessImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpResendSuccessImplCopyWith<_$OtpResendSuccessImpl> get copyWith =>
      __$$OtpResendSuccessImplCopyWithImpl<_$OtpResendSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return otpResendSuccess(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return otpResendSuccess?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (otpResendSuccess != null) {
      return otpResendSuccess(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return otpResendSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return otpResendSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (otpResendSuccess != null) {
      return otpResendSuccess(this);
    }
    return orElse();
  }
}

abstract class _OtpResendSuccess implements AuthState {
  const factory _OtpResendSuccess(final String message) =
      _$OtpResendSuccessImpl;

  String get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpResendSuccessImplCopyWith<_$OtpResendSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OtpVerifyFailedImplCopyWith<$Res> {
  factory _$$OtpVerifyFailedImplCopyWith(
    _$OtpVerifyFailedImpl value,
    $Res Function(_$OtpVerifyFailedImpl) then,
  ) = __$$OtpVerifyFailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$OtpVerifyFailedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$OtpVerifyFailedImpl>
    implements _$$OtpVerifyFailedImplCopyWith<$Res> {
  __$$OtpVerifyFailedImplCopyWithImpl(
    _$OtpVerifyFailedImpl _value,
    $Res Function(_$OtpVerifyFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$OtpVerifyFailedImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$OtpVerifyFailedImpl implements _OtpVerifyFailed {
  const _$OtpVerifyFailedImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AuthState.otpVerifyFailed(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpVerifyFailedImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpVerifyFailedImplCopyWith<_$OtpVerifyFailedImpl> get copyWith =>
      __$$OtpVerifyFailedImplCopyWithImpl<_$OtpVerifyFailedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return otpVerifyFailed(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return otpVerifyFailed?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (otpVerifyFailed != null) {
      return otpVerifyFailed(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return otpVerifyFailed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return otpVerifyFailed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (otpVerifyFailed != null) {
      return otpVerifyFailed(this);
    }
    return orElse();
  }
}

abstract class _OtpVerifyFailed implements AuthState {
  const factory _OtpVerifyFailed(final String message) = _$OtpVerifyFailedImpl;

  String get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpVerifyFailedImplCopyWith<_$OtpVerifyFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OtpVerifiedImplCopyWith<$Res> {
  factory _$$OtpVerifiedImplCopyWith(
    _$OtpVerifiedImpl value,
    $Res Function(_$OtpVerifiedImpl) then,
  ) = __$$OtpVerifiedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, bool isSetup, Map<String, dynamic>? data});
}

/// @nodoc
class __$$OtpVerifiedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$OtpVerifiedImpl>
    implements _$$OtpVerifiedImplCopyWith<$Res> {
  __$$OtpVerifiedImplCopyWithImpl(
    _$OtpVerifiedImpl _value,
    $Res Function(_$OtpVerifiedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? isSetup = null,
    Object? data = freezed,
  }) {
    return _then(
      _$OtpVerifiedImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        null == isSetup
            ? _value.isSetup
            : isSetup // ignore: cast_nullable_to_non_nullable
                  as bool,
        freezed == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$OtpVerifiedImpl implements _OtpVerified {
  const _$OtpVerifiedImpl(
    this.message,
    this.isSetup, [
    final Map<String, dynamic>? data,
  ]) : _data = data;

  @override
  final String message;
  @override
  final bool isSetup;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AuthState.otpVerified(message: $message, isSetup: $isSetup, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpVerifiedImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isSetup, isSetup) || other.isSetup == isSetup) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    isSetup,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpVerifiedImplCopyWith<_$OtpVerifiedImpl> get copyWith =>
      __$$OtpVerifiedImplCopyWithImpl<_$OtpVerifiedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return otpVerified(message, isSetup, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return otpVerified?.call(message, isSetup, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (otpVerified != null) {
      return otpVerified(message, isSetup, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return otpVerified(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return otpVerified?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (otpVerified != null) {
      return otpVerified(this);
    }
    return orElse();
  }
}

abstract class _OtpVerified implements AuthState {
  const factory _OtpVerified(
    final String message,
    final bool isSetup, [
    final Map<String, dynamic>? data,
  ]) = _$OtpVerifiedImpl;

  String get message;
  bool get isSetup;
  Map<String, dynamic>? get data;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpVerifiedImplCopyWith<_$OtpVerifiedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LogoutImplCopyWith<$Res> {
  factory _$$LogoutImplCopyWith(
    _$LogoutImpl value,
    $Res Function(_$LogoutImpl) then,
  ) = __$$LogoutImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LogoutImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$LogoutImpl>
    implements _$$LogoutImplCopyWith<$Res> {
  __$$LogoutImplCopyWithImpl(
    _$LogoutImpl _value,
    $Res Function(_$LogoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LogoutImpl implements _Logout {
  const _$LogoutImpl();

  @override
  String toString() {
    return 'AuthState.logout()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LogoutImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return logout();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return logout?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return logout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return logout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout(this);
    }
    return orElse();
  }
}

abstract class _Logout implements AuthState {
  const factory _Logout() = _$LogoutImpl;
}

/// @nodoc
abstract class _$$OtpForgotResendSuccessImplCopyWith<$Res> {
  factory _$$OtpForgotResendSuccessImplCopyWith(
    _$OtpForgotResendSuccessImpl value,
    $Res Function(_$OtpForgotResendSuccessImpl) then,
  ) = __$$OtpForgotResendSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$OtpForgotResendSuccessImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$OtpForgotResendSuccessImpl>
    implements _$$OtpForgotResendSuccessImplCopyWith<$Res> {
  __$$OtpForgotResendSuccessImplCopyWithImpl(
    _$OtpForgotResendSuccessImpl _value,
    $Res Function(_$OtpForgotResendSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$OtpForgotResendSuccessImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$OtpForgotResendSuccessImpl implements _OtpForgotResendSuccess {
  const _$OtpForgotResendSuccessImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AuthState.otpForgotResendSuccess(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpForgotResendSuccessImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpForgotResendSuccessImplCopyWith<_$OtpForgotResendSuccessImpl>
  get copyWith =>
      __$$OtpForgotResendSuccessImplCopyWithImpl<_$OtpForgotResendSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return otpForgotResendSuccess(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return otpForgotResendSuccess?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (otpForgotResendSuccess != null) {
      return otpForgotResendSuccess(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return otpForgotResendSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return otpForgotResendSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (otpForgotResendSuccess != null) {
      return otpForgotResendSuccess(this);
    }
    return orElse();
  }
}

abstract class _OtpForgotResendSuccess implements AuthState {
  const factory _OtpForgotResendSuccess(final String message) =
      _$OtpForgotResendSuccessImpl;

  String get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpForgotResendSuccessImplCopyWith<_$OtpForgotResendSuccessImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(
    _$ValidationErrorImpl value,
    $Res Function(_$ValidationErrorImpl) then,
  ) = __$$ValidationErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ValidationError? validationError});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
    _$ValidationErrorImpl _value,
    $Res Function(_$ValidationErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? validationError = freezed}) {
    return _then(
      _$ValidationErrorImpl(
        freezed == validationError
            ? _value.validationError
            : validationError // ignore: cast_nullable_to_non_nullable
                  as ValidationError?,
      ),
    );
  }
}

/// @nodoc

class _$ValidationErrorImpl implements _ValidationError {
  const _$ValidationErrorImpl(this.validationError);

  @override
  final ValidationError? validationError;

  @override
  String toString() {
    return 'AuthState.validationError(validationError: $validationError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.validationError, validationError) ||
                other.validationError == validationError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, validationError);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message, Map<String, dynamic>? data)
    success,
    required TResult Function(AppException exception) failure,
    required TResult Function(String message, String email, String hash)
    registerSuccess,
    required TResult Function(String message) otpResendFailure,
    required TResult Function(String message) otpResendSuccess,
    required TResult Function(String message) otpVerifyFailed,
    required TResult Function(
      String message,
      bool isSetup,
      Map<String, dynamic>? data,
    )
    otpVerified,
    required TResult Function() logout,
    required TResult Function(String message) otpForgotResendSuccess,
    required TResult Function(ValidationError? validationError) validationError,
  }) {
    return validationError(this.validationError);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message, Map<String, dynamic>? data)? success,
    TResult? Function(AppException exception)? failure,
    TResult? Function(String message, String email, String hash)?
    registerSuccess,
    TResult? Function(String message)? otpResendFailure,
    TResult? Function(String message)? otpResendSuccess,
    TResult? Function(String message)? otpVerifyFailed,
    TResult? Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult? Function()? logout,
    TResult? Function(String message)? otpForgotResendSuccess,
    TResult? Function(ValidationError? validationError)? validationError,
  }) {
    return validationError?.call(this.validationError);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message, Map<String, dynamic>? data)? success,
    TResult Function(AppException exception)? failure,
    TResult Function(String message, String email, String hash)?
    registerSuccess,
    TResult Function(String message)? otpResendFailure,
    TResult Function(String message)? otpResendSuccess,
    TResult Function(String message)? otpVerifyFailed,
    TResult Function(String message, bool isSetup, Map<String, dynamic>? data)?
    otpVerified,
    TResult Function()? logout,
    TResult Function(String message)? otpForgotResendSuccess,
    TResult Function(ValidationError? validationError)? validationError,
    required TResult orElse(),
  }) {
    if (validationError != null) {
      return validationError(this.validationError);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_RegisterSuccess value) registerSuccess,
    required TResult Function(_OtpResendFailed value) otpResendFailure,
    required TResult Function(_OtpResendSuccess value) otpResendSuccess,
    required TResult Function(_OtpVerifyFailed value) otpVerifyFailed,
    required TResult Function(_OtpVerified value) otpVerified,
    required TResult Function(_Logout value) logout,
    required TResult Function(_OtpForgotResendSuccess value)
    otpForgotResendSuccess,
    required TResult Function(_ValidationError value) validationError,
  }) {
    return validationError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_RegisterSuccess value)? registerSuccess,
    TResult? Function(_OtpResendFailed value)? otpResendFailure,
    TResult? Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult? Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult? Function(_OtpVerified value)? otpVerified,
    TResult? Function(_Logout value)? logout,
    TResult? Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult? Function(_ValidationError value)? validationError,
  }) {
    return validationError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_RegisterSuccess value)? registerSuccess,
    TResult Function(_OtpResendFailed value)? otpResendFailure,
    TResult Function(_OtpResendSuccess value)? otpResendSuccess,
    TResult Function(_OtpVerifyFailed value)? otpVerifyFailed,
    TResult Function(_OtpVerified value)? otpVerified,
    TResult Function(_Logout value)? logout,
    TResult Function(_OtpForgotResendSuccess value)? otpForgotResendSuccess,
    TResult Function(_ValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (validationError != null) {
      return validationError(this);
    }
    return orElse();
  }
}

abstract class _ValidationError implements AuthState {
  const factory _ValidationError(final ValidationError? validationError) =
      _$ValidationErrorImpl;

  ValidationError? get validationError;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
