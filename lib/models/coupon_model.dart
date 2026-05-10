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
    return CouponModel(
      id: json['id'],
      code: json['code'],
      discount: (json['discount'] as num).toDouble(),
      type: json['type'],
      expiry: DateTime.parse(json['expiry']),
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
