import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../products/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final productProvider = context.watch<ProductProvider>();
    final favoriteProducts = productProvider.allProducts
        .where((p) => wishlistProvider.isFavorite(p.id))
        .toList();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách yêu thích (F12)')),
      body: favoriteProducts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Danh sách yêu thích đang trống.\nDữ liệu được lưu Offline tại favorites_<uid>.json và đồng bộ Firestore.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProducts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return LmMaterialCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: PhoneStudioIllustration(
                          brandId: product.brandId,
                          categoryId: product.categoryId,
                          productName: product.name,
                          colorHex: product.defaultColorHex,
                          height: 76,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LmStatusPill(text: product.brandId, color: accent),
                            const SizedBox(height: 6),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.formatVnd(product.priceFromVnd),
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Bỏ yêu thích',
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                        onPressed: () =>
                            wishlistProvider.toggleFavorite(product.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
