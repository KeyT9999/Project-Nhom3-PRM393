class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAtIso': createdAt.toUtc().toIso8601String(),
  };

  factory ReviewModel.fromJson(String id, Map<String, dynamic> json) =>
      ReviewModel(
        id: id,
        productId: json['productId']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        userName: json['userName']?.toString() ?? 'Khách hàng',
        rating: (json['rating'] as num?)?.toInt() ?? 5,
        comment: json['comment']?.toString() ?? '',
        createdAt: json['createdAtIso'] != null
            ? (DateTime.tryParse(json['createdAtIso'].toString()) ??
                  DateTime.now())
            : DateTime.now(),
      );
}
