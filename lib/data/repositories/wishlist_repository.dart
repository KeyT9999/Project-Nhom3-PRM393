import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/constants/firestore_collections.dart';
import '../local/local_file_storage_service.dart';

class WishlistRepository {
  final LocalFileStorageService _localStorage;

  WishlistRepository({LocalFileStorageService? localStorage})
    : _localStorage = localStorage ?? LocalFileStorageService();

  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  Future<List<String>> loadFavoriteProductIds(String? userId) async {
    final rawItems = await _localStorage.loadFavoriteItems(userId);
    final localIds = rawItems
        .map((e) => e['productId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    if (_isFirebaseReady &&
        userId != null &&
        userId.isNotEmpty &&
        userId != 'guest') {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(FirestoreCollections.wishlist)
            .get();
        final cloudIds = snap.docs.map((doc) => doc.id).toList();
        await _localStorage.saveFavoriteItems(userId, [
          for (final id in cloudIds) {'productId': id},
        ]);
        return cloudIds;
      } catch (_) {}
    }

    return localIds.toList();
  }

  Future<void> saveFavoriteProductIds(
    String? userId,
    List<String> productIds,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final items = productIds
        .map((id) => {'productId': id, 'createdAt': now})
        .toList();
    await _localStorage.saveFavoriteItems(userId, items);

    if (_isFirebaseReady &&
        userId != null &&
        userId.isNotEmpty &&
        userId != 'guest') {
      try {
        final col = FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection(FirestoreCollections.wishlist);
        final batch = FirebaseFirestore.instance.batch();
        final existing = await col.get();
        final retained = productIds.toSet();
        for (final doc in existing.docs) {
          if (!retained.contains(doc.id)) batch.delete(doc.reference);
        }
        for (final id in productIds) {
          batch.set(col.doc(id), {'productId': id, 'createdAt': now});
        }
        await batch.commit();
      } catch (_) {}
    }
  }
}
