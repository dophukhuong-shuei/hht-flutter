import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCheck {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has WiFi or mobile connection
  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Check if device has WiFi connection
  static Future<bool> isWifiConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Stream of connectivity changes
  static Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}

