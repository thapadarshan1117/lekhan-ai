import 'package:connectivity_plus/connectivity_plus.dart';

/// What the connection can realistically carry.
///
/// `connectivity_plus` reports the transport, not the reachability of our API,
/// so treat this as a hint: the runner still has to react to real failures.
enum NetworkQuality {
  none,
  mobile,
  wifi,
  ethernet,
  other;

  bool get isOnline => this != NetworkQuality.none;

  /// Suitable for the biggest files without upsetting the user's data plan.
  bool get isUnmetered =>
      this == NetworkQuality.wifi || this == NetworkQuality.ethernet;
}

/// Thin, testable wrapper around connectivity.
///
/// Note: this is *not* the network service used for HTTP calls (`NetworkService`
/// stays exactly as it is). It only answers "is there a usable transport right
/// now, and may we spend it on a 400 MB video?".
class NetworkInfo {
  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<NetworkQuality> currentQuality() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      return _map(results);
    } catch (_) {
      // Never block the app because a platform channel misbehaved.
      return NetworkQuality.other;
    }
  }

  Future<bool> get isConnected async => (await currentQuality()).isOnline;

  Future<bool> get isUnmetered async => (await currentQuality()).isUnmetered;

  Stream<NetworkQuality> get onQualityChanged =>
      _connectivity.onConnectivityChanged.map(_map);

  Stream<bool> get onStatusChanged =>
      onQualityChanged.map((NetworkQuality quality) => quality.isOnline);

  /// Decision used by the sync engine before starting a heavy transfer.
  bool allowsTransfer({
    required NetworkQuality quality,
    required bool wifiOnly,
    required bool isLargeFile,
  }) {
    if (!quality.isOnline) return false;
    if (!wifiOnly) return true;
    if (!isLargeFile) return true;
    return quality.isUnmetered;
  }

  NetworkQuality _map(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkQuality.none;
    }
    if (results.contains(ConnectivityResult.wifi)) return NetworkQuality.wifi;
    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkQuality.ethernet;
    }
    if (results.contains(ConnectivityResult.mobile)) return NetworkQuality.mobile;
    return NetworkQuality.other;
  }
}
