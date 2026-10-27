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
- [x] ✅ B1. Giỏ hàng đã chuyển sang **SQLite (sqflite)**, bảng `Cart` khớp báo cáo mục 3.3 (thêm `variant_id`, `variant_label`, `updated_at`), có di trú một lần từ JSON cũ. Vẫn đồng bộ Firestore khi đăng nhập. 20/20 test pass (TASK-4, TASK-5 ĐẠT). Báo cáo nên ghi thêm 3 cột mở rộng này.
- [ ] ⚠️ B2. Báo cáo ghi "chưa tích hợp thanh toán online, dữ liệu mock" nhưng code đã có PayOS (`payos_service.dart`, `payos_payment_screen.dart`) và nhiều dữ liệu sản phẩm. → cập nhật mục 6 của báo cáo.
- [ ] ⚠️ B3. Báo cáo ghi chat "Firebase Realtime"; code dùng Cloud Firestore. → sửa chữ trong báo cáo.

## C. Testing (mục 4.2)
- [x] ✅ C1. Unit test tổng tiền giỏ hàng – `test/cart_provider_test.dart`, 5/5 pass (Claude đã chạy lại, TASK-1 ĐẠT)
- [x] ✅ C2. Widget test nút thêm vào giỏ trên Product Detail (nút hiện là IconButton, tooltip "Thêm vào giỏ hàng") – `test/product_detail_add_to_cart_test.dart` pass (TASK-2 ĐẠT)
- [x] ✅ C3. `flutter test` toàn bộ: 10/10 pass, `flutter analyze` sạch. TC01 từng fail do 2 lỗi trong test: pumpAndSettle bị animation lặp vô hạn, và nhãn tab cũ (Home/Catalog...) không còn khớp UI mới (TASK-3, Claude đã sửa).

## D. Triển khai (mục 4.3)
- [ ] ❌ D1. `flutter build apk --release` thành công + chụp màn hình + giữ file APK (cần cấu hình `.env`/keystore, **người làm**)

## E. Tài liệu
- [ ] ❌ E1. Cập nhật báo cáo theo B1–B3 (sau khi chốt B1)
