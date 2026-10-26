import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/errors/app_exception.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../local/local_file_storage_service.dart';
import 'product_repository.dart';

class OrderRepository {
  final ProductRepository _productRepository;
  final LocalFileStorageService _localStorage;
  final List<OrderModel> _orders = [];

  OrderRepository({
    ProductRepository? productRepository,
    LocalFileStorageService? localStorage,
  }) : _productRepository = productRepository ?? ProductRepository(),
       _localStorage = localStorage ?? LocalFileStorageService();

  List<OrderModel> get orders => List.unmodifiable(_orders);

  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  Future<void> loadOrders(String userId, {bool isAdmin = false}) async {
    try {
      final local = await _localStorage.loadOrders(userId);
      for (final data in local) {
        final order = OrderModel.fromJson(data['id'].toString(), data);
        final idx = _orders.indexWhere((o) => o.id == order.id);
        if (idx < 0) {
          _orders.add(order);
        } else {
          _orders[idx] = order;
        }
      }
    } catch (_) {}
    if (_isFirebaseReady && (isAdmin || userId != 'guest')) {
      try {
        final collection = FirebaseFirestore.instance.collection(
          FirestoreCollections.orders,
        );
        final snapshot = isAdmin
            ? await collection.get()
            : await collection.where('userId', isEqualTo: userId).get();
        for (final doc in snapshot.docs) {
          final order = OrderModel.fromJson(doc.id, doc.data());
          final index = _orders.indexWhere((o) => o.id == order.id);
          if (index < 0) {
            _orders.add(order);
          } else {
            _orders[index] = order;
          }
        }
        await _saveOrders(userId);
      } catch (_) {}
    }
    _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveOrders(String userId) async {
    await _localStorage.saveOrders(userId, [
      for (final order in _orders.where((o) => o.userId == userId))
        {'id': order.id, ...order.toJson()},
    ]);
  }

  /// S02, S03, S04, S07, S08:
  /// Kiểm tra tồn kho, xác minh giá thực tế, chống đặt trùng (`requestId`),
  /// trừ kho nguyên tử và tạo đơn hàng Snapshot.
  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required AddressModel shippingAddress,
    String? requestId,
    String? couponCode,
    int? shippingFeeVnd,
    String paymentMethod = 'cod',
    String paymentStatus = 'unpaid',
  }) async {
    final reqId =
        requestId ?? 'req_${userId}_${DateTime.now().millisecondsSinceEpoch}';

    // TC12: Chống đặt hàng trùng lặp (Idempotency)
    for (final existing in _orders) {
      if (existing.requestId == reqId && existing.userId == userId) {
        return existing;
      }
    }

    if (items.isEmpty) {
      throw const AppException('Giỏ hàng trống, không thể tạo đơn hàng.');
    }

    // S02 & S03: Xác minh tồn kho & đọc lại đơn giá thực tế trên Server/Repository
    final List<CartItemModel> verifiedItems = [];
    for (final item in items) {
      final realVariant = _productRepository.findVariantById(
        item.productId,
        item.variantId,
      );
      if (realVariant != null) {
        if (item.quantity > realVariant.stock) {
          // TC10: Đặt vượt tồn kho -> Server từ chối
          throw AppException(
            'Sản phẩm "${item.productName} (${item.variantLabel})" chỉ còn ${realVariant.stock} máy trong kho.',
            code: 'OUT_OF_STOCK',
          );
        }
        // TC14: Luôn lấy giá thực tế từ Server (`realVariant.priceVnd`)
        verifiedItems.add(item.copyWith(priceVnd: realVariant.priceVnd));
      } else {
        throw AppException(
          'Không tìm thấy biến thể ${item.variantId}.',
          code: 'VARIANT_NOT_FOUND',
        );
      }
    }

    // S04: Tính tổng tiền bằng số nguyên VND
    final subtotal = verifiedItems.fold<int>(
      0,
      (total, item) => total + item.lineTotalVnd,
    );

    int discount = 0;
    if (couponCode != null && couponCode.trim().isNotEmpty) {
      final coupon = _productRepository.validateCoupon(couponCode, subtotal);
      if (coupon != null) {
        discount = coupon.discountVnd;
      }
    }

    final effectiveShippingFee =
        shippingFeeVnd ??
        (subtotal <= 10000 ? 0 : AppConstants.defaultShippingFeeVnd);

    final totalVnd = (subtotal + effectiveShippingFee - discount).clamp(
      0,
      999999999,
    );
    final now = DateTime.now();
    final orderCode = 'SS-${now.year}-${now.microsecondsSinceEpoch}';

    final initialHistory = [
      {
        'status': 'pending',
        'title': paymentMethod == 'payos' && paymentStatus == 'paid'
            ? 'Đặt hàng & Thanh toán VietQR PayOS thành công'
            : 'Đặt hàng thành công',
        'time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day}/${now.month}/${now.year}',
      },
    ];

    String orderId = 'order_${base64Url.encode(utf8.encode(reqId))}';

    final order = OrderModel(
      id: orderId,
      orderCode: orderCode,
      requestId: reqId,
      userId: userId,
      items: verifiedItems,
      subtotalVnd: subtotal,
      shippingFeeVnd: effectiveShippingFee,
      discountVnd: discount,
      couponCode: couponCode,
      totalVnd: totalVnd,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      shippingAddress: shippingAddress,
      statusHistory: initialHistory,
      createdAt: now,
    );

    if (_isFirebaseReady) {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection(FirestoreCollections.orders).doc(orderId);
      orderId = docRef.id;
      OrderModel? existingCloudOrder;
      await db.runTransaction((transaction) async {
        final existingSnapshot = await transaction.get(docRef);
        if (existingSnapshot.exists && existingSnapshot.data() != null) {
          existingCloudOrder = OrderModel.fromJson(
            docRef.id,
            existingSnapshot.data()!,
          );
          return;
        }
        existingCloudOrder = null;
        final refs = [
          for (final item in verifiedItems)
            db
                .collection(FirestoreCollections.products)
                .doc(item.productId)
                .collection(FirestoreCollections.variants)
                .doc(item.variantId),
        ];
        final snapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
        for (final ref in refs) {
          snapshots.add(await transaction.get(ref));
        }
        for (var i = 0; i < verifiedItems.length; i++) {
          final item = verifiedItems[i];
          final data = snapshots[i].data();
          if (data == null ||
              (data['stock'] as num? ?? 0).toInt() < item.quantity) {
            throw AppException(
              'Không đủ tồn kho cho ${item.productName}.',
              code: 'OUT_OF_STOCK',
            );
          }
          transaction.update(refs[i], {
            'stock': (data['stock'] as num).toInt() - item.quantity,
          });
        }
        final soldByProduct = <String, int>{};
        for (final item in verifiedItems) {
          soldByProduct.update(
            item.productId,
            (current) => current + item.quantity,
            ifAbsent: () => item.quantity,
          );
        }
        for (final entry in soldByProduct.entries) {
          transaction.update(
            db.collection(FirestoreCollections.products).doc(entry.key),
            {'soldCount': FieldValue.increment(entry.value)},
          );
        }
        transaction.set(docRef, {
          ...order.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      if (existingCloudOrder != null) {
        _orders.insert(0, existingCloudOrder!);
        await _saveOrders(userId);
        return existingCloudOrder!;
      }
    }
    for (final item in verifiedItems) {
      await _productRepository.adjustVariantStock(
        item.productId,
        item.variantId,
        -item.quantity,
        syncCloud: false,
      );
      _productRepository.recordSale(item.productId, item.quantity);
    }

    final savedOrder = OrderModel(
      id: orderId,
      orderCode: order.orderCode,
      requestId: reqId,
      userId: order.userId,
      items: order.items,
      subtotalVnd: order.subtotalVnd,
      shippingFeeVnd: order.shippingFeeVnd,
      discountVnd: order.discountVnd,
      couponCode: order.couponCode,
      totalVnd: order.totalVnd,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      shippingAddress: order.shippingAddress,
      statusHistory: initialHistory,
      createdAt: now,
    );

    _orders.insert(0, savedOrder);
    await _saveOrders(userId);
    return savedOrder;
  }

  /// F16 & A06: Cập nhật trạng thái đơn hàng & Hoàn tồn kho 1 lần duy nhất nếu Hủy / Giao thất bại
  Future<OrderModel?> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required String note,
  }) async {
    final idx = _orders.indexWhere(
      (o) => o.id == orderId || o.orderCode == orderId,
    );
    if (idx < 0) return null;

    final current = _orders[idx];
    const transitions = {
      'pending': {'confirmed', 'cancelled'},
      'confirmed': {'processing', 'cancelled'},
      'processing': {'shipping', 'cancelled'},
      'shipping': {'delivered', 'failed_delivery'},
    };
    if (!(transitions[current.status]?.contains(newStatus) ?? false)) {
      throw AppException(
        'Không thể chuyển từ ${current.status} sang $newStatus.',
      );
    }
    bool restocked = current.restocked;

    // Quy tắc hoàn tồn kho (Restock Rule): Chỉ hoàn kho đúng 1 lần khi hủy hoặc giao thất bại
    if ((newStatus == 'cancelled' || newStatus == 'failed_delivery') &&
        !restocked) {
      for (final item in current.items) {
        await _productRepository.adjustVariantStock(
          item.productId,
          item.variantId,
          item.quantity,
        );
      }
      restocked = true;
    }

    final now = DateTime.now();
    final updatedHistory = List<Map<String, String>>.from(current.statusHistory)
      ..add({
        'status': newStatus,
        'title': note,
        'time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day}/${now.month}/${now.year}',
      });

    final paymentStatus = newStatus == 'delivered'
        ? 'paid'
        : current.paymentStatus;

    final updated = current.copyWith(
      status: newStatus,
      paymentStatus: paymentStatus,
      restocked: restocked,
      statusHistory: updatedHistory,
    );
    _orders[idx] = updated;
    await _saveOrders(current.userId);

    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.orders)
            .doc(current.id)
            .update({
              'status': newStatus,
              'paymentStatus': paymentStatus,
              'restocked': restocked,
              'statusHistory': updatedHistory,
            });
      } catch (_) {}
    }
    return updated;
  }

  /// Cập nhật trạng thái đã thanh toán qua PayOS cho đơn hàng chưa thanh toán
  Future<OrderModel?> markOrderPaidByPayos(String orderId) async {
    final idx = _orders.indexWhere(
      (o) => o.id == orderId || o.orderCode == orderId,
    );
    if (idx < 0) return null;

    final current = _orders[idx];
    final now = DateTime.now();
    final updatedHistory = List<Map<String, String>>.from(current.statusHistory)
      ..add({
        'status': current.status,
        'title': 'Thanh toán thành công qua VietQR PayOS',
        'time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day}/${now.month}/${now.year}',
      });

    final updated = current.copyWith(
      paymentMethod: 'payos',
      paymentStatus: 'paid',
      statusHistory: updatedHistory,
    );
    _orders[idx] = updated;
    await _saveOrders(current.userId);

    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.orders)
            .doc(current.id)
            .update({
              'paymentMethod': 'payos',
              'paymentStatus': 'paid',
              'statusHistory': updatedHistory,
            });
      } catch (_) {}
    }
    return updated;
  }

  OrderModel? findOrderByCodeOrId(String query) {
    final q = query.trim().toUpperCase();
    for (final o in _orders) {
      if (o.orderCode.toUpperCase() == q || o.id.toUpperCase() == q) {
        return o;
      }
    }
    return null;
  }
}
