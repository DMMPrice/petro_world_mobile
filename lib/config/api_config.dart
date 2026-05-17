import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base URL for the Express backend.
///
/// Priority order:
///   1. API_URL from .env  (e.g. http://192.168.1.5:3002/api/v1 for physical device)
///   2. Android emulator default  → http://10.0.2.2:3002/api/v1
///   3. iOS / other              → http://localhost:3002/api/v1
class ApiConfig {
  static String get baseUrl {
    // Use whatever is set in .env first
    final envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      // On Android emulator 'localhost' won't resolve – swap it automatically
      if (Platform.isAndroid && envUrl.contains('localhost')) {
        return envUrl.replaceFirst('localhost', '10.0.2.2');
      }
      return envUrl;
    }

    // Fallback defaults
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3002/api/v1';
    }
    return 'http://localhost:3002/api/v1';
  }
}
