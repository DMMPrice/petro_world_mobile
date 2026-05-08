import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shipment_model.dart';
import 'supabase_service.dart';

class LogisticsService {
  static final LogisticsService _instance = LogisticsService._internal();
  factory LogisticsService() => _instance;
  LogisticsService._internal();

  // Shiprocket Base URL
  static const String baseUrl = "https://apiv2.shiprocket.in/v1/external";

  /// Checks if a pincode is serviceable by Shiprocket
  Future<bool> checkServiceability(String pincode) async {
    // TODO: Implement actual Shiprocket Serviceability API call
    // GET /courier/serviceability?pickup_postcode={origin}&delivery_postcode={destination}&weight={weight}
    await Future.delayed(const Duration(milliseconds: 800));
    return pincode.length == 6; // Mock: Any 6 digit pincode is serviceable
  }

  /// Fetches tracking details from Shiprocket
  Future<ShipmentTracking> getTrackingDetails(String orderId, String trackingNumber) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'shiprocket-core/sync',
        body: {
          'order_id': orderId,
          'tracking_number': trackingNumber,
        },
      );

      if (response.status != 200) {
        throw Exception('Tracking fetch failed');
      }

      final data = response.data;
      if (data['success'] == true) {
        return ShipmentTracking.fromJson(trackingNumber, data);
      } else {
        throw Exception(data['error'] ?? 'Unknown tracking error');
      }
    } catch (e) {
      print('Tracking Error: $e');
      // Fallback to mock for testing if needed, or rethrow
      return ShipmentTracking.fromMock(trackingNumber);
    }
  }

  /// Calculates estimated delivery days via Shiprocket
  Future<Map<String, dynamic>> getEstimatedDelivery(String destinationPincode, {double weight = 0.5}) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'shiprocket-serviceability',
        body: {
          'pincode': destinationPincode,
          'weight': weight,
        },
      );

      if (response.status != 200) {
        throw Exception('Serviceability check failed');
      }

      final data = response.data;
      if (data['success'] == true) {
        return {
          "status": "success",
          "etd": data['etd'],
          "days": data['estimated_delivery_days'],
          "courier": data['courier_name'],
          "provider": "Shiprocket",
        };
      } else {
        return {
          "status": "error",
          "message": data['message'] ?? "Not serviceable",
        };
      }
    } catch (e) {
      print('Shiprocket Serviceability Error: $e');
      return {
        "status": "error",
        "message": "Service currently unavailable",
      };
    }
  }

  /// Looks up city and state from pincode using postalpincode.in API
  Future<Map<String, String>?> lookupPincode(String pincode) async {
    if (pincode.length != 6) return null;
    try {
      final response = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'));
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
      print('Pincode Lookup Error: $e');
    }
    return null;
  }
}
