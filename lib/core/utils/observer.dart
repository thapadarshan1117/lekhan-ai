import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print(
          'onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print(
          'onError -- bloc: ${bloc.runtimeType}, error: $error, stackTrace: $stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }
}
