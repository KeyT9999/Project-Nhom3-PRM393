import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/constants/firestore_collections.dart';
import '../local/cart_database.dart';
import '../local/local_file_storage_service.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final LocalFileStorageService _localStorage;
  final CartDatabase _cartDatabase;

  CartRepository({
    LocalFileStorageService? localStorage,
    CartDatabase? cartDatabase,
  })  : _localStorage = localStorage ?? LocalFileStorageService(),
        _cartDatabase = cartDatabase ??
            CartDatabase(fileStorage: localStorage);

  LocalFileStorageService get localStorage => _localStorage;
  CartDatabase get cartDatabase => _cartDatabase;

  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  /// S01: Đọc giỏ hàng từ SQLite (SmartStore.db), hợp nhất giỏ `guest` (nếu vừa đăng nhập)
  /// và hợp nhất với Cloud Firestore theo quy tắc Last-Write-Wins dựa trên `variantId` và `updatedAt`.
  Future<List<CartItemModel>> loadCart(String? userId) async {
    final rawItems = await _cartDatabase.loadCartItems(userId);
    final localItems = rawItems.map(CartItemModel.fromJson).toList();

    final mergedMap = <String, CartItemModel>{
      for (final item in localItems) item.variantId: item,
    };

    // Nếu người dùng vừa đăng nhập (userId != 'guest'), hợp nhất giỏ hàng từ giỏ guest sang
    if (userId != null && userId.isNotEmpty && userId != 'guest') {
      final guestRaw = await _cartDatabase.loadCartItems('guest');
      if (guestRaw.isNotEmpty) {
        for (final gJson in guestRaw) {
          final guestItem = CartItemModel.fromJson(gJson);
          final existing = mergedMap[guestItem.variantId];
          if (existing == null ||
              guestItem.updatedAt.compareTo(existing.updatedAt) >= 0) {
            mergedMap[guestItem.variantId] = guestItem;
          }
        }
        await _cartDatabase.clearCart('guest');
      }
    }

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

        for (final cItem in cloudItems) {
          final existing = mergedMap[cItem.variantId];
          if (existing == null ||
              cItem.updatedAt.compareTo(existing.updatedAt) > 0) {
            mergedMap[cItem.variantId] = cItem;
          }
        }

        final mergedList = mergedMap.values.toList();
        await saveCart(userId, mergedList);
        return mergedList;
      } catch (_) {}
    }

    final result = mergedMap.values.toList();
    await _cartDatabase.saveCartItems(
      userId,
      result.map((e) => e.toJson()).toList(),
    );
    return result;
  }

  Future<void> saveCart(String? userId, List<CartItemModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    // 1. Lưu ngay vào SQLite (smartstore.db) trên thiết bị Android
    await _cartDatabase.saveCartItems(userId, jsonList);

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
    await _cartDatabase.clearCart(userId);
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

