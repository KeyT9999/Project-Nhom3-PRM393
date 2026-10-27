import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/product_display.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/product_image.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Đang ở chế độ Offline',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          content: const Text(
            'Giỏ hàng được lưu trên máy nên vẫn dùng được khi không có mạng.\n\nTuy nhiên, bước Đặt hàng cần kết nối Internet để hệ thống kiểm tra tồn kho và xác nhận thanh toán.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Để sau'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {
                auth.toggleOfflineSimulation(false);
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              child: const Text('Bật mạng & Đặt hàng'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          IconButton(
            tooltip: 'Giả lập Offline',
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
              tooltip: 'Xóa toàn bộ',
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Xóa toàn bộ giỏ hàng?'),
                    content: const Text('Toàn bộ sản phẩm sẽ được xóa khỏi giỏ.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartProvider.clearCart();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          'Xóa sạch',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.ink),
            ),
        ],
      ),
      body: LiquidAmbientCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Cart Items List or Empty State
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceLightSlate,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 40,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Giỏ hàng trống',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Chọn sản phẩm từ trang chủ để thêm vào giỏ.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.inkSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return LiquidGlassCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 68,
                                  height: 74,
                                  child: Center(
                                    child: RepaintBoundary(
                                      child: ProductImage(
                                        productId: item.productId,
                                        fallbackUrl: item.imageUrl,
                                        padding: const EdgeInsets.all(2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ProductDisplay.shortName(item.productName),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.variantLabel,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        CurrencyFormatter.formatVnd(
                                          item.lineTotalVnd,
                                        ),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity Stepper
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 14),
                                        onPressed: () =>
                                            cartProvider.updateQuantity(
                                          item.variantId,
                                          item.quantity - 1,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 14),
                                        onPressed: () =>
                                            cartProvider.updateQuantity(
                                          item.variantId,
                                          item.quantity + 1,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // Floating Liquid-Glass Checkout Bar
      bottomNavigationBar: items.isEmpty
          ? null
          : ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    border: const Border(
                      top: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tạm tính (${cartProvider.totalQuantity} sản phẩm)',
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.inkMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatVnd(
                                cartProvider.subtotalVnd,
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LiquidPillButton(
                          label: 'Đặt hàng',
                          onPressed: () => _proceedToCheckout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
