class VariantModel {
  final String id;
  final String sku;
  final String color;
  final String colorHex;
  final int ramGB;
  final int storageGB;
  final int priceVnd;
  final int stock;
  final List<String> imageUrls;
  final bool isActive;

  const VariantModel({
    required this.id,
    required this.sku,
    required this.color,
    this.colorHex = '#1C1C1E',
    required this.ramGB,
    required this.storageGB,
    required this.priceVnd,
    required this.stock,
    this.imageUrls = const [],
    this.isActive = true,
  });

  String get label =>
      ramGB > 0 ? '${ramGB}GB / ${storageGB}GB • $color' : color;

  bool get isInStock => isActive && stock > 0;

  VariantModel copyWith({
    String? sku,
    String? color,
    String? colorHex,
    int? ramGB,
    int? storageGB,
    int? priceVnd,
    int? stock,
    bool? isActive,
  }) {
    return VariantModel(
      id: id,
      sku: sku ?? this.sku,
      color: color ?? this.color,
      colorHex: colorHex ?? this.colorHex,
      ramGB: ramGB ?? this.ramGB,
      storageGB: storageGB ?? this.storageGB,
      priceVnd: priceVnd ?? this.priceVnd,
      stock: stock ?? this.stock,
      imageUrls: imageUrls,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'sku': sku,
    'color': color,
    'colorHex': colorHex,
    'ramGB': ramGB,
    'storageGB': storageGB,
    'priceVnd': priceVnd,
    'stock': stock,
    'imageUrls': imageUrls,
    'isActive': isActive,
  };

  factory VariantModel.fromJson(String id, Map<String, dynamic> json) {
    final rawImages = json['imageUrls'] as List<dynamic>? ?? [];
    return VariantModel(
      id: id,
      sku: json['sku']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      colorHex: json['colorHex']?.toString() ?? '#1C1C1E',
      ramGB: (json['ramGB'] as num?)?.toInt() ?? 8,
      storageGB: (json['storageGB'] as num?)?.toInt() ?? 128,
      priceVnd: (json['priceVnd'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrls: rawImages.map((e) => e.toString()).toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
