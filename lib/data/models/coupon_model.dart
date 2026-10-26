class CouponModel {
  final String code;
  final String description;
  final int discountVnd;
  final int minOrderVnd;
  final bool isActive;

  const CouponModel({
    required this.code,
    required this.description,
    required this.discountVnd,
    required this.minOrderVnd,
    this.isActive = true,
  });
}
