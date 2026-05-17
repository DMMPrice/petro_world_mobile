class CouponModel {
  final String id;
  final String code;
  final double discount;
  final String type; // 'percentage' or 'fixed'
  final DateTime expiry;
  final bool active;

  CouponModel({
    required this.id,
    required this.code,
    required this.discount,
    required this.type,
    required this.expiry,
    required this.active,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final raw = json['discount'];
    final discount = raw is num
        ? raw.toDouble()
        : double.tryParse(raw?.toString() ?? '') ?? 0.0;
    return CouponModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      discount: discount,
      type: json['type']?.toString() ?? 'percentage',
      expiry: DateTime.parse(json['expiry'].toString()),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
      'type': type,
      'expiry': expiry.toIso8601String(),
      'active': active,
    };
  }
}
