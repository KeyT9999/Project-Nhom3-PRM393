# SmartStore – Checklist đối chiếu báo cáo (Sample_Project.docx) với code

Ký hiệu: ✅ có code (chưa chạy thử trên máy) · ⚠️ lệch so với báo cáo · ❌ thiếu · ⏳ đang giao cho Anti
Kiểm tra lại 27/10/2026 (Claude): `flutter analyze` → No issues found; `flutter test` → +24 All tests passed. Đã chạy thử app trên emulator và web (Chrome), chưa chạy trên máy thật.

## A. Chức năng (mục 5 báo cáo)
- [x] ✅ Login / Register / Quên mật khẩu (Firebase Auth) – `lib/features/auth/`, `auth_repository.dart`
- [x] ✅ Product List – `lib/features/products/catalog_screen.dart`, `home_screen.dart` (đã xác nhận: dùng SliverGrid ở trang chủ)
- [x] ✅ Product Detail – `product_detail_screen.dart`
- [x] ✅ Shopping Cart (tăng/giảm số lượng) – `features/cart/cart_screen.dart`, `cart_provider.dart`
- [x] ✅ Checkout + xác nhận đơn – `features/checkout/checkout_screen.dart`, `order_success_screen.dart`
- [x] ✅ Notifications – `notifications_screen.dart`, `local_notification_service.dart`
- [x] ✅ Map Screen – `store_map_screen.dart` (google_maps_flutter)
- [x] ✅ Messaging – `chat_screen.dart`, `chat_repository.dart` (Firestore)
- [x] ✅ State management Provider – `lib/providers/`

## B. Lệch giữa báo cáo và code (cần chốt)
- [x] ✅ B1. Giỏ hàng đã chuyển sang **SQLite (sqflite)**, bảng `Cart` khớp báo cáo mục 3.3 (thêm `variant_id`, `variant_label`, `updated_at`), có di trú một lần từ JSON cũ. Vẫn đồng bộ Firestore khi đăng nhập. 20/20 test pass (TASK-4, TASK-5 ĐẠT). Báo cáo nên ghi thêm 3 cột mở rộng này.
- [x] ✅ B2. Mục 6 của báo cáo đã sửa: ghi hỗ trợ COD + PayOS (chưa có VNPay/MoMo), dữ liệu sản phẩm là dữ liệu demo nạp lên Firestore. Xem `Sample_Project_updated.docx`.
- [x] ✅ B3. Mục 5 (Messaging) đã sửa thành chat qua Cloud Firestore. Xem `Sample_Project_updated.docx`.

## C. Testing (mục 4.2)
- [x] ✅ C1. Unit test tổng tiền giỏ hàng – `test/cart_provider_test.dart`, 5/5 pass (Claude đã chạy lại, TASK-1 ĐẠT)
- [x] ✅ C2. Widget test nút thêm vào giỏ trên Product Detail (nút hiện là IconButton, tooltip "Thêm vào giỏ hàng") – `test/product_detail_add_to_cart_test.dart` pass (TASK-2 ĐẠT)
- [x] ✅ C3. `flutter test` toàn bộ: 24/24 pass (thêm 4 test ảnh sản phẩm), `flutter analyze` sạch. TC01 từng fail do 2 lỗi trong test: pumpAndSettle bị animation lặp vô hạn, và nhãn tab cũ (Home/Catalog...) không còn khớp UI mới (TASK-3, Claude đã sửa).

## D. Triển khai (mục 4.3)
- [ ] ❌ D1. `flutter build apk --release` thành công + chụp màn hình + giữ file APK (cần cấu hình `.env`/keystore, **người làm**)

## E. Tài liệu
- [x] ✅ E1. Báo cáo đã cập nhật theo B1–B3 thành `F:\PRM_PROJECT_GROUP3\Sample_Project_updated.docx` (file gốc giữ nguyên, cần mở bằng Word kiểm tra định dạng).

## F. Phát hiện khi kiểm tra lại (27/10/2026)
- [x] ✅ F1. Báo cáo (mục 2) từng ghi SQLite lưu cả yêu thích; thực tế chỉ giỏ hàng dùng SQLite, yêu thích lưu file JSON + Firestore. Đã chọn sửa chữ báo cáo, không đổi code. Xem `Sample_Project_updated_v2.docx`.
- [ ] ⚠️ F2. Cấu hình `release` trong `android/app/build.gradle` đang ký bằng khóa debug; cần keystore thật nếu nộp APK release (liên quan D1). Hiện chỉ có `app-debug.apk`.
- [x] ✅ F3. Mục 4.2 trong `Sample_Project_updated_v2.docx` đã thêm Database Test (10 test), Image Test (4 test) và kết quả 24 test đạt.
- [ ] ⚠️ F4. Giao diện đã đổi lớn (ảnh sản phẩm thật, phong cách phẳng): ảnh chụp màn hình trong báo cáo (mục 5) nên chụp lại.
- [x] ✅ F5. Đã sửa: tên máy gọn ở checkout/đơn hàng, bỏ nhãn "FIREBASE AUTH" và câu "Kỷ lục pin tốt nhất", `payos_test_10k` không còn là sản phẩm nổi bật (vẫn mua được để thử PayOS). Còn lại: `xiaomi_15_pro` chưa có ảnh (hiện khung xám); không tìm thấy màn đăng nhập kiểu tiếng Anh trong `lib/` nên có thể là bản build cũ.
