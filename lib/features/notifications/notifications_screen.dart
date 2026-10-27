import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../providers/notification_provider.dart';
import '../orders/order_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _triggerDemoLocalNotification(BuildContext context) async {
    final notifProv = context.read<NotificationProvider>();
    notifProv.addNotification(
      title: 'Khuyến mãi Flash Sale SmartStore!',
      body: 'Giảm ngay 500.000₫ khi nhập mã SMART500 cho iPhone 16 Series.',
    );
    try {
      await LocalNotificationService.showOrderNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'SmartStore • Thông báo đẩy Android',
        body: 'Giảm ngay 500.000₫ khi nhập mã SMART500 cho iPhone 16 Series!',
      );
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã gửi thông báo thử.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationProvider>();
    final notifications = notifProv.notifications;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo & Ưu đãi'),
        actions: [
          IconButton(
            tooltip: 'Bắn thử Local Notification trên Android',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => _triggerDemoLocalNotification(context),
          ),
          if (notifProv.unreadCount > 0)
            TextButton(
              onPressed: notifProv.markAllAsRead,
              child: const Text('Đọc tất cả'),
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return LmMaterialCard(
            selected: !item.isRead,
            onTap: () {
              notifProv.markAsRead(item.id);
              if (item.orderId != null && item.orderId!.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(orderId: item.orderId!),
                  ),
                );
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: item.isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                          fontSize: 14.5,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
