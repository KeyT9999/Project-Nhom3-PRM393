class BrandModel {
  final String id;
  final String name;
  final String slug;
  final String origin;
  final bool isActive;

  const BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.origin = 'Chính hãng',
    this.isActive = true,
  });

  BrandModel copyWith({
    String? name,
    String? slug,
    String? origin,
    bool? isActive,
  }) {
    return BrandModel(
      id: id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      origin: origin ?? this.origin,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'origin': origin,
    'isActive': isActive,
  };

  factory BrandModel.fromJson(String id, Map<String, dynamic> json) =>
      BrandModel(
        id: id,
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        origin: json['origin']?.toString() ?? 'Chính hãng',
        isActive: json['isActive'] as bool? ?? true,
      );
}
