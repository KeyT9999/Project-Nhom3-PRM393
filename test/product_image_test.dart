import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartstore/core/utils/product_images.dart';
import 'package:smartstore/core/widgets/product_image.dart';

const _fakeAssets = [
  'assets/images/products/iphone_16/main.jpg',
  'assets/images/products/oppo_find_x8/main.webp',
  'assets/images/products/oppo_find_x8/gallery_10.webp',
  'assets/images/products/oppo_find_x8/gallery_2.webp',
  'assets/images/products/oppo_find_x8/gallery_1.webp',
  'assets/images/products/oppo_find_x8/color_blue.webp',
  'assets/images/hero_iphone_rock.jpg',
];

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 120, child: child))),
    );

void main() {
  group('ProductImages lookup', () {
    test('main và gallery đúng thứ tự, không phụ thuộc đuôi file', () {
      final images = ProductImages(assets: _fakeAssets);
      expect(images.main('iphone_16'),
          'assets/images/products/iphone_16/main.jpg');
      expect(images.main('oppo_find_x8'),
          'assets/images/products/oppo_find_x8/main.webp');
      expect(images.gallery('oppo_find_x8'), [
        'assets/images/products/oppo_find_x8/gallery_1.webp',
        'assets/images/products/oppo_find_x8/gallery_2.webp',
        'assets/images/products/oppo_find_x8/gallery_10.webp',
      ]);
      expect(images.all('oppo_find_x8').first,
          'assets/images/products/oppo_find_x8/main.webp');
      expect(images.main('oppo_find_x8', color: 'Blue'),
          'assets/images/products/oppo_find_x8/color_blue.webp');
    });

    test('chưa nạp hoặc thiếu sản phẩm thì trả null/rỗng, không throw', () {
      final empty = ProductImages();
      expect(empty.main('iphone_16'), isNull);
      expect(empty.gallery('iphone_16'), isEmpty);
      final images = ProductImages(assets: _fakeAssets);
      expect(images.main('xiaomi_15_pro'), isNull);
      expect(images.gallery('xiaomi_15_pro'), isEmpty);
    });
  });

  group('ProductImage widget', () {
    testWidgets('hiện ảnh khi có asset', (tester) async {
      final images = ProductImages(assets: _fakeAssets);
      await tester.pumpWidget(
        _host(ProductImage(productId: 'iphone_16', images: images)),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(find.byKey(const ValueKey('product-image-placeholder')),
          findsNothing);
    });

    testWidgets('hiện placeholder khi thiếu ảnh (xiaomi_15_pro)',
        (tester) async {
      final images = ProductImages(assets: _fakeAssets);
      await tester.pumpWidget(
        _host(ProductImage(productId: 'xiaomi_15_pro', images: images)),
      );
      expect(find.byKey(const ValueKey('product-image-placeholder')),
          findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
