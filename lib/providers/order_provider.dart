import 'package:flutter/foundation.dart';

import '../data/models/address_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/order_model.dart';
import '../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  bool _isSubmitting = false;

  OrderProvider({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository();

  List<OrderModel> get orders => _orderRepository.orders;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadOrders(String userId, {bool isAdmin = false}) async {
    await _orderRepository.loadOrders(userId, isAdmin: isAdmin);
    notifyListeners();
  }

  int get totalRevenueVnd => _orderRepository.orders
      .where((o) => o.status != 'cancelled' && o.status != 'failed_delivery')
      .fold<int>(0, (sum, o) => sum + o.totalVnd);

  int get pendingOrdersCount =>
      _orderRepository.orders.where((o) => o.status == 'pending').length;

  List<OrderModel> ordersByStatus(String statusFilter, {String? userId}) {
    final visible = userId == null
        ? orders
        : orders.where((o) => o.userId == userId).toList();
    if (statusFilter == 'all' || statusFilter.isEmpty) {
      return visible;
    }
    return visible.where((o) => o.status == statusFilter).toList();
  }

  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required AddressModel shippingAddress,
    String? requestId,
    String? couponCode,
    String paymentMethod = 'cod',
    String paymentStatus = 'unpaid',
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final order = await _orderRepository.createOrder(
        userId: userId,
        items: items,
        shippingAddress: shippingAddress,
        requestId: requestId,
        couponCode: couponCode,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
      );
      notifyListeners();
      return order;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// F16: Khách hàng hủy đơn hàng khi còn ở trạng thái `pending` hoặc `confirmed`
  Future<OrderModel?> cancelOrder(String orderId) async {
    final updated = await _orderRepository.updateOrderStatus(
      orderId: orderId,
      newStatus: 'cancelled',
      note: 'Khách hàng yêu cầu hủy đơn (Đã hoàn lại tồn kho)',
    );
    notifyListeners();
    return updated;
  }

  /// A06: Admin cập nhật trạng thái đơn hàng
  Future<OrderModel?> adminUpdateOrderStatus({
    required String orderId,
    required String newStatus,
    required String note,
  }) async {
    final updated = await _orderRepository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      note: note,
    );
    notifyListeners();
    return updated;
  }

  OrderModel? findOrder(String codeOrId) {
    return _orderRepository.findOrderByCodeOrId(codeOrId);
  }
}
