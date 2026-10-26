import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
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
            'Túi hàng hoạt động hoàn toàn Offline nhờ lưu vào file cart.json.\n\nTuy nhiên, bước Đặt hàng cần kết nối Internet để hệ thống kiểm tra tồn kho và xác nhận thanh toán.',
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
        title: const Text('Túi Hàng Của Bạn'),
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
                    title: const Text('Xác nhận xóa túi hàng?'),
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
        animate: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Offline sync banner pill in Glass
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: LiquidGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  borderRadius: 14,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_done_rounded,
                        size: 17,
                        color: AppColors.brand700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đồng bộ tức thì: cart_${authProvider.activeUserId}.json ↔ Cloud',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                                decoration: BoxDecoration(
                                  color: AppColors.brand700.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 44,
                                  color: AppColors.brand700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Túi Hàng Đang Trống',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Hãy chọn một phiên bản iPhone 16 hoặc phụ kiện chính hãng để bắt đầu đặt hàng.',
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
                            padding: const EdgeInsets.all(14),
                            borderRadius: 18,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 68,
                                  height: 74,
                                  child: Center(
                                    child: PhoneStudioIllustration(
                                      brandId: 'Apple',
                                      productName: item.productName,
                                      colorHex: '#C5B4A5',
                                      height: 68,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppColors.ink,
                                          letterSpacing: -0.2,
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
                                          color: AppColors.brand700,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.5,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity Stepper
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(999),
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
                    color: Colors.white.withValues(alpha: 0.82),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 1.2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
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
                              'Tổng phụ (${cartProvider.totalQuantity} món):',
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
                                color: AppColors.brand700,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LiquidPillButton(
                          label: 'Tiến Hành Đặt Hàng',
                          icon: Icons.shopping_bag_outlined,
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
