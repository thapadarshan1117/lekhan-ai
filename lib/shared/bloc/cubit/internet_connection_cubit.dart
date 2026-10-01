import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lekhan_ai/core/config/backend_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'internet_connection_cubit.freezed.dart';
part 'internet_connection_state.dart';
/// A cubit that listens to internet connection changes and emits the current
/// internet connection status.
class InternetConnectionCubit extends Cubit<InternetConnectionState> {
  InternetConnectionCubit() : super(const InternetConnectionState()) {
    init();
  }

  /// A subscription to listen to real device changes outside mock mode.
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  /// Initializes the cubit.
  /// This method is called when the cubit is initialized. It checks the current
  /// internet connection status and listens to internet connection changes.
  void init() {
    if (BackendMode.useMockBackend) {
      emit(const InternetConnectionState(status: ConnectivityStatus.connected));
      return;
    }
    checkConntectivity();
    listenToConnectivityChanges();
  }
  /// Checks the current internet connection status.
  void checkConntectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectivityStatus(connectivityResult);
  }
  /// Updates the internet connection status based on the [connectivityResult].
  void _updateConnectivityStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(const InternetConnectionState(
          status: ConnectivityStatus.disconnected));
    } else {
      emit(const InternetConnectionState(status: ConnectivityStatus.connected));
    }
  }
  /// Listens to internet connection changes.
  /// This method is called when the cubit is initialized.
  void listenToConnectivityChanges() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectivityStatus(result);
    });
  }
  /// Closes the subscription when the cubit is closed.
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
} 