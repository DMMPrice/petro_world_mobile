import 'dart:io';

/// Base URL for the Express backend.
///
/// - Android emulator: 10.0.2.2 maps to the host machine's localhost
/// - iOS simulator:    localhost works directly
/// - Physical device:  replace with your machine's LAN IP, e.g. 192.168.1.5
class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3002/api/v1';
    }
    // iOS simulator or other platforms
    return 'http://localhost:3002/api/v1';
  }
}
