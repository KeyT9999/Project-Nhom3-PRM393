import 'address_model.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String orderCode;
  final String requestId;
  final String userId;
  final List<CartItemModel> items;
  final int subtotalVnd;
  final int shippingFeeVnd;
  final int discountVnd;
  final String? couponCode;
  final int totalVnd;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final bool restocked;
  final AddressModel shippingAddress;
  final List<Map<String, String>> statusHistory;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderCode,
    this.requestId = '',
    required this.userId,
    required this.items,
    required this.subtotalVnd,
    required this.shippingFeeVnd,
    this.discountVnd = 0,
    this.couponCode,
    required this.totalVnd,
    this.paymentMethod = 'cod',
    this.paymentStatus = 'unpaid',
    this.status = 'pending',
    this.restocked = false,
    required this.shippingAddress,
    this.statusHistory = const [],
    required this.createdAt,
  });

  bool get canBeCancelled => status == 'pending' || status == 'confirmed';

  String get statusLabelVi {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang đóng gói';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Giao thành công';
      case 'cancelled':
        return 'Đã hủy';
      case 'failed_delivery':
        return 'Giao thất bại';
      default:
        return status;
    }
  }

  OrderModel copyWith({
    String? status,
    String? paymentStatus,
    bool? restocked,
    List<Map<String, String>>? statusHistory,
  }) {
    return OrderModel(
      id: id,
      orderCode: orderCode,
      requestId: requestId,
      userId: userId,
      items: items,
      subtotalVnd: subtotalVnd,
      shippingFeeVnd: shippingFeeVnd,
      discountVnd: discountVnd,
      couponCode: couponCode,
      totalVnd: totalVnd,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      restocked: restocked ?? this.restocked,
      shippingAddress: shippingAddress,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'orderCode': orderCode,
    'requestId': requestId,
    'userId': userId,
    'items': items
        .map(
          (e) => {
            ...e.toJson(),
            'unitPriceVnd': e.priceVnd,
            'lineTotalVnd': e.lineTotalVnd,
          },
        )
        .toList(),
    'subtotalVnd': subtotalVnd,
    'shippingFeeVnd': shippingFeeVnd,
    'discountVnd': discountVnd,
    'couponCode': couponCode,
    'totalVnd': totalVnd,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus,
    'status': status,
    'restocked': restocked,
    'shippingAddress': shippingAddress.toJson(),
    'statusHistory': statusHistory,
    'createdAtIso': createdAt.toUtc().toIso8601String(),
  };

  factory OrderModel.fromJson(String id, Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawAddress = json['shippingAddress'] as Map<String, dynamic>? ?? {};
    final rawHistory = json['statusHistory'] as List<dynamic>? ?? [];
    return OrderModel(
      id: id,
      orderCode: json['orderCode']?.toString() ?? 'SS-2026-0001',
      requestId: json['requestId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? 'guest',
      items: rawItems
          .map(
            (e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      subtotalVnd: (json['subtotalVnd'] as num?)?.toInt() ?? 0,
      shippingFeeVnd: (json['shippingFeeVnd'] as num?)?.toInt() ?? 30000,
      discountVnd: (json['discountVnd'] as num?)?.toInt() ?? 0,
      couponCode: json['couponCode']?.toString(),
      totalVnd: (json['totalVnd'] as num?)?.toInt() ?? 0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'cod',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      status: json['status']?.toString() ?? 'pending',
      restocked: json['restocked'] as bool? ?? false,
      shippingAddress: AddressModel.fromJson(rawAddress),
      statusHistory: rawHistory
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      createdAt: json['createdAtIso'] != null
          ? (DateTime.tryParse(json['createdAtIso'].toString()) ??
                DateTime.now())
          : DateTime.now(),
    );
  }
}
