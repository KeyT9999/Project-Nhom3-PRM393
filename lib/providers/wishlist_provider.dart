import 'package:flutter/foundation.dart';

import '../data/repositories/wishlist_repository.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _wishlistRepository;
  final Set<String> _favoriteProductIds = {};
  String _currentUserId = 'guest';

  WishlistProvider({WishlistRepository? wishlistRepository})
    : _wishlistRepository = wishlistRepository ?? WishlistRepository() {
    loadWishlist(_currentUserId);
  }

  Set<String> get favoriteProductIds => Set.unmodifiable(_favoriteProductIds);

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);

  Future<void> loadWishlist(String userId) async {
    final prevUser = _currentUserId;
    _currentUserId = userId;
    final ids = await _wishlistRepository.loadFavoriteProductIds(userId);
    if (prevUser != userId || _favoriteProductIds.isEmpty) {
      _favoriteProductIds
        ..clear()
        ..addAll(ids);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();
    await _wishlistRepository.saveFavoriteProductIds(
      _currentUserId,
      _favoriteProductIds.toList(),
    );
  }

  Future<void> syncToCloud() => _wishlistRepository.saveFavoriteProductIds(
    _currentUserId,
    _favoriteProductIds.toList(),
  );
}
