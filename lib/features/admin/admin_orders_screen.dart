import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderProvider>().loadOrders(
          context.read<AuthProvider>().activeUserId,
          isAdmin: true,
        );
      }
    });
  }

  static const Map<String, String> _statusMap = {
    'all': 'Tất cả',
    'pending': 'Chờ xác nhận',
    'confirmed': 'Đã xác nhận',
    'processing': 'Đang đóng gói',
    'shipping': 'Đang giao hàng',
    'delivered': 'Đã giao thành công',
    'cancelled': 'Đã hủy',
    'failed_delivery': 'Giao thất bại',
  };

  Color _colorForStatus(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
      case 'processing':
      case 'shipping':
        return const Color(0xFF2F6BFF);
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
      case 'failed_delivery':
        return AppColors.danger;
      default:
        return AppColors.ink3;
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    OrderModel order,
    String newStatus,
  ) async {
    final label = _statusMap[newStatus] ?? newStatus;
    try {
      final updated = await context
          .read<OrderProvider>()
          .adminUpdateOrderStatus(
            orderId: order.id,
            newStatus: newStatus,
            note: 'Admin cập nhật trạng thái sang: $label',
          );
      if (!context.mounted || updated == null) return;
      await context.read<ProductProvider>().loadProducts();
      if (!context.mounted) return;

      final notifTitle = 'Đơn hàng ${order.orderCode}: $label';
      final notifBody =
          'Đơn hàng ${order.orderCode} của bạn đã chuyển sang trạng thái "$label".';

      context.read<NotificationProvider>().addNotification(
        title: notifTitle,
        body: notifBody,
        orderId: order.id,
      );
      try {
        await LocalNotificationService.showOrderNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: notifTitle,
          body: notifBody,
          orderId: order.id,
        );
      } catch (_) {}

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật ${order.orderCode} → $label'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.danger, content: Text('$e')),
      );
    }
  }

  void _openQrScannerModal(BuildContext context) {
    final codeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quét mã QR Vận đơn / Nhập mã đơn',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: MobileScanner(
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      final raw = barcode.rawValue;
                      if (raw != null && raw.isNotEmpty) {
                        Navigator.pop(ctx);
                        _lookupAndShowOrder(context, raw);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Hoặc nhập mã đơn (VD: ORD-...)',
                      prefixIcon: Icon(Icons.qr_code_2),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () {
                    final code = codeCtrl.text.trim();
                    if (code.isEmpty) return;
                    Navigator.pop(ctx);
                    _lookupAndShowOrder(context, code);
                  },
                  child: const Text('Tra cứu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _lookupAndShowOrder(BuildContext context, String rawCode) {
    final order = context.read<OrderProvider>().findOrder(rawCode);
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy đơn hàng với mã: $rawCode')),
      );
      return;
    }
    _showStatusUpdateModal(context, order);
  }

  void _showStatusUpdateModal(BuildContext context, OrderModel order) {
    const allowedTransitions = {
      'pending': {'confirmed', 'cancelled'},
      'confirmed': {'processing', 'cancelled'},
      'processing': {'shipping', 'cancelled'},
      'shipping': {'delivered', 'failed_delivery'},
    };
    final validNext = allowedTransitions[order.status] ?? <String>{};
    final statuses = [
      'pending',
      'confirmed',
      'processing',
      'shipping',
      'delivered',
      'cancelled',
      'failed_delivery',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xử lý đơn hàng ${order.orderCode}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Khách nhận: ${order.shippingAddress.fullName} (${order.shippingAddress.phone})',
              style: const TextStyle(fontSize: 13, color: AppColors.ink3),
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statuses.map((st) {
                final isCurrent = order.status == st;
                final canSelect = isCurrent || validNext.contains(st);
                return ChoiceChip(
                  label: Text(_statusMap[st] ?? st),
                  selected: isCurrent,
                  onSelected: !canSelect
                      ? null
                      : (selected) {
                          if (!selected || isCurrent) return;
                          Navigator.pop(ctx);
                          _updateStatus(context, order, st);
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final orders = orderProv.ordersByStatus(_statusFilter);
    final palette = context.watch<AuthProvider>().palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý & Duyệt Đơn hàng'),
        actions: [
          IconButton(
            tooltip: 'Quét QR vận đơn',
            onPressed: () => _openQrScannerModal(context),
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _statusMap.entries.map((entry) {
                final selected = _statusFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _statusFilter = entry.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có đơn hàng nào trong trạng thái này.',
                      style: TextStyle(color: AppColors.ink3),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return LmMaterialCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.orderCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.ink,
                                  ),
                                ),
                                LmStatusPill(
                                  text: order.statusLabelVi,
                                  color: _colorForStatus(order.status),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Người nhận: ${order.shippingAddress.fullName} • ${order.shippingAddress.phone}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Địa chỉ: ${order.shippingAddress.addressLine}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.ink3,
                              ),
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${order.items.length} sản phẩm • ${order.paymentMethod.toUpperCase()} (${order.paymentStatus == 'paid' ? 'Đã TT' : 'Chưa TT'})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.ink3,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatVnd(
                                        order.totalVnd,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: palette.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: () =>
                                      _showStatusUpdateModal(context, order),
                                  icon: const Icon(Icons.sync_alt, size: 18),
                                  label: const Text('Cập nhật trạng thái'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
