# 🤖 03. Cấu Hình Chuyên Biệt Cho Nền Tảng Android & Thư Viện (Android Setup & Packages)

> **Dự án:** SmartStore – Hệ thống bán điện thoại di động  
> **Môn học:** PRM393 – Mobile Programming (Chuyên biệt nền tảng Android với Flutter & Dart)

---

## 1. Danh sách toàn bộ Packages sử dụng trong SmartStore

Bộ thư viện được chọn lọc để đáp ứng đầy đủ các tính năng thực tế của một ứng dụng E-commerce trên Android: **Local JSON File Storage**, **Firebase Backend**, **Local & Push Notifications (kèm Desugaring)**, **UI/UX hiện đại**, **Bản đồ**, **Quét QR** và **Sinh trắc học**.

### 1.1. Bảng phân loại Packages theo chức năng

| Nhóm chức năng | Package (`pub.dev`) | Vai trò cụ thể trong SmartStore |
| :--- | :--- | :--- |
| **1. Firebase Core & Backend** | `firebase_core` | Khởi tạo kết nối Firebase SDK trên Android |
| | `firebase_auth` | Đăng ký, đăng nhập Email/Password, khôi phục mật khẩu |
| | `google_sign_in` | Đăng nhập nhanh bằng tài khoản Google trên Android |
| | `cloud_firestore` | Cơ sở dữ liệu NoSQL lưu sản phẩm, biến thể, đơn hàng, chat |
| | `firebase_storage` | Lưu trữ hình ảnh điện thoại, banner, ảnh đại diện |
| | `cloud_functions` | Gọi hàm xử lý đặt hàng, kiểm tra giá và tồn kho trên server |
| **2. State & Navigation** | `provider` | Quản lý trạng thái ứng dụng (`ChangeNotifier`, `MultiProvider`) |
| | `go_router` | Điều hướng màn hình khai báo (Declarative Routing) & Route Guard cho Admin |
| **3. Local File Storage** | `path_provider` | Lấy đường dẫn thư mục hệ thống Android (`getApplicationDocumentsDirectory`) để lưu `cart.json` và `favorites.json` |
| | `shared_preferences` | Lưu trữ cấu hình nhẹ (Dark Mode, trạng thái đã xem Onboarding, lịch sử từ khóa) |
| **4. Notifications** | `flutter_local_notifications` | Hiển thị thông báo cục bộ trên thanh trạng thái Android (Đặt đơn thành công, nhắc giỏ hàng, hiển thị FCM khi mở app) |
| | `firebase_messaging` | Nhận thông báo đẩy (Push Notification) từ Firebase Cloud Messaging |
| **5. Network & Device** | `connectivity_plus` | Lắng nghe trạng thái kết nối mạng (Wi-Fi / Mobile Data / Offline) để kích hoạt Offline Mode |
| | `permission_handler` | Xin quyền truy cập Thông báo, Vị trí, Camera trên Android |
| **6. Images & Media** | `cached_network_image` | Tải và lưu cache ảnh điện thoại giúp cuộn danh sách mượt mà |
| | `image_picker` | Chọn ảnh từ thư viện hoặc chụp ảnh từ Camera Android (cập nhật Avatar, Admin đăng ảnh sản phẩm) |
| **7. UI & Animations** | `google_fonts` | Đồng bộ bộ font chữ hiện đại (Inter / Plus Jakarta Sans) |
| | `flutter_svg` | Hiển thị icon và logo định dạng vector `.svg` |
| | `shimmer` | Hiệu ứng khung xương (Skeleton Loading) khi đang tải danh sách điện thoại |
| | `flutter_animate` | Tạo hiệu ứng chuyển động mượt cho thẻ sản phẩm và tiến trình giao hàng |
| | `carousel_slider` | Trình chiếu Banner trang chủ và bộ ảnh nhiều góc của điện thoại |
| | `flutter_rating_bar` | Hiển thị và chọn số sao đánh giá sản phẩm (1–5 sao) |
| **8. Utilities** | `intl` | Định dạng tiền tệ Việt Nam Đồng (`18.990.000 ₫`) và ngày giờ (`dd/MM/yyyy HH:mm`) |
| | `uuid` | Sinh mã định danh duy nhất (`requestId`, ID tạm ở chế độ cục bộ) |
| | `url_launcher` | Mở trình gọi điện thoại (`tel:`), gửi email (`mailto:`) hoặc mở Google Maps ngoài |
| | `share_plus` | Chia sẻ thông tin sản phẩm qua các ứng dụng khác trên Android |
| **9. Tính năng nâng cao** | `google_maps_flutter` | Hiển thị bản đồ vị trí cửa hàng SmartStore |
| | `mobile_scanner` | Quét mã QR đơn hàng bằng Camera Android (dành cho Admin) |
| | `qr_flutter` | Tạo mã QR cho từng đơn hàng trong màn hình Order Detail |
| | `local_auth` | Xác thực vân tay / khuôn mặt trên Android trước khi xác nhận thao tác nhạy cảm |
| **10. Bảo mật & Giám sát** | `firebase_app_check` | Bảo vệ tài nguyên Firebase khỏi truy cập trái phép |
| | `firebase_crashlytics` | Ghi nhận báo cáo lỗi (Crash Report) trên thiết bị Android |

---

### 1.2. Các câu lệnh cài đặt thư viện (`flutter pub add`)

Chạy lần lượt các nhóm lệnh sau trong Terminal tại thư mục gốc của project Flutter:

```bash
# 1. Nhóm Firebase
flutter pub add firebase_core firebase_auth google_sign_in cloud_firestore firebase_storage cloud_functions firebase_messaging

# 2. Nhóm Kiến trúc (State Management & Routing)
flutter pub add provider go_router

# 3. Nhóm Local File Storage & Preferences (Thay thế SQLite)
flutter pub add path_provider shared_preferences

# 4. Nhóm Thông báo & Kết nối mạng
flutter pub add flutter_local_notifications connectivity_plus permission_handler

# 5. Nhóm Hình ảnh & Giao diện (UI/UX)
flutter pub add cached_network_image image_picker google_fonts flutter_svg shimmer flutter_animate carousel_slider flutter_rating_bar

# 6. Nhóm Tiện ích (Format tiền VND, UUID, Launcher, Share)
flutter pub add intl uuid url_launcher share_plus

# 7. Nhóm Tính năng nâng cao (Maps, QR Code, Sinh trắc học)
flutter pub add google_maps_flutter mobile_scanner qr_flutter local_auth

# 8. Nhóm Kiểm thử & Lints
flutter pub add --dev flutter_lints
flutter pub add --dev integration_test --sdk=flutter
```

---

## 2. Cấu hình chuyên biệt cho Android (`Gradle` & `Core Library Desugaring`)

Khi sử dụng `flutter_local_notifications` kết hợp với Firebase SDK trên Android, dự án **bắt buộc phải bật `coreLibraryDesugaring`** để hỗ trợ các API Java 8+ trên mọi phiên bản Android.

### 2.1. Cấu hình `android/app/build.gradle.kts` (Chuẩn Kotlin DSL – Flutter mới)

Mở file `android/app/build.gradle.kts` và cập nhật các khối `android`, `compileOptions`, `kotlinOptions`, `defaultConfig` và `dependencies` như sau:

```kotlin
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.prm393.smartstore"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Bật Core Library Desugaring (Bắt buộc cho flutter_local_notifications)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.prm393.smartstore"
        // Firebase & các plugin hiện đại yêu cầu minSdk tối thiểu là 23
        minSdk = 23
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Thư viện Desugaring JDK (dùng bản 2.1.4 cho flutter_local_notifications mới hoặc 2.0.4 cho bản ^17.0.0)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### 2.2. Cấu hình tương đương nếu project dùng `android/app/build.gradle` (Cú pháp Groovy)

Nếu dự án được khởi tạo với file `.gradle` (Groovy) truyền thống:

```groovy
android {
    namespace "com.prm393.smartstore"
    compileSdk 36

    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    defaultConfig {
        applicationId "com.prm393.smartstore"
        minSdkVersion 23
        targetSdkVersion 36
        multiDexEnabled true
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

> **Lưu ý về phiên bản `desugar_jdk_libs`:**
> - Nếu nhóm chốt dùng `flutter_local_notifications: ^17.0.0` (hoặc `^18.0.0`), có thể dùng `com.android.tools:desugar_jdk_libs:2.0.4` hoặc `2.1.4`.
> - Nếu dùng `flutter_local_notifications` các bản mới hơn (`>= 19.x`), bắt buộc dùng `com.android.tools:desugar_jdk_libs:2.1.4` trở lên. Vì `2.1.4` tương thích ngược hoàn toàn với `2.0.4`, nhóm nên khai báo `2.1.4` để tránh lỗi build.

---

## 3. Cấu hình quyền Android trong `AndroidManifest.xml`

Mở file `android/app/src/main/AndroidManifest.xml` và khai báo đầy đủ các quyền phục vụ Internet, Thông báo (Android 13+), Bản đồ, Camera (Quét QR / Chụp ảnh) và Sinh trắc học:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- 1. Quyền kết nối mạng -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <!-- 2. Quyền hiển thị thông báo trên Android 13+ (API 33+) & Rung -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <!-- 3. Quyền vị trí cho Google Maps (Xem vị trí cửa hàng & chỉ đường) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <!-- 4. Quyền Camera (Quét mã QR đơn hàng & Chụp ảnh đại diện/sản phẩm) -->
    <uses-permission android:name="android.permission.CAMERA"/>

    <!-- 5. Quyền xác thực sinh trắc học (Vân tay / Khuôn mặt) -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>

    <application
        android:label="SmartStore"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <!-- Cấu hình Channel mặc định cho Firebase Cloud Messaging trên Android -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="smartstore_orders_channel" />

        <!-- Cấu hình API Key cho Google Maps SDK for Android -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ANDROID_GOOGLE_MAPS_API_KEY_HERE"/>

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

> **Lưu ý khi dùng `local_auth` trên Android:** Trong file `MainActivity.kt`, hãy đổi lớp kế thừa từ `FlutterActivity()` sang `FlutterFragmentActivity()` để hộp thoại xác thực vân tay của Android hoạt động ổn định.

---

## 4. Code mẫu chuẩn cho 2 dịch vụ cốt lõi trên Android

### 4.1. Dịch vụ lưu trữ JSON cục bộ (`lib/data/local/local_file_storage_service.dart`)

Đoạn code dưới đây cài đặt hoàn chỉnh việc lưu trữ `cart_<uid>.json` và `favorites_<uid>.json` bằng `path_provider` và `dart:io`, có cơ chế bắt lỗi file hỏng và tách biệt dữ liệu theo từng `userId`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalFileStorageService {
  static const int _schemaVersion = 1;

  /// Mã hóa userId thành chuỗi an toàn để đặt tên file trên Android
  String _encodeSafeUserId(String? userId) {
    final rawId = (userId == null || userId.trim().isEmpty) ? 'guest' : userId;
    return base64Url.encode(utf8.encode(rawId));
  }

  /// Lấy đối tượng File trong thư mục ApplicationDocumentsDirectory của Android
  Future<File> _getLocalFile(String prefix, String? userId) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeId = _encodeSafeUserId(userId);
    return File('${dir.path}/${prefix}_$safeId.json');
  }

  /// Lưu danh sách Giỏ hàng vào file cart_<safeId>.json
  Future<void> saveCartItems(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    final file = await _getLocalFile('cart', userId);
    final payload = {
      'schemaVersion': _schemaVersion,
      'userId': userId ?? 'guest',
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'items': items,
    };
    await file.writeAsString(jsonEncode(payload), flush: true);
  }

  /// Đọc danh sách Giỏ hàng từ file cart_<safeId>.json
  Future<List<Map<String, dynamic>>> loadCartItems(String? userId) async {
    try {
      final file = await _getLocalFile('cart', userId);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawList = decoded['items'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      // Nếu file JSON bị lỗi định dạng, trả về danh sách rỗng để không crash app
      return [];
    }
  }

  /// Xóa sạch giỏ hàng cục bộ (gọi sau khi Đặt hàng thành công)
  Future<void> clearCart(String? userId) async {
    final file = await _getLocalFile('cart', userId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Lưu danh sách Yêu thích vào file favorites_<safeId>.json
  Future<void> saveFavoriteItems(
    String? userId,
    List<Map<String, dynamic>> items,
  ) async {
    final file = await _getLocalFile('favorites', userId);
    final payload = {
      'schemaVersion': _schemaVersion,
      'userId': userId ?? 'guest',
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'items': items,
    };
    await file.writeAsString(jsonEncode(payload), flush: true);
  }

  /// Đọc danh sách Yêu thích từ file favorites_<safeId>.json
  Future<List<Map<String, dynamic>>> loadFavoriteItems(String? userId) async {
    try {
      final file = await _getLocalFile('favorites', userId);
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawList = decoded['items'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
```

---

### 4.2. Dịch vụ Thông báo Android (`lib/core/services/local_notification_service.dart`)

Kết hợp `flutter_local_notifications` và `firebase_messaging` để hiển thị thông báo đơn hàng trên Android:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'smartstore_orders_channel';
  static const String _channelName = 'Thông báo đơn hàng SmartStore';
  static const String _channelDesc =
      'Cập nhật trạng thái đơn hàng và khuyến mãi từ SmartStore';

  /// Khởi tạo Local Notifications & xin quyền trên Android 13+
  static Future<void> initialize({
    void Function(String? orderId)? onNotificationTap,
  }) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );

    // Xin quyền POST_NOTIFICATIONS trên Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Lắng nghe tin nhắn FCM khi ứng dụng đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      showOrderNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? 'SmartStore',
        body: notification.body ?? '',
        orderId: message.data['orderId']?.toString(),
      );
    });
  }

  /// Hiển thị thông báo trạng thái đơn hàng ngay trên thanh trạng thái Android
  static Future<void> showOrderNotification({
    required int id,
    required String title,
    required String body,
    String? orderId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: orderId,
    );
  }
}
```
