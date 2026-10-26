import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        context.read<OrderProvider>().loadOrders(
          auth.activeUserId,
          isAdmin: auth.isAdmin,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final found = orderProv.findOrder(widget.orderId);
    final order =
        found != null && (auth.isAdmin || found.userId == auth.activeUserId)
        ? found
        : null;
    final accent = Theme.of(context).colorScheme.primary;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
        body: const Center(child: Text('Không tìm thấy thông tin đơn hàng.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Đơn hàng ${order.orderCode} (F15)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Trạng thái & Tiến trình vận chuyển
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tiến trình đơn hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    LmStatusPill(
                      text: order.statusLabelVi,
                      color: order.status == 'cancelled'
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ],
                ),
                const Divider(height: 20),
                ...order.statusHistory.reversed.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.radio_button_checked_rounded,
                          size: 16,
                          color: accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                step['time'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Địa chỉ giao hàng
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Địa chỉ nhận hàng',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '${order.shippingAddress.fullName} • ${order.shippingAddress.phone}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  order.shippingAddress.addressLine,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Danh sách sản phẩm Snapshot
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sản phẩm trong đơn (Snapshot Giá)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                const Divider(height: 20),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.quantity}x ${item.productName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${item.variantLabel} • Đơn giá: ${CurrencyFormatter.formatVnd(item.priceVnd)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatVnd(item.lineTotalVnd),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tạm tính:'),
                    Text(CurrencyFormatter.formatVnd(order.subtotalVnd)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Phí vận chuyển:'),
                    Text(CurrencyFormatter.formatVnd(order.shippingFeeVnd)),
                  ],
                ),
                if (order.discountVnd > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Giảm giá (${order.couponCode}):'),
                      Text(
                        '-${CurrencyFormatter.formatVnd(order.discountVnd)}',
                        style: const TextStyle(color: AppColors.success),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Phương thức thanh toán:'),
                    Text(
                      order.paymentMethod == 'payos'
                          ? 'PayOS VietQR (${order.paymentStatus == 'paid' ? 'Đã thanh toán' : 'Chờ TT'})'
                          : 'COD (${order.paymentStatus == 'paid' ? 'Đã thu tiền' : 'Thanh toán khi nhận'})',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: order.paymentStatus == 'paid'
                            ? AppColors.success
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán:',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatVnd(order.totalVnd),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Mã QR đơn hàng
          LmMaterialCard(
            child: Column(
              children: [
                const Text(
                  'Mã QR định danh đơn hàng',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                QrImageView(
                  data: order.orderCode,
                  size: 120,
                  version: QrVersions.auto,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. Nút Hủy đơn hàng (F16) nếu đơn đang ở `pending` hoặc `confirmed`
          if (order.canBeCancelled)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () async {
                await orderProv.cancelOrder(order.orderCode);
                if (!context.mounted) return;
                await context.read<ProductProvider>().loadProducts();
                if (!context.mounted) return;
                context.read<NotificationProvider>().addNotification(
                  title: 'Đã hủy đơn hàng ${order.orderCode}',
                  body: 'Đơn hàng đã được hủy và hoàn lại số lượng tồn kho.',
                  orderId: order.orderCode,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Đã hủy đơn hàng & hoàn lại số lượng tồn kho (F16)!',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Hủy đơn hàng (F16)'),
            ),
        ],
      ),
    );
  }
}
