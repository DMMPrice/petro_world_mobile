class AddressModel {
  final String? id;
  final String name;
  final String address;
  final String phoneNumber;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      phoneNumber: json['phone_number'] ?? "",
      city: json['city'] ?? "",
      state: json['state'] ?? "",
      pincode: json['pincode'] ?? "",
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }
}
