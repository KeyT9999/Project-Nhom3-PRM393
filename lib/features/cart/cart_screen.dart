import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _proceedToCheckout(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (auth.isOfflineSimulated) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đang ở chế độ Offline (F23)'),
          content: const Text(
            'Giỏ hàng hoạt động hoàn toàn Offline nhờ lưu vào file cart_<uid>.json.\n\nTuy nhiên, bước Đặt hàng (Checkout) cần kết nối Internet để Server xác minh giá bán và tồn kho thực tế.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Để sau'),
            ),
            ElevatedButton(
              onPressed: () {
                auth.toggleOfflineSimulation(false);
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              child: const Text('Bật lại mạng & Checkout'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final items = cartProvider.items;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn (F11)'),
        actions: [
          IconButton(
            tooltip: 'Giả lập Bật/Tắt mạng để test TC07 & TC08',
            icon: Icon(
              authProvider.isOfflineSimulated
                  ? Icons.wifi_off_rounded
                  : Icons.wifi_rounded,
              color: authProvider.isOfflineSimulated
                  ? AppColors.warning
                  : AppColors.success,
            ),
            onPressed: () => authProvider.toggleOfflineSimulation(),
          ),
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Xóa toàn bộ giỏ hàng',
              onPressed: () => cartProvider.clearCart(),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: LmGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: 14,
              child: Row(
                children: [
                  Icon(Icons.folder_zip_outlined, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Local File Storage: cart_${authProvider.activeUserId}.json ↔ Firestore Sync (S01)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Giỏ hàng đang trống.\nHãy chọn một mẫu điện thoại và phiên bản Màu/RAM/ROM để thêm vào giỏ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return LmMaterialCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.smartphone_rounded,
                                color: accent,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.variantLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    CurrencyFormatter.formatVnd(
                                      item.lineTotalVnd,
                                    ),
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                  ),
                                  onPressed: () => cartProvider.updateQuantity(
                                    item.variantId,
                                    item.quantity - 1,
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                  ),
                                  onPressed: () => cartProvider.updateQuantity(
                                    item.variantId,
                                    item.quantity + 1,
                                  ),
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
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tạm tính (${cartProvider.totalQuantity} sản phẩm):',
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatVnd(cartProvider.subtotalVnd),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LmTintedButton(
                      label: 'Tiến hành Đặt hàng (F13)',
                      icon: Icons.shopping_bag_outlined,
                      onPressed: () => _proceedToCheckout(context),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
