class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String brandId;
  final String categoryId;
  final String description;
  final String thumbnailUrl;
  final int priceFromVnd;
  final Map<String, String> specs;
  final bool isActive;
  final bool isFeatured;
  final String condition;
  final String warrantyPolicy;
  final int soldCount;
  final double ratingAvg;
  final int reviewCount;
  final List<int> ramOptions;
  final List<int> storageOptions;
  final String defaultColorHex;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.brandId,
    required this.categoryId,
    required this.description,
    this.thumbnailUrl = '',
    required this.priceFromVnd,
    required this.specs,
    this.isActive = true,
    this.isFeatured = false,
    this.condition = 'Mới 100% Chính Hãng VN/A',
    this.warrantyPolicy =
        'Bảo hành chính hãng 12 tháng • 1 đổi 1 trong 30 ngày',
    this.soldCount = 45,
    this.ratingAvg = 4.9,
    this.reviewCount = 24,
    this.ramOptions = const [8, 12],
    this.storageOptions = const [128, 256, 512],
    this.defaultColorHex = '#1C1C1E',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime(2026, 10, 1);

  ProductModel copyWith({
    String? name,
    String? brandId,
    String? categoryId,
    String? description,
    int? priceFromVnd,
    List<int>? ramOptions,
    List<int>? storageOptions,
    Map<String, String>? specs,
    bool? isActive,
    bool? isFeatured,
    String? condition,
    String? warrantyPolicy,
    int? soldCount,
    double? ratingAvg,
    int? reviewCount,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      slug: slug,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl,
      priceFromVnd: priceFromVnd ?? this.priceFromVnd,
      specs: specs ?? this.specs,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      condition: condition ?? this.condition,
      warrantyPolicy: warrantyPolicy ?? this.warrantyPolicy,
      soldCount: soldCount ?? this.soldCount,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      reviewCount: reviewCount ?? this.reviewCount,
      ramOptions: ramOptions ?? this.ramOptions,
      storageOptions: storageOptions ?? this.storageOptions,
      defaultColorHex: defaultColorHex,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'brandId': brandId,
    'categoryId': categoryId,
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'priceFromVnd': priceFromVnd,
    'specs': specs,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'condition': condition,
    'warrantyPolicy': warrantyPolicy,
    'soldCount': soldCount,
    'ratingAvg': ratingAvg,
    'reviewCount': reviewCount,
    'ramOptions': ramOptions,
    'storageOptions': storageOptions,
    'defaultColorHex': defaultColorHex,
  };

  factory ProductModel.fromJson(String id, Map<String, dynamic> json) {
    final rawSpecs = json['specs'] as Map<String, dynamic>? ?? {};
    final rawRam = json['ramOptions'] as List<dynamic>?;
    final rawStorage = json['storageOptions'] as List<dynamic>?;
    return ProductModel(
      id: id,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      brandId: json['brandId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? 'smartphones',
      description: json['description']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      priceFromVnd: (json['priceFromVnd'] as num?)?.toInt() ?? 0,
      specs: rawSpecs.map((k, v) => MapEntry(k, v.toString())),
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      condition: json['condition']?.toString() ?? 'Mới 100% Chính Hãng VN/A',
      warrantyPolicy:
          json['warrantyPolicy']?.toString() ??
          'Bảo hành chính hãng 12 tháng • 1 đổi 1 trong 30 ngày',
      soldCount: (json['soldCount'] as num?)?.toInt() ?? 42,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 18,
      ramOptions: rawRam != null
          ? rawRam.map((e) => (e as num).toInt()).toList()
          : const [8, 12],
      storageOptions: rawStorage != null
          ? rawStorage.map((e) => (e as num).toInt()).toList()
          : const [128, 256, 512],
      defaultColorHex: json['defaultColorHex']?.toString() ?? '#1C1C1E',
    );
  }
}
