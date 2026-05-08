class ShipmentTracking {
  final String trackingNumber;
  final String status;
  final String? currentLocation;
  final DateTime? expectedDelivery;
  final List<TrackingCheckpoint> checkpoints;

  ShipmentTracking({
    required this.trackingNumber,
    required this.status,
    this.currentLocation,
    this.expectedDelivery,
    required this.checkpoints,
  });

  factory ShipmentTracking.fromJson(String number, Map<String, dynamic> json) {
    final activities = (json['activities'] as List? ?? []);
    
    return ShipmentTracking(
      trackingNumber: number,
      status: json['current_status'] ?? "In Transit",
      currentLocation: activities.isNotEmpty ? activities[0]['location'] : null,
      expectedDelivery: null, // Shiprocket sometimes provides this elsewhere
      checkpoints: activities.map((a) => TrackingCheckpoint(
        message: a['activity'] ?? a['status'] ?? "Status Update",
        location: a['location'] ?? "Unknown",
        timestamp: DateTime.tryParse(a['date'] ?? "") ?? DateTime.now(),
      )).toList(),
    );
  }

  factory ShipmentTracking.fromMock(String number) {
    return ShipmentTracking(
      trackingNumber: number,
      status: "In Transit",
      currentLocation: "Mumbai Hub",
      expectedDelivery: DateTime.now().add(const Duration(days: 3)),
      checkpoints: [
        TrackingCheckpoint(
          message: "Shipment arrived at Mumbai Hub",
          location: "Mumbai",
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        TrackingCheckpoint(
          message: "Shipment picked up",
          location: "Bangalore",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}

class TrackingCheckpoint {
  final String message;
  final String location;
  final DateTime timestamp;

  TrackingCheckpoint({
    required this.message,
    required this.location,
    required this.timestamp,
  });
}
