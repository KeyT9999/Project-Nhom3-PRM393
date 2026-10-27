import 'package:flutter_test/flutter_test.dart';
import 'package:smartstore/core/errors/app_exception.dart';
import 'package:smartstore/data/models/cart_item_model.dart';
import 'package:smartstore/data/models/product_model.dart';
import 'package:smartstore/data/models/variant_model.dart';
import 'package:smartstore/data/repositories/cart_repository.dart';
import 'package:smartstore/providers/cart_provider.dart';

class FakeCartRepository extends CartRepository {
  List<CartItemModel> storedItems = [];

  @override
  Future<List<CartItemModel>> loadCart(String? userId) async {
    return List<CartItemModel>.from(storedItems);
  }

  @override
  Future<void> saveCart(String? userId, List<CartItemModel> items) async {
    storedItems = List<CartItemModel>.from(items);
  }

  @override
  Future<void> clearCart(String? userId) async {
    storedItems.clear();
  }
}

ProductModel _createTestProduct({
  String id = 'prod_1',
  String name = 'iPhone 16 Pro Max',
  int priceFromVnd = 31990000,
}) {
  return ProductModel(
    id: id,
    name: name,
    slug: 'slug-$id',
    brandId: 'apple',
    categoryId: 'smartphones',
    description: 'Mô tả kiểm thử sản phẩm',
    priceFromVnd: priceFromVnd,
    specs: const {'ram': '8GB'},
  );
}

VariantModel _createTestVariant({
  String id = 'var_1',
  String sku = 'SKU-01',
  int priceVnd = 31990000,
  int stock = 10,
}) {
  return VariantModel(
    id: id,
    sku: sku,
    color: 'Titan Sa Mạc',
    ramGB: 8,
    storageGB: 256,
    priceVnd: priceVnd,
    stock: stock,
  );
}

void main() {
  group('CartProvider - Unit test tính tiền và số lượng giỏ hàng (Mục 4.2)', () {
    late FakeCartRepository fakeRepo;
    late CartProvider cartProvider;

    setUp(() {
      fakeRepo = FakeCartRepository();
      cartProvider = CartProvider(cartRepository: fakeRepo);
    });

    test('Case a: Giỏ rỗng thì subtotalVnd == 0 và totalQuantity == 0', () {
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.subtotalVnd, 0);
      expect(cartProvider.totalQuantity, 0);
    });

    test('Case b: Thêm 1 biến thể số lượng 2 thì subtotalVnd == giá × 2', () async {
      final product = _createTestProduct();
      final variant = _createTestVariant(
        id: 'var_test_1',
        priceVnd: 15000000,
        stock: 10,
      );

      await cartProvider.addVariantToCart(
        product: product,
        variant: variant,
        quantity: 2,
      );

      expect(cartProvider.items.length, 1);
      expect(cartProvider.totalQuantity, 2);
      expect(cartProvider.subtotalVnd, 15000000 * 2);
      expect(cartProvider.items.first.lineTotalVnd, 30000000);
    });

    test('Case c: Thêm 2 biến thể khác nhau thì subtotalVnd bằng tổng hai dòng', () async {
      final product = _createTestProduct();
      final variant1 = _createTestVariant(
        id: 'var_1',
        priceVnd: 12000000,
        stock: 5,
      );
      final variant2 = _createTestVariant(
        id: 'var_2',
        priceVnd: 20000000,
        stock: 5,
      );

      await cartProvider.addVariantToCart(
        product: product,
        variant: variant1,
        quantity: 2,
      );
      await cartProvider.addVariantToCart(
        product: product,
        variant: variant2,
        quantity: 1,
      );

      expect(cartProvider.items.length, 2);
      expect(cartProvider.totalQuantity, 3);
      final expectedSubtotal = (12000000 * 2) + (20000000 * 1);
      expect(cartProvider.subtotalVnd, expectedSubtotal);
    });

    test('Case d: Thêm cùng biến thể hai lần thì số lượng cộng dồn, không tạo dòng trùng', () async {
      final product = _createTestProduct();
      final variant = _createTestVariant(
        id: 'var_same',
        priceVnd: 10000000,
        stock: 10,
      );

      await cartProvider.addVariantToCart(
        product: product,
        variant: variant,
        quantity: 2,
      );
      await cartProvider.addVariantToCart(
        product: product,
        variant: variant,
        quantity: 3,
      );

      expect(cartProvider.items.length, 1);
      expect(cartProvider.totalQuantity, 5);
      expect(cartProvider.items.first.quantity, 5);
      expect(cartProvider.subtotalVnd, 10000000 * 5);
    });

    test('Case e: Thêm vượt tồn kho thì ném AppException và giỏ không đổi', () async {
      final product = _createTestProduct();
      final variant = _createTestVariant(
        id: 'var_limited',
        priceVnd: 8000000,
        stock: 4,
      );

      // Thêm hợp lệ ban đầu 2 sản phẩm
      await cartProvider.addVariantToCart(
        product: product,
        variant: variant,
        quantity: 2,
      );
      expect(cartProvider.totalQuantity, 2);
      expect(cartProvider.subtotalVnd, 16000000);

      // Thêm tiếp 3 sản phẩm (tổng 2 + 3 = 5 > tồn kho 4) -> phải ném AppException
      expect(
        () => cartProvider.addVariantToCart(
          product: product,
          variant: variant,
          quantity: 3,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('vượt quá tồn kho'),
          ),
        ),
      );

      // Kiểm tra giỏ hàng giữ nguyên trạng thái cũ, không bị thay đổi
      expect(cartProvider.items.length, 1);
      expect(cartProvider.totalQuantity, 2);
      expect(cartProvider.subtotalVnd, 16000000);
    });
  });
}
