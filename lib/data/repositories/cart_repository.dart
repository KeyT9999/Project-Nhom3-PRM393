import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/constants/firestore_collections.dart';
import '../local/local_file_storage_service.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final LocalFileStorageService _localStorage;

  CartRepository({LocalFileStorageService? localStorage})
    : _localStorage = localStorage ?? LocalFileStorageService();

  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  /// S01: Đọc giỏ hàng từ Local JSON (`cart_<uid>.json`) và hợp nhất với Cloud Firestore
  /// theo quy tắc Last-Write-Wins dựa trên `variantId` và `updatedAt` (không cộng dồn trùng lặp).
  Future<List<CartItemModel>> loadCart(String? userId) async {
    final rawItems = await _localStorage.loadCartItems(userId);
    final localItems = rawItems.map(CartItemModel.fromJson).toList();

    if (_isFirebaseReady &&
        userId != null &&
        userId.isNotEmpty &&
        userId != 'guest') {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(FirestoreCollections.cart)
            .get();

        final cloudItems = snap.docs
            .map((d) => CartItemModel.fromJson(d.data()))
            .toList();

        final mergedList = cloudItems;
        await _localStorage.saveCartItems(
          userId,
          mergedList.map((e) => e.toJson()).toList(),
        );
        return mergedList;
      } catch (_) {}
    }

    return localItems;
  }

  Future<void> saveCart(String? userId, List<CartItemModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    // 1. Lưu ngay vào file cart_<uid>.json trên thiết bị Android
    await _localStorage.saveCartItems(userId, jsonList);

    // 2. Đồng bộ lên Cloud Firestore nếu người dùng đã đăng nhập
    if (_isFirebaseReady &&
        userId != null &&
        userId.isNotEmpty &&
        userId != 'guest') {
      try {
        final cartCol = FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(FirestoreCollections.cart);
        final batch = FirebaseFirestore.instance.batch();
        final existing = await cartCol.get();
        final retained = items.map((item) => item.variantId).toSet();
        for (final doc in existing.docs) {
          if (!retained.contains(doc.id)) batch.delete(doc.reference);
        }
        for (final item in items) {
          batch.set(cartCol.doc(item.variantId), item.toJson());
        }
        await batch.commit();
      } catch (_) {}
    }
  }

  Future<void> clearCart(String? userId) async {
    await _localStorage.clearCart(userId);
    if (_isFirebaseReady &&
        userId != null &&
        userId.isNotEmpty &&
        userId != 'guest') {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(FirestoreCollections.cart)
            .get();
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (_) {}
    }
  }
}
