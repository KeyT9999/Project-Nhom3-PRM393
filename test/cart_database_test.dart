import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartstore/data/local/cart_database.dart';
import 'package:smartstore/data/local/local_file_storage_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeLocalFileStorageService extends LocalFileStorageService {
  final Map<String, List<Map<String, dynamic>>> storage = {};

  @override
  Future<List<Map<String, dynamic>>> loadCartItems(String? userId) async {
    final uid =
        (userId == null || userId.trim().isEmpty) ? 'guest' : userId.trim();
    return List<Map<String, dynamic>>.from(storage[uid] ?? []);
  }

  @override
  Future<void> saveCartItems(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    final uid =
        (userId == null || userId.trim().isEmpty) ? 'guest' : userId.trim();
    storage[uid] = List<Map<String, dynamic>>.from(items);
  }

  @override
  Future<void> clearCart(String? userId) async {
    final uid =
        (userId == null || userId.trim().isEmpty) ? 'guest' : userId.trim();
    storage.remove(uid);
  }
}

class FaultyDatabaseFactory implements DatabaseFactory {
  @override
  Future<Database> openDatabase(
    String path, {
    OpenDatabaseOptions? options,
  }) async {
    throw Exception('Simulated SQLite DB open failure');
  }

  @override
  Future<void> deleteDatabase(String path) async {
    throw Exception('Simulated SQLite DB delete failure');
  }

  @override
  Future<bool> databaseExists(String path) async {
    throw Exception('Simulated SQLite DB exists failure');
  }

  @override
  Future<String> getDatabasesPath() async {
    throw Exception('Simulated SQLite getDatabasesPath failure');
  }

  @override
  Future<void> setDatabasesPath(String path) async {}

  @override
  Future<Uint8List> readDatabaseBytes(String path) async {
    throw Exception('Simulated SQLite readDatabaseBytes failure');
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) async {
    throw Exception('Simulated SQLite writeDatabaseBytes failure');
  }
}

class FailingSaveCartDatabase extends CartDatabase {
  FailingSaveCartDatabase({
    super.db,
    super.fileStorage,
  });

  @override
  Future<void> saveCartItems(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    throw Exception('Simulated save failure during migration');
  }
}

void main() {
  // Khởi tạo FFI engine để chạy SQLite in-memory trong môi trường unit test
  sqfliteFfiInit();

  group('CartDatabase - Tầng lưu trữ SQLite cho giỏ hàng (Mục 3.3 / 4.1)', () {
    late CartDatabase cartDb;
    late Database rawDb;

    setUp(() async {
      rawDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await CartDatabase.createTables(db);
          },
        ),
      );
      cartDb = CartDatabase(db: rawDb);
    });

    tearDown(() async {
      await cartDb.close();
    });

    test('Case a: Lưu rồi tải lại: dữ liệu đúng, kể cả quantity và priceVnd', () async {
      final item = {
        'productId': 'iphone_16_pro_max',
        'variantId': 'ip16pm_256_desert',
        'productName': 'iPhone 16 Pro Max Chính Hãng VN/A',
        'variantLabel': '8GB / 256GB • Titan Sa Mạc',
        'priceVnd': 31990000,
        'quantity': 2,
        'imageUrl': 'assets/images/ip16pm_desert.png',
        'updatedAt': '2026-10-27T10:00:00.000Z',
      };

      await cartDb.saveCartItems('user_test_01', [item]);
      final loaded = await cartDb.loadCartItems('user_test_01');

      expect(loaded.length, 1);
      final first = loaded.first;
      expect(first['productId'], 'iphone_16_pro_max');
      expect(first['variantId'], 'ip16pm_256_desert');
      expect(first['productName'], 'iPhone 16 Pro Max Chính Hãng VN/A');
      expect(first['variantLabel'], '8GB / 256GB • Titan Sa Mạc');
      expect(first['priceVnd'], 31990000);
      expect(first['quantity'], 2);
      expect(first['imageUrl'], 'assets/images/ip16pm_desert.png');
      expect(first['updatedAt'], '2026-10-27T10:00:00.000Z');
    });

    test('Case b: saveCartItems lần 2 với danh sách khác thay thế hẳn giỏ cũ (không cộng dồn)', () async {
      // Lần 1: Lưu sản phẩm A
      await cartDb.saveCartItems('user_test_01', [
        {
          'productId': 'prod_a',
          'variantId': 'var_a',
          'productName': 'Sản phẩm A',
          'priceVnd': 100000,
          'quantity': 3,
        },
      ]);
      var loaded = await cartDb.loadCartItems('user_test_01');
      expect(loaded.length, 1);
      expect(loaded.first['variantId'], 'var_a');
      expect(loaded.first['quantity'], 3);

      // Lần 2: Lưu sản phẩm B (danh sách mới hoàn toàn)
      await cartDb.saveCartItems('user_test_01', [
        {
          'productId': 'prod_b',
          'variantId': 'var_b',
          'productName': 'Sản phẩm B',
          'priceVnd': 200000,
          'quantity': 1,
        },
      ]);
      loaded = await cartDb.loadCartItems('user_test_01');
      expect(loaded.length, 1);
      expect(loaded.first['variantId'], 'var_b');
      expect(loaded.first['quantity'], 1);
      // Sản phẩm A phải bị xóa hoàn toàn khỏi giỏ hàng
      expect(loaded.any((e) => e['variantId'] == 'var_a'), isFalse);
    });

    test('Case c: Hai user khác nhau không thấy giỏ của nhau; guest tách biệt', () async {
      await cartDb.saveCartItems('user_alpha', [
        {
          'productId': 'prod_1',
          'variantId': 'var_alpha',
          'productName': 'Hàng của Alpha',
          'priceVnd': 50000,
          'quantity': 1,
        },
      ]);
      await cartDb.saveCartItems('user_beta', [
        {
          'productId': 'prod_2',
          'variantId': 'var_beta',
          'productName': 'Hàng của Beta',
          'priceVnd': 80000,
          'quantity': 4,
        },
      ]);
      // userId là null hoặc chuỗi rỗng sẽ tự động ánh xạ sang 'guest'
      await cartDb.saveCartItems(null, [
        {
          'productId': 'prod_3',
          'variantId': 'var_guest',
          'productName': 'Hàng của Guest',
          'priceVnd': 120000,
          'quantity': 2,
        },
      ]);

      final cartAlpha = await cartDb.loadCartItems('user_alpha');
      final cartBeta = await cartDb.loadCartItems('user_beta');
      final cartGuest = await cartDb.loadCartItems('guest');
      final cartEmptyUid = await cartDb.loadCartItems('');

      expect(cartAlpha.length, 1);
      expect(cartAlpha.first['variantId'], 'var_alpha');

      expect(cartBeta.length, 1);
      expect(cartBeta.first['variantId'], 'var_beta');

      expect(cartGuest.length, 1);
      expect(cartGuest.first['variantId'], 'var_guest');

      expect(cartEmptyUid.length, 1);
      expect(cartEmptyUid.first['variantId'], 'var_guest');
    });

    test('Case d: clearCart chỉ xóa giỏ của user đó', () async {
      await cartDb.saveCartItems('user_01', [
        {
          'productId': 'prod_1',
          'variantId': 'var_1',
          'productName': 'Món 1',
          'priceVnd': 10000,
          'quantity': 1,
        },
      ]);
      await cartDb.saveCartItems('user_02', [
        {
          'productId': 'prod_2',
          'variantId': 'var_2',
          'productName': 'Món 2',
          'priceVnd': 20000,
          'quantity': 2,
        },
      ]);

      await cartDb.clearCart('user_01');

      expect(await cartDb.loadCartItems('user_01'), isEmpty);
      final user02Items = await cartDb.loadCartItems('user_02');
      expect(user02Items.length, 1);
      expect(user02Items.first['variantId'], 'var_2');
    });

    test('Case e: Lưu hai dòng cùng variantId cho cùng user không tạo dòng trùng (gộp số lượng + UNIQUE constraint)', () async {
      // Truyền danh sách chứa 2 mục có cùng variantId
      await cartDb.saveCartItems('user_01', [
        {
          'productId': 'prod_same',
          'variantId': 'var_duplicate',
          'productName': 'Tai nghe AirPods',
          'priceVnd': 5000000,
          'quantity': 2,
        },
        {
          'productId': 'prod_same',
          'variantId': 'var_duplicate',
          'productName': 'Tai nghe AirPods',
          'priceVnd': 5000000,
          'quantity': 3,
        },
      ]);

      final items = await cartDb.loadCartItems('user_01');
      expect(items.length, 1);
      expect(items.first['variantId'], 'var_duplicate');
      // Chọn phương án gộp số lượng: 2 + 3 = 5
      expect(items.first['quantity'], 5);
    });

    test('Case f: Lỗi DB không crash (factory ném lỗi => loadCartItems trả [], save/clear bỏ qua)', () async {
      final brokenDb = CartDatabase(databaseFactory: FaultyDatabaseFactory());

      // loadCartItems phải trả [] mà không crash
      final items = await brokenDb.loadCartItems('user_01');
      expect(items, isEmpty);

      // saveCartItems và clearCart bỏ qua lỗi, không làm ném exception
      await expectLater(
        brokenDb.saveCartItems('user_01', [
          {'variantId': 'var_x', 'quantity': 1},
        ]),
        completes,
      );
      await expectLater(brokenDb.clearCart('user_01'), completes);
    });

    test('Case g: Di trú dữ liệu cũ từ JSON file sang SQLite khi DB trống và xóa file cũ sau khi nhập thành công', () async {
      final fakeStorage = FakeLocalFileStorageService();
      fakeStorage.storage['guest'] = [
        {
          'productId': 'legacy_prod',
          'variantId': 'legacy_var',
          'productName': 'Sản phẩm từ file JSON cũ',
          'variantLabel': 'Standard',
          'priceVnd': 99000,
          'quantity': 1,
          'imageUrl': '',
          'updatedAt': '2026-10-01T00:00:00.000Z',
        },
      ];

      final migratingDb = CartDatabase(
        db: rawDb,
        fileStorage: fakeStorage,
      );

      // Lần đầu load: SQLite trống -> đọc từ file cũ, lưu vào SQLite và trả về
      final loaded = await migratingDb.loadCartItems('guest');
      expect(loaded.length, 1);
      expect(loaded.first['variantId'], 'legacy_var');

      // File JSON cũ đã được xóa sạch sau khi nhập thành công vào SQLite
      expect(fakeStorage.storage['guest'], isNull);

      // Lần thứ hai load: đọc trực tiếp từ SQLite đã di trú
      final fromDb = await migratingDb.loadCartItems('guest');
      expect(fromDb.length, 1);
      expect(fromDb.first['variantId'], 'legacy_var');
    });

    test('Case h: Di trú một lần rồi clearCart(uid), load lại => trả [] (không sống lại)', () async {
      final fakeStorage = FakeLocalFileStorageService();
      fakeStorage.storage['user_del'] = [
        {
          'productId': 'prod_del',
          'variantId': 'var_del',
          'productName': 'Món sắp xóa',
          'priceVnd': 50000,
          'quantity': 2,
        },
      ];

      final migratingDb = CartDatabase(
        db: rawDb,
        fileStorage: fakeStorage,
      );

      // 1. Di trú lần đầu thành công
      final initialLoad = await migratingDb.loadCartItems('user_del');
      expect(initialLoad.length, 1);
      expect(initialLoad.first['variantId'], 'var_del');

      // 2. Xóa sạch giỏ hàng
      await migratingDb.clearCart('user_del');
      expect(await migratingDb.loadCartItems('user_del'), isEmpty);

      // 3. Load lại: giỏ hàng phải là rỗng, KHÔNG bị dữ liệu JSON cũ sống lại
      final reloaded = await migratingDb.loadCartItems('user_del');
      expect(reloaded, isEmpty);
    });

    test('Case i: Sau di trú, file JSON cũ của user đã bị xóa; user khác chưa di trú không bị ảnh hưởng', () async {
      final fakeStorage = FakeLocalFileStorageService();
      fakeStorage.storage['user_done'] = [
        {
          'productId': 'prod_done',
          'variantId': 'var_done',
          'productName': 'Đơn user_done',
          'priceVnd': 70000,
          'quantity': 1,
        },
      ];
      fakeStorage.storage['user_pending'] = [
        {
          'productId': 'prod_pending',
          'variantId': 'var_pending',
          'productName': 'Đơn user_pending',
          'priceVnd': 90000,
          'quantity': 3,
        },
      ];

      final migratingDb = CartDatabase(
        db: rawDb,
        fileStorage: fakeStorage,
      );

      // Di trú cho user_done
      final loadedDone = await migratingDb.loadCartItems('user_done');
      expect(loadedDone.length, 1);

      // File JSON của user_done đã bị xóa
      expect(fakeStorage.storage['user_done'], isNull);

      // User khác chưa di trú vẫn còn nguyên vẹn dữ liệu JSON
      expect(fakeStorage.storage['user_pending'], isNotNull);
      expect(fakeStorage.storage['user_pending']!.length, 1);
      expect(
        fakeStorage.storage['user_pending']!.first['variantId'],
        'var_pending',
      );
    });

    test('Case j: Di trú thất bại (ép save lỗi) => file JSON vẫn còn, không mất dữ liệu', () async {
      final fakeStorage = FakeLocalFileStorageService();
      fakeStorage.storage['user_fail'] = [
        {
          'productId': 'prod_precious',
          'variantId': 'var_precious',
          'productName': 'Dữ liệu quan trọng',
          'priceVnd': 15000000,
          'quantity': 1,
        },
      ];

      final failingDb = FailingSaveCartDatabase(
        db: rawDb,
        fileStorage: fakeStorage,
      );

      final loaded = await failingDb.loadCartItems('user_fail');
      expect(loaded, isEmpty);

      // File JSON vẫn còn nguyên vẹn, không bị xóa vì lưu vào SQLite thất bại
      expect(fakeStorage.storage['user_fail'], isNotNull);
      expect(fakeStorage.storage['user_fail']!.length, 1);
      expect(
        fakeStorage.storage['user_fail']!.first['variantId'],
        'var_precious',
      );
    });
  });
}
