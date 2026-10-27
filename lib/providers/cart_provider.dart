import 'package:flutter/foundation.dart';

import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/models/variant_model.dart';
import '../data/repositories/cart_repository.dart';
import '../core/errors/app_exception.dart';
import '../data/repositories/product_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;
  final ProductRepository _productRepository;
  final List<CartItemModel> _items = [];
  String _currentUserId = 'guest';

  CartProvider({
    CartRepository? cartRepository,
    ProductRepository? productRepository,
  }) : _cartRepository = cartRepository ?? CartRepository(),
       _productRepository = productRepository ?? ProductRepository() {
    loadCart(_currentUserId);
  }

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  int get subtotalVnd =>
      _items.fold<int>(0, (sum, item) => sum + item.lineTotalVnd);

  Future<void> loadCart(String userId) async {
    final previousUser = _currentUserId;
    _currentUserId = userId;
    final loaded = await _cartRepository.loadCart(userId);
    final synced = loaded.map((item) {
      final v =
          _productRepository.findVariantById(item.productId, item.variantId);
      if (v != null && v.priceVnd != item.priceVnd) {
        return item.copyWith(priceVnd: v.priceVnd);
      }
      return item;
    }).toList();
    if (previousUser != userId) {
      _items
        ..clear()
        ..addAll(synced);
    } else {
      for (final item in synced) {
        final idx = _items.indexWhere((e) => e.variantId == item.variantId);
        if (idx < 0) {
          _items.add(item);
        } else {
          _items[idx] = item;
        }
      }
    }
    notifyListeners();
  }

  Future<void> addVariantToCart({
    required ProductModel product,
    required VariantModel variant,
    int quantity = 1,
  }) async {
    final currentQuantity = _items
        .where((item) => item.variantId == variant.id)
        .fold<int>(0, (total, item) => total + item.quantity);
    if (quantity <= 0 || currentQuantity + quantity > variant.stock) {
      throw AppException('Số lượng vượt quá tồn kho (${variant.stock}).');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final existingIndex = _items.indexWhere(
      (item) => item.variantId == variant.id,
    );

    if (existingIndex >= 0) {
      final current = _items[existingIndex];
      _items[existingIndex] = current.copyWith(
        quantity: current.quantity + quantity,
        priceVnd: variant.priceVnd,
        updatedAt: now,
      );
    } else {
      _items.add(
        CartItemModel(
          productId: product.id,
          variantId: variant.id,
          productName: product.name,
          variantLabel: variant.label,
          priceVnd: variant.priceVnd,
          quantity: quantity,
          imageUrl: variant.imageUrls.isNotEmpty
              ? variant.imageUrls.first
              : product.thumbnailUrl,
          updatedAt: now,
        ),
      );
    }

    notifyListeners();
    await _cartRepository.saveCart(_currentUserId, _items);
  }

  Future<void> updateQuantity(String variantId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(variantId);
      return;
    }

    final index = _items.indexWhere((item) => item.variantId == variantId);
    if (index < 0) return;

    final variant = _productRepository.findVariantById(
      _items[index].productId,
      variantId,
    );
    if (variant != null && newQuantity > variant.stock) {
      throw AppException('Số lượng vượt quá tồn kho (${variant.stock}).');
    }

    _items[index] = _items[index].copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    notifyListeners();
    await _cartRepository.saveCart(_currentUserId, _items);
  }

  Future<void> removeItem(String variantId) async {
    _items.removeWhere((item) => item.variantId == variantId);
    notifyListeners();
    await _cartRepository.saveCart(_currentUserId, _items);
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _cartRepository.clearCart(_currentUserId);
  }

  Future<void> syncToCloud() =>
      _cartRepository.saveCart(_currentUserId, _items);
}
