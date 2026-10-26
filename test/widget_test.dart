import 'package:flutter_test/flutter_test.dart';
import 'package:smartstore/app/app.dart';
import 'package:smartstore/app/theme/app_colors.dart';
import 'package:smartstore/data/models/address_model.dart';
import 'package:smartstore/providers/auth_provider.dart';
import 'package:smartstore/providers/cart_provider.dart';
import 'package:smartstore/providers/chat_provider.dart';
import 'package:smartstore/providers/order_provider.dart';
import 'package:smartstore/providers/product_provider.dart';
import 'package:smartstore/providers/wishlist_provider.dart';

void main() {
  testWidgets(
    'TC01: SmartStore hiển thị Trang chủ Frosted-Glass & 5 tab điều hướng chính',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SmartStoreApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khám phá ngay'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Catalog'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    },
  );

  test('TC02, TC03: Tìm kiếm (F06), Lọc theo Hãng/RAM/ROM/Giá (F05, F07), Sắp xếp (F08) & Đánh giá (F22)', () async {
    final productProvider = ProductProvider();
    await productProvider.loadProducts();

    // Lọc theo hãng Apple (F05)
    productProvider.applyFilters(brand: 'Apple');
    expect(
      productProvider.products.every((p) => p.brandId.toLowerCase() == 'apple'),
      isTrue,
    );

    // Tìm kiếm từ khóa 'Ultra' (F06)
    productProvider.applyFilters(clearAll: true);
    productProvider.setSearchQuery('Ultra');
    expect(
      productProvider.products.every(
        (p) => p.name.toLowerCase().contains('ultra'),
      ),
      isTrue,
    );

    // Sắp xếp giá tăng dần (F08)
    productProvider.setSearchQuery('');
    productProvider.setSortOption(ProductSortOption.priceAsc);
    final prices = productProvider.products.map((p) => p.priceFromVnd).toList();
    for (var i = 0; i < prices.length - 1; i++) {
      expect(prices[i] <= prices[i + 1], isTrue);
    }

    // Gửi đánh giá sản phẩm (F22)
    final targetId = productProvider.allProducts.first.id;
    final beforeReviews = productProvider.getReviewsForProduct(targetId).length;
    await productProvider.submitReview(
      productId: targetId,
      userId: 'user_01',
      userName: 'Lê Minh Tuấn',
      rating: 5,
      comment: 'Máy chính hãng VN/A nguyên seal, giao hàng cực nhanh!',
    );
    final afterReviews = productProvider.getReviewsForProduct(targetId).length;
    expect(afterReviews, beforeReviews + 1);
  });

  test('TC04, TC05, TC09, TC11, TC12: Chọn biến thể, tính tiền VND nguyên, áp mã giảm giá, đặt đơn COD và hủy đơn hoàn kho', () async {
    final productProvider = ProductProvider();
    await productProvider.loadProducts();
    expect(productProvider.allProducts.isNotEmpty, isTrue);

    final firstProduct = productProvider.allProducts.first;
    await productProvider.loadVariantsForProduct(firstProduct.id);
    expect(productProvider.currentVariants.isNotEmpty, isTrue);

    final variant = productProvider.selectedVariant!;
    final initialStock = variant.stock;
    expect(initialStock, greaterThan(0));

    // Thêm vào giỏ hàng & kiểm tra tính tiền số nguyên VND (S04)
    final cartProvider = CartProvider();
    await cartProvider.addVariantToCart(
      product: firstProduct,
      variant: variant,
      quantity: 1,
    );
    expect(cartProvider.totalQuantity, 1);
    expect(cartProvider.subtotalVnd, variant.priceVnd);
    await expectLater(
      cartProvider.addVariantToCart(
        product: firstProduct,
        variant: variant,
        quantity: variant.stock,
      ),
      throwsException,
    );

    // Kiểm tra mã giảm giá SMART500
    final coupon = productProvider.validateCoupon(
      'SMART500',
      cartProvider.subtotalVnd,
    );
    expect(coupon, isNotNull);
    expect(coupon!.discountVnd, 500000);

    // Đặt đơn hàng COD (F13, S02, S03, S04)
    final orderProvider = OrderProvider();
    final order = await orderProvider.placeOrder(
      userId: 'user_test_01',
      items: cartProvider.items,
      shippingAddress: const AddressModel(
        id: 'addr_1',
        fullName: 'Nguyễn Văn A',
        phone: '0901234567',
        addressLine: 'Lô E2a-7, Đường D1, TP. Thủ Đức, TP.HCM',
        isDefault: true,
      ),
      couponCode: 'SMART500',
    );
    expect(order.status, 'pending');
    expect(order.discountVnd, 500000);
    expect(orderProvider.ordersByStatus('all', userId: 'other_user'), isEmpty);
    expect(
      orderProvider.ordersByStatus('all', userId: 'user_test_01'),
      hasLength(1),
    );

    // Kiểm tra tồn kho đã giảm đi 1 sau khi đặt đơn (S02)
    await productProvider.loadVariantsForProduct(firstProduct.id);
    final updatedVariantAfterOrder = productProvider.currentVariants.firstWhere(
      (v) => v.id == variant.id,
    );
    expect(updatedVariantAfterOrder.stock, initialStock - 1);

    // Hủy đơn hàng khi đang pending và kiểm tra hoàn kho tự động 1 lần (F16, A06)
    final cancelled = await orderProvider.cancelOrder(order.id);
    expect(cancelled?.status, 'cancelled');
    expect(cancelled?.restocked, isTrue);
    await expectLater(
      orderProvider.adminUpdateOrderStatus(
        orderId: order.id,
        newStatus: 'shipping',
        note: 'Không hợp lệ',
      ),
      throwsException,
    );

    await productProvider.loadVariantsForProduct(firstProduct.id);
    final restoredVariant = productProvider.currentVariants.firstWhere(
      (v) => v.id == variant.id,
    );
    expect(restoredVariant.stock, initialStock);
  });

  test('TC08, TC10: Wishlist (F12), Chuyển đổi Theme UI DESIGN (Blue/Mono/Orange), Offline Mode (F23) & Chat CSKH (F20, A09)', () async {
    final wishlist = WishlistProvider();
    await wishlist.toggleFavorite('iphone_16_pro_max');
    expect(wishlist.isFavorite('iphone_16_pro_max'), isTrue);

    final auth = AuthProvider();
    auth.setThemeType(LmThemeType.orange);
    expect(auth.palette.type, LmThemeType.orange);
    auth.toggleOfflineSimulation(true);
    expect(auth.isOfflineSimulated, isTrue);

    final chat = ChatProvider();
    final initialCount = chat.messages.length;
    await chat.sendMessage(
      'Cho mình hỏi iPhone 16 Pro Max còn màu Titan Tự Nhiên không?',
      senderName: 'Khách hàng',
      isAdmin: false,
    );
    await chat.sendMessage(
      'Dạ SmartStore hiện đang sẵn hàng tại cả 3 chi nhánh ạ!',
      senderName: 'Admin SmartStore',
      isAdmin: true,
    );
    expect(chat.messages.length, initialCount + 2);
  });
}
