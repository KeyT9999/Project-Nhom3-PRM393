import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
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
    final productProvider = context.watch<ProductProvider>();
    final items = cartProvider.items;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Giỏ Hàng Của Bạn'),
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
                    title: const Text('Xác nhận xóa giỏ hàng?'),
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
                      Icon(
                        Icons.cloud_done_rounded,
                        size: 17,
                        color: accent,
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
                                  color: accent.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 44,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Giỏ Hàng Đang Trống',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Hãy chọn một mẫu điện thoại chính hãng hoặc phụ kiện yêu thích để bắt đầu đặt hàng.',
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
                          final matchedProduct = productProvider.allProducts
                              .where((p) => p.id == item.productId)
                              .firstOrNull;
                          final matchedVariant = productProvider.repository
                              .findVariantById(item.productId, item.variantId);
                          final maxStock = matchedVariant?.stock;
                          final effectiveImageUrl = item.imageUrl.isNotEmpty
                              ? item.imageUrl
                              : (matchedProduct != null &&
                                        matchedProduct.thumbnailUrl.isNotEmpty
                                    ? matchedProduct.thumbnailUrl
                                    : null);

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
                                      brandId:
                                          matchedProduct?.brandId ?? 'Apple',
                                      categoryId:
                                          matchedProduct?.categoryId ??
                                          'smartphones',
                                      productName: item.productName,
                                      colorHex:
                                          matchedVariant?.colorHex ??
                                          matchedProduct?.defaultColorHex ??
                                          '#C5B4A5',
                                      imageUrl: effectiveImageUrl,
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
                                        maxStock != null
                                            ? '${item.variantLabel} • Kho: $maxStock'
                                            : item.variantLabel,
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
                                        style: TextStyle(
                                          color: accent,
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
                                        onPressed: () async {
                                          try {
                                            await cartProvider.updateQuantity(
                                              item.variantId,
                                              item.quantity - 1,
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    AppColors.error,
                                                content: Text('$e'),
                                              ),
                                            );
                                          }
                                        },
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
                                        icon: Icon(
                                          Icons.add,
                                          size: 14,
                                          color:
                                              (maxStock != null &&
                                                  item.quantity >= maxStock)
                                              ? AppColors.inkFaint
                                              : AppColors.ink,
                                        ),
                                        onPressed: () async {
                                          if (maxStock != null &&
                                              item.quantity >= maxStock) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Đã đạt tối đa tồn kho hiện có ($maxStock sản phẩm).',
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          try {
                                            await cartProvider.updateQuantity(
                                              item.variantId,
                                              item.quantity + 1,
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    AppColors.error,
                                                content: Text('$e'),
                                              ),
                                            );
                                          }
                                        },
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: accent,
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
