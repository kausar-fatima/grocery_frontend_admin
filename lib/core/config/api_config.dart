import 'package:flutter/foundation.dart';

/// Central API configuration.
///
/// The base URL is resolved per-platform so the same code works everywhere:
/// - Web / desktop → `localhost`
/// - Android emulator → `10.0.2.2` (the host loopback alias)
/// - Physical device → set [overrideBaseUrl] to your machine's LAN IP.
class ApiConfig {
  ApiConfig._();

  /// Set this (e.g. 'http://192.168.1.20:3000') to test on a physical device.
  static String? overrideBaseUrl;

  static const int _port = 3000;

  static String get baseUrl {
    if (overrideBaseUrl != null && overrideBaseUrl!.isNotEmpty) {
      return overrideBaseUrl!;
    }
    if (kIsWeb) return 'http://localhost:$_port';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$_port';
      default:
        return 'http://192.168.0.100:$_port';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
