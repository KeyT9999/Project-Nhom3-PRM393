class CartItemModel {
  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final int priceVnd;
  final int quantity;
  final String imageUrl;
  final String updatedAt;

  const CartItemModel({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.priceVnd,
    required this.quantity,
    required this.imageUrl,
    required this.updatedAt,
  });

  int get lineTotalVnd => priceVnd * quantity;

  CartItemModel copyWith({int? quantity, int? priceVnd, String? updatedAt}) {
    return CartItemModel(
      productId: productId,
      variantId: variantId,
      productName: productName,
      variantLabel: variantLabel,
      priceVnd: priceVnd ?? this.priceVnd,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variantId': variantId,
    'productName': productName,
    'variantLabel': variantLabel,
    'priceVnd': priceVnd,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'updatedAt': updatedAt,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: json['productId']?.toString() ?? '',
    variantId: json['variantId']?.toString() ?? '',
    productName: json['productName']?.toString() ?? '',
    variantLabel: json['variantLabel']?.toString() ?? '',
    priceVnd: (json['priceVnd'] as num?)?.toInt() ?? 0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    imageUrl: json['imageUrl']?.toString() ?? '',
    updatedAt:
        json['updatedAt']?.toString() ??
        DateTime.now().toUtc().toIso8601String(),
  );
}
