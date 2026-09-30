import 'package:fpdart/fpdart.dart';

/// Readable accessors for `Either<AppException, T>`.
///
/// Every datasource, repository and use case in this project returns
/// `Either<AppException, T>`; this extension keeps the call sites free of
/// nested `fold`s while staying a thin wrapper over `fold` (so it behaves
/// exactly like the rest of the codebase).
extension EitherValueAccess<L, R> on Either<L, R> {
  /// The success value, or null when this is a failure.
  R? get valueOrNull => fold((L _) => null, (R value) => value);

  /// The failure, or null when this is a success.
  L? get errorOrNull => fold((L error) => error, (R _) => null);

  bool get isSuccess => fold((L _) => false, (R _) => true);

  bool get isFailure => fold((L _) => true, (R _) => false);
}

/// Maps a list result without leaving the `Either` world.
extension EitherListAccess<L, R> on Either<L, List<R>> {
  /// The success list, or an empty list when this is a failure.
  List<R> get valuesOrEmpty => fold((L _) => <R>[], (List<R> values) => values);
}

/// Left/Right constructors with the app's failure type pinned down.
Either<L, R> leftOf<L, R>(L error) => Left<L, R>(error);

Either<L, R> rightOf<L, R>(R value) => Right<L, R>(value);
