import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartstore/features/maps/store_map_screen.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('StoreMapScreen renders correctly and allows branch selection', (tester) async {
    // Set screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: StoreMapScreen(),
      ),
    );
    await tester.pump();

    // Verify Title
    expect(find.text('Bản đồ cửa hàng SmartStore'), findsOneWidget);

    // Verify Badges
    expect(find.text('Bản đồ đường phố thực tế (Live OSM)'), findsOneWidget);
    expect(find.text('Đang mở cửa'), findsOneWidget);
    expect(find.textContaining('GPS: 10.8412'), findsOneWidget);

    // Initial marker at Thủ Đức is in the camera viewport
    expect(find.text('SmartStore Thủ Đức'), findsOneWidget);

    // Tap branch 2 in the branch list card
    await tester.tap(find.text('SmartStore Center – Quận 1 (Bitexco)'));
    await tester.pump();

    // Now map has moved to Bitexco: marker Bitexco is visible, GPS updated
    expect(find.textContaining('GPS: 10.7716'), findsOneWidget);
    expect(find.text('SmartStore Bitexco Q1'), findsOneWidget);

    // Verify Google Maps & Hotline action buttons
    expect(find.text('Mở chỉ đường ngoài ứng dụng Google Maps'), findsOneWidget);
    expect(find.textContaining('Gọi Hotline chi nhánh (0909888999)'), findsOneWidget);
  });
}
