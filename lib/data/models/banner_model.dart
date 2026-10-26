class BannerModel {
  final String id;
  final String badge;
  final String title;
  final String subtitle;
  final String targetProductId;
  final bool isActive;
  final int sortOrder;

  const BannerModel({
    required this.id,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.targetProductId,
    this.isActive = true,
    this.sortOrder = 1,
  });

  BannerModel copyWith({
    String? badge,
    String? title,
    String? subtitle,
    String? targetProductId,
    bool? isActive,
    int? sortOrder,
  }) {
    return BannerModel(
      id: id,
      badge: badge ?? this.badge,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      targetProductId: targetProductId ?? this.targetProductId,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'badge': badge,
    'title': title,
    'subtitle': subtitle,
    'targetProductId': targetProductId,
    'isActive': isActive,
    'sortOrder': sortOrder,
  };

  factory BannerModel.fromJson(String id, Map<String, dynamic> json) =>
      BannerModel(
        id: id,
        badge: json['badge']?.toString() ?? 'SMARTSTORE EXCLUSIVE',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        targetProductId: json['targetProductId']?.toString() ?? 'iphone_16_pro',
        isActive: json['isActive'] as bool? ?? true,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 1,
      );
}
