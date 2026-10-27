import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'local_file_storage_service.dart';

class CartDatabase {
  static const String tableName = 'Cart';
  static const String databaseName = 'smartstore.db';
  static const int databaseVersion = 1;

  Database? _db;
  final DatabaseFactory? _factory;
  String? _customPath;
  final LocalFileStorageService _fileStorage;

  CartDatabase({
    Database? db,
    DatabaseFactory? databaseFactory,
    String? customPath,
    LocalFileStorageService? fileStorage,
  })  : _factory = databaseFactory,
        _fileStorage = fileStorage ?? LocalFileStorageService() {
    _db = db;
    _customPath = customPath;
  }

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      await createTables(_db!);
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath;
    final custom = _customPath;
    if (custom != null) {
      dbPath = custom;
    } else {
      final factory = _factory;
      final databasesPath = factory != null
          ? await factory.getDatabasesPath()
          : await getDatabasesPath();
      dbPath = p.join(databasesPath, databaseName);
    }

    final factory = _factory;
    final openFunc = factory != null ? factory.openDatabase : openDatabase;

    return await openFunc(
      dbPath,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: (db, version) async {
          await createTables(db);
        },
      ),
    );
  }

  static Future<void> createTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        variant_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        variant_label TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        image_url TEXT,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, variant_id)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_cart_user_id ON $tableName (user_id)
    ''');
  }

  String _cleanUserId(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      return 'guest';
    }
    return userId.trim();
  }

  List<Map<String, dynamic>> _mapRows(List<Map<String, Object?>> rows) {
    return rows.map((row) {
      return <String, dynamic>{
        'productId': row['product_id']?.toString() ?? '',
        'variantId': row['variant_id']?.toString() ?? '',
        'productName': row['product_name']?.toString() ?? '',
        'variantLabel': row['variant_label']?.toString() ?? '',
        'priceVnd': (row['price'] as num?)?.toInt() ?? 0,
        'quantity': (row['quantity'] as num?)?.toInt() ?? 1,
        'imageUrl': row['image_url']?.toString() ?? '',
        'updatedAt': row['updated_at']?.toString() ?? '',
      };
    }).toList();
  }

  /// S01: Đọc danh sách giỏ hàng của user từ SQLite
  /// Nếu chưa có bản ghi và tồn tại file JSON cũ, tự động di trú dữ liệu cũ vào SQLite (tối đa 1 lần)
  Future<List<Map<String, dynamic>>> loadCartItems(String? userId) async {
    try {
      final db = await database;
      final uid = _cleanUserId(userId);
      final rows = await db.query(
        tableName,
        where: 'user_id = ?',
        whereArgs: [uid],
        orderBy: 'id ASC',
      );

      if (rows.isEmpty) {
        // Di trú dữ liệu cũ từ JSON sang SQLite (chỉ thực hiện tối đa 1 lần)
        final oldItems = await _fileStorage.loadCartItems(uid);
        if (oldItems.isNotEmpty) {
          try {
            await saveCartItems(uid, oldItems);
            // Đọc lại DB xác nhận số dòng > 0 trước khi xóa file cũ
            final checkRows = await db.query(
              tableName,
              where: 'user_id = ?',
              whereArgs: [uid],
              orderBy: 'id ASC',
            );
            if (checkRows.isNotEmpty) {
              await _fileStorage.clearCart(uid);
              return _mapRows(checkRows);
            }
          } catch (_) {}
        }
        return [];
      }

      return _mapRows(rows);
    } catch (_) {
      return [];
    }
  }

  /// Lưu toàn bộ giỏ hàng của user trong 1 transaction SQLite
  /// Gộp các dòng có cùng variant_id (cộng dồn quantity) và bảo vệ bằng UNIQUE constraint
  Future<void> saveCartItems(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final db = await database;
      final uid = _cleanUserId(userId);

      // Gộp các dòng trùng variantId trước khi ghi: cộng dồn quantity
      final mergedMap = <String, Map<String, dynamic>>{};
      for (final item in items) {
        final variantId = item['variantId']?.toString() ?? '';
        if (variantId.isEmpty) continue;

        if (mergedMap.containsKey(variantId)) {
          final existing = mergedMap[variantId]!;
          final qExisting = (existing['quantity'] as num?)?.toInt() ?? 1;
          final qNew = (item['quantity'] as num?)?.toInt() ?? 1;
          final combined = Map<String, dynamic>.from(existing);
          combined['quantity'] = qExisting + qNew;
          if (item['updatedAt'] != null) {
            combined['updatedAt'] = item['updatedAt'];
          }
          mergedMap[variantId] = combined;
        } else {
          mergedMap[variantId] = Map<String, dynamic>.from(item);
        }
      }

      await db.transaction((txn) async {
        await txn.delete(
          tableName,
          where: 'user_id = ?',
          whereArgs: [uid],
        );

        for (final item in mergedMap.values) {
          final priceVnd = (item['priceVnd'] as num?)?.toDouble() ?? 0.0;
          final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
          await txn.insert(
            tableName,
            {
              'user_id': uid,
              'product_id': item['productId']?.toString() ?? '',
              'variant_id': item['variantId']?.toString() ?? '',
              'product_name': item['productName']?.toString() ?? '',
              'variant_label': item['variantLabel']?.toString() ?? '',
              'price': priceVnd,
              'quantity': quantity,
              'image_url': item['imageUrl']?.toString() ?? '',
              'updated_at': item['updatedAt']?.toString() ??
                  DateTime.now().toUtc().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (_) {}
  }

  /// Xóa sạch giỏ hàng của user trong SQLite
  Future<void> clearCart(String? userId) async {
    try {
      final db = await database;
      final uid = _cleanUserId(userId);
      await db.delete(
        tableName,
        where: 'user_id = ?',
        whereArgs: [uid],
      );
    } catch (_) {}
  }

  /// Đóng database nếu đang mở
  Future<void> close() async {
    try {
      if (_db != null && _db!.isOpen) {
        await _db!.close();
      }
    } catch (_) {}
  }
}
