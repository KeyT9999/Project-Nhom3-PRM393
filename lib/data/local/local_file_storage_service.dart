import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalFileStorageService {
  static const int _schemaVersion = 1;

  /// Mã hóa userId thành chuỗi an toàn để đặt tên file trên Android
  String _encodeSafeUserId(String? userId) {
    final rawId = (userId == null || userId.trim().isEmpty) ? 'guest' : userId;
    return base64Url.encode(utf8.encode(rawId));
  }

  /// Lấy đối tượng File trong thư mục ApplicationDocumentsDirectory của Android
  Future<File> _getLocalFile(String prefix, String? userId) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeId = _encodeSafeUserId(userId);
    return File('${dir.path}/${prefix}_$safeId.json');
  }

  /// Lưu danh sách Giỏ hàng vào file `cart_<safeId>.json`
  Future<void> saveCartItems(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final file = await _getLocalFile('cart', userId);
      final payload = {
        'schemaVersion': _schemaVersion,
        'userId': userId ?? 'guest',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'items': items,
      };
      await file.writeAsString(jsonEncode(payload), flush: true);
    } catch (_) {}
  }

  /// Đọc danh sách Giỏ hàng từ file `cart_<safeId>.json`
  Future<List<Map<String, dynamic>>> loadCartItems(String? userId) async {
    try {
      final file = await _getLocalFile('cart', userId);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawList = decoded['items'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Xóa sạch giỏ hàng cục bộ (gọi sau khi Đặt hàng thành công)
  Future<void> clearCart(String? userId) async {
    try {
      final file = await _getLocalFile('cart', userId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Lưu danh sách Yêu thích vào file `favorites_<safeId>.json`
  Future<void> saveFavoriteItems(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final file = await _getLocalFile('favorites', userId);
      final payload = {
        'schemaVersion': _schemaVersion,
        'userId': userId ?? 'guest',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'items': items,
      };
      await file.writeAsString(jsonEncode(payload), flush: true);
    } catch (_) {}
  }

  /// Đọc danh sách Yêu thích từ file `favorites_<safeId>.json`
  Future<List<Map<String, dynamic>>> loadFavoriteItems(String? userId) async {
    try {
      final file = await _getLocalFile('favorites', userId);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawList = decoded['items'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Lưu Sổ địa chỉ nhận hàng vào file `addresses_<safeId>.json`
  Future<void> saveAddresses(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final file = await _getLocalFile('addresses', userId);
      final payload = {
        'schemaVersion': _schemaVersion,
        'userId': userId ?? 'guest',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'items': items,
      };
      await file.writeAsString(jsonEncode(payload), flush: true);
    } catch (_) {}
  }

  /// Đọc Sổ địa chỉ từ file `addresses_<safeId>.json`
  Future<List<Map<String, dynamic>>> loadAddresses(String? userId) async {
    try {
      final file = await _getLocalFile('addresses', userId);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawList = decoded['items'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Lưu danh sách Đơn hàng vào file `orders_<safeId>.json`
  Future<void> saveOrders(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final file = await _getLocalFile('orders', userId);
      final payload = {
        'schemaVersion': _schemaVersion,
        'userId': userId ?? 'guest',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'items': items,
      };
      await file.writeAsString(jsonEncode(payload), flush: true);
    } catch (_) {}
  }

  /// Đọc danh sách Đơn hàng từ file `orders_<safeId>.json`
  Future<List<Map<String, dynamic>>> loadOrders(String? userId) async {
    try {
      final file = await _getLocalFile('orders', userId);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawList = decoded['items'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Lưu Cache danh mục sản phẩm vào catalog_cache.json (Phục vụ F23 Offline Mode)
  Future<void> saveCatalogCache(List<Map<String, dynamic>> products) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/catalog_cache.json');
      final payload = {
        'schemaVersion': _schemaVersion,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'products': products,
      };
      await file.writeAsString(jsonEncode(payload), flush: true);
    } catch (_) {}
  }

  /// Đọc Cache danh mục sản phẩm từ catalog_cache.json
  Future<List<Map<String, dynamic>>> loadCatalogCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/catalog_cache.json');
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawList = decoded['products'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
