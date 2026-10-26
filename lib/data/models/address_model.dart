class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'addressLine': addressLine,
    'isDefault': isDefault,
  };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    addressLine: json['addressLine']?.toString() ?? '',
    isDefault: json['isDefault'] as bool? ?? false,
  );
}
