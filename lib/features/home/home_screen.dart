import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../products/compare_phones_screen.dart';
import '../products/product_detail_screen.dart';
import '../wishlist/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;

  static const List<String> _brandFilters = [
    'Tất cả',
    'Apple',
    'Samsung',
    'Xiaomi',
    'OPPO',
    'Phụ kiện',
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final banners = productProvider.banners;
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.smartphone_rounded, size: 19, color: accent),
            ),
            const SizedBox(width: 10),
            const Text('SmartStore'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'So sánh cấu hình điện thoại',
            icon: Badge(
              isLabelVisible: productProvider.comparedProductIds.isNotEmpty,
              label: Text('${productProvider.comparedProductIds.length}'),
              child: const Icon(Icons.compare_arrows_rounded),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComparePhonesScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Danh sách yêu thích (F12)',
            icon: Badge(
              isLabelVisible: wishlistProvider.favoriteProductIds.isNotEmpty,
              label: Text('${wishlistProvider.favoriteProductIds.length}'),
              child: const Icon(Icons.favorite_border_rounded),
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // 1. Thanh tìm kiếm nhanh kiểu Frosted-Glass
          LmGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            borderRadius: 16,
            child: TextField(
              onChanged: productProvider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Tìm iPhone 16 Pro Max, Galaxy S25, Xiaomi 15...',
                prefixIcon: Icon(Icons.search_rounded),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Hero Banner Slider trên nền trắng chuẩn UI DESIGN (Không dùng mảng màu lòe loẹt)
          if (banners.isNotEmpty) ...[
            SizedBox(
              height: 168,
              child: PageView.builder(
                itemCount: banners.length,
                onPageChanged: (idx) => setState(() => _bannerIndex = idx),
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: LmMaterialCard(
                      padding: const EdgeInsets.all(18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              productId: banner.targetProductId,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LmStatusPill(
                                  text: banner.badge,
                                  color: accent,
                                  icon: Icons.auto_awesome_rounded,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  banner.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                    letterSpacing: -0.4,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  banner.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          PhoneStudioIllustration(
                            brandId:
                                productProvider.allProducts
                                    .where(
                                      (p) => p.id == banner.targetProductId,
                                    )
                                    .firstOrNull
                                    ?.brandId ??
                                'SmartStore',
                            productName:
                                productProvider.allProducts
                                    .where(
                                      (p) => p.id == banner.targetProductId,
                                    )
                                    .firstOrNull
                                    ?.name ??
                                banner.title,
                            colorHex:
                                productProvider.allProducts
                                    .where(
                                      (p) => p.id == banner.targetProductId,
                                    )
                                    .firstOrNull
                                    ?.defaultColorHex ??
                                '#C5B4A5',
                            height: 112,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (idx) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _bannerIndex == idx ? 20 : 6,
                  decoration: BoxDecoration(
                    color: _bannerIndex == idx ? accent : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // 3. Thanh chọn Danh mục & Hãng (F05)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thương hiệu & Danh mục',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${products.length} sản phẩm',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _brandFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final brand = _brandFilters[index];
                final isSelected = productProvider.selectedBrand == brand;
                return ChoiceChip(
                  label: Text(brand),
                  selected: isSelected,
                  onSelected: (_) => productProvider.loadProducts(brand: brand),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // 4. Lưới sản phẩm nổi bật & mới nhất (F04)
          const Text(
            'Sản phẩm nổi bật & Chính hãng',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFav = wishlistProvider.isFavorite(product.id);

              return LmMaterialCard(
                padding: const EdgeInsets.all(12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: product.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LmStatusPill(text: product.brandId, color: accent),
                        InkWell(
                          borderRadius: BorderRadius.circular(99),
                          onTap: () =>
                              wishlistProvider.toggleFavorite(product.id),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 19,
                              color: isFav
                                  ? AppColors.error
                                  : AppColors.textFaint,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: PhoneStudioIllustration(
                          brandId: product.brandId,
                          categoryId: product.categoryId,
                          productName: product.name,
                          colorHex: product.defaultColorHex,
                          imageUrl: product.thumbnailUrl,
                          height: 105,
                        ),
                      ),
                    ),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.ink,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${product.ratingAvg} (${product.reviewCount})',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Đã bán ${product.soldCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textFaint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.formatVnd(product.priceFromVnd),
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
