import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartstore/data/models/cart_item_model.dart';
import 'package:smartstore/data/repositories/cart_repository.dart';
import 'package:smartstore/features/products/product_detail_screen.dart';
import 'package:smartstore/providers/auth_provider.dart';
import 'package:smartstore/providers/cart_provider.dart';
import 'package:smartstore/providers/product_provider.dart';
import 'package:smartstore/providers/wishlist_provider.dart';

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

void main() {
  group('ProductDetailScreen - Widget test nút thêm vào giỏ hàng', () {
    late FakeCartRepository fakeCartRepo;
    late CartProvider cartProvider;
    late ProductProvider productProvider;
    late WishlistProvider wishlistProvider;
    late AuthProvider authProvider;

    setUp(() {
      fakeCartRepo = FakeCartRepository();
      cartProvider = CartProvider(cartRepository: fakeCartRepo);
      productProvider = ProductProvider();
      wishlistProvider = WishlistProvider();
      authProvider = AuthProvider();
    });

    Widget createTestWidget({required String productId}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
          ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ChangeNotifierProvider<WishlistProvider>.value(
            value: wishlistProvider,
          ),
        ],
        child: MaterialApp(
          home: ProductDetailScreen(productId: productId),
        ),
      );
    }

    testWidgets(
      'Case a & b: Hiển thị nút thêm vào giỏ hàng và thêm đúng 1 dòng vào CartProvider khi bấm nút',
      (WidgetTester tester) async {
        // Cài đặt kích thước màn hình để tránh overflow trong môi trường test
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Mở màn hình chi tiết sản phẩm mẫu còn hàng
        await tester.pumpWidget(
          createTestWidget(productId: 'iphone_16_pro_max'),
        );
        // Dùng pump có khoảng thời gian giới hạn để _loadData bất đồng bộ hoàn tất (tránh pumpAndSettle vô tận do LiquidAmbientCanvas)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Case a: Tìm thấy nút thêm vào giỏ hàng (kiểm tra cả byTooltip và byIcon)
        final addToCartTooltip = find.byTooltip('Thêm vào giỏ hàng');
        final addToCartIcon = find.byIcon(Icons.add_shopping_cart_rounded);

        expect(addToCartTooltip, findsOneWidget);
        expect(addToCartIcon, findsOneWidget);
        expect(cartProvider.totalQuantity, 0);
        expect(cartProvider.items, isEmpty);

        // Case b: Bấm nút thêm vào giỏ hàng
        await tester.tap(addToCartTooltip);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Kiểm tra CartProvider có thêm đúng 1 dòng và totalQuantity == 1
        expect(cartProvider.items.length, 1);
        expect(cartProvider.totalQuantity, 1);
        expect(cartProvider.items.first.productId, 'iphone_16_pro_max');
        expect(cartProvider.items.first.quantity, 1);
      },
    );
  });
}
