import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shipment_model.dart';
import 'logger_service.dart';

class LogisticsService {
  static final LogisticsService _instance = LogisticsService._internal();
  factory LogisticsService() => _instance;
  LogisticsService._internal();

  // Shiprocket Base URL
  static const String baseUrl = "https://apiv2.shiprocket.in/v1/external";

  /// Checks if a pincode is serviceable by Shiprocket
  Future<bool> checkServiceability(String pincode) async {
    // Returns true for any 6-digit pincode
    await Future.delayed(const Duration(milliseconds: 800));
    return pincode.length == 6;
  }

  /// Fetches tracking details.
  /// Shiprocket Edge Function has been removed — falls back to mock data.
  Future<ShipmentTracking> getTrackingDetails(
      String orderId, String trackingNumber) async {
    LoggerService.info('Shiprocket sync not implemented — returning mock');
    return ShipmentTracking.fromMock(trackingNumber);
  }

  /// Calculates estimated delivery days.
  /// Shiprocket serviceability Edge Function has been removed — returns a generic estimate.
  Future<Map<String, dynamic>> getEstimatedDelivery(String destinationPincode,
      {double weight = 0.5}) async {
    // No Shiprocket integration on the mobile side. Return a generic estimate.
    return {
      'status': 'success',
      'etd': '5-7 business days',
      'days': 7,
      'courier': 'Standard Courier',
      'provider': 'PetroWorld Logistics',
    };
  }

  /// Looks up city and state from pincode using postalpincode.in API
  Future<Map<String, String>?> lookupPincode(String pincode) async {
    if (pincode.length != 6) return null;
    try {
      String url = 'https://api.postalpincode.in/pincode/$pincode';
      if (kIsWeb) {
        url = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          return {
            'city': postOffice['District'],
            'state': postOffice['State'],
          };
        }
      }
    } catch (e) {
      LoggerService.error('Pincode Lookup Error: $e');
    }
    return null;
  }
}
