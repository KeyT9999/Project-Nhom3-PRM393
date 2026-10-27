# SmartStore – Checklist đối chiếu báo cáo (Sample_Project.docx) với code

Ký hiệu: ✅ có code (chưa chạy thử trên máy) · ⚠️ lệch so với báo cáo · ❌ thiếu · ⏳ đang giao cho Anti
Kiểm tra gần nhất (Claude): `flutter analyze` → No issues found. Chưa chạy `flutter test`, chưa chạy app.

## A. Chức năng (mục 5 báo cáo)
- [x] ✅ Login / Register / Quên mật khẩu (Firebase Auth) – `lib/features/auth/`, `auth_repository.dart`
- [x] ✅ Product List – `lib/features/products/catalog_screen.dart`, `home_screen.dart` (cần xác nhận dùng GridView)
- [x] ✅ Product Detail – `product_detail_screen.dart`
- [x] ✅ Shopping Cart (tăng/giảm số lượng) – `cart_screen.dart`, `cart_provider.dart`
- [x] ✅ Checkout + xác nhận đơn – `checkout_screen.dart`, `order_success_screen.dart`
- [x] ✅ Notifications – `notifications_screen.dart`, `local_notification_service.dart`
- [x] ✅ Map Screen – `store_map_screen.dart` (google_maps_flutter)
- [x] ✅ Messaging – `chat_screen.dart`, `chat_repository.dart` (Firestore)
- [x] ✅ State management Provider – `lib/providers/`

## B. Lệch giữa báo cáo và code (cần chốt)
- [ ] ⚠️ B1. Báo cáo ghi giỏ hàng lưu **SQLite (sqflite), bảng Cart**; code thật lưu **file JSON cục bộ + đồng bộ Firestore** (`cart_repository.dart`, `local_file_storage_service.dart`), khóa theo `variantId`, không có `sqflite` trong `pubspec.yaml`. → **Cần người quyết định**: (a) sửa báo cáo cho khớp code, hoặc (b) thêm tầng sqflite.
- [ ] ⚠️ B2. Báo cáo ghi "chưa tích hợp thanh toán online, dữ liệu mock" nhưng code đã có PayOS (`payos_service.dart`, `payos_payment_screen.dart`) và nhiều dữ liệu sản phẩm. → cập nhật mục 6 của báo cáo.
- [ ] ⚠️ B3. Báo cáo ghi chat "Firebase Realtime"; code dùng Cloud Firestore. → sửa chữ trong báo cáo.

## C. Testing (mục 4.2)
- [x] ✅ C1. Unit test tổng tiền giỏ hàng – `test/cart_provider_test.dart`, 5/5 pass (Claude đã chạy lại, TASK-1 ĐẠT)
- [x] ✅ C2. Widget test nút thêm vào giỏ trên Product Detail (nút hiện là IconButton, tooltip "Thêm vào giỏ hàng") – `test/product_detail_add_to_cart_test.dart` pass (TASK-2 ĐẠT)
- [ ] ⚠️ C3. `flutter test` toàn bộ: 8 pass, 1 fail. `widget_test.dart` TC01 ("Trang chủ Frosted-Glass & 5 tab") fail từ trước khi Anti làm việc (file này không bị đổi). Cần chẩn đoán (TASK-3).

## D. Triển khai (mục 4.3)
- [ ] ❌ D1. `flutter build apk --release` thành công + chụp màn hình + giữ file APK (cần cấu hình `.env`/keystore, **người làm**)

## E. Tài liệu
- [ ] ❌ E1. Cập nhật báo cáo theo B1–B3 (sau khi chốt B1)
