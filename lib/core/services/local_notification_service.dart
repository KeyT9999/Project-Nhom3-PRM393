import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

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
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );

    // Xin quyền POST_NOTIFICATIONS trên Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
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
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: orderId,
    );
  }
}
