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
  String _selectedFinish = 'desert';
  String _selectedStorage = '256GB';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _brandFilters = [
    'Tất cả',
    'Apple',
    'Samsung',
    'Xiaomi',
    'OPPO',
    'Phụ kiện',
  ];

  static const Map<String, int> _storagePrices = {
    '256GB': 31990000,
    '512GB': 37990000,
    '1TB': 42990000,
  };

  static const List<Map<String, dynamic>> _proFeatures = [
    {
      'icon': Icons.camera_alt_rounded,
      'title': 'Camera 48MP Fusion',
      'desc': 'Nút Camera Control cảm ứng lực',
    },
    {
      'icon': Icons.smartphone_rounded,
      'title': 'OLED 6.9" 120Hz',
      'desc': 'Viền màn hình mỏng nhất lịch sử',
    },
    {
      'icon': Icons.memory_rounded,
      'title': 'Chip A18 Pro 3nm',
      'desc': 'Apple Intelligence trực tiếp trên máy',
    },
    {
      'icon': Icons.battery_charging_full_rounded,
      'title': 'Pin Đến 33 Giờ',
      'desc': 'Kỷ lục bền bỉ nhất trên iPhone',
    },
  ];

  static String _finishLabel(String key) {
    switch (key) {
      case 'natural':
        return 'Titan Tự Nhiên';
      case 'white':
        return 'Titan Trắng';
      case 'black':
        return 'Titan Đen';
      default:
        return 'Titan Sa Mạc';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final products = productProvider.products;
    final accent = Theme.of(context).colorScheme.primary;
    final selectedStorageGB = _selectedStorage == '1TB'
        ? 1024
        : (_selectedStorage == '512GB' ? 512 : 256);
    final heroVariants = productProvider.repository.getCachedVariants(
      'iphone_16_pro_max',
    );
    final matchedHeroVariant = heroVariants
        .where((v) => v.storageGB == selectedStorageGB)
        .firstOrNull;
    final currentPrice =
        matchedHeroVariant?.priceVnd ??
        (_storagePrices[_selectedStorage] ?? 31990000);
    final accessoryProducts = productProvider.allProducts
        .where((p) => p.isActive && p.categoryId == 'accessories')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LiquidAmbientCanvas(
        animate: true,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sleek Floating Glass Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.smartphone_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SmartStore',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Flagship Đa Thương Hiệu • Liquid-Glass',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.inkMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Compare Button
                      IconButton(
                        tooltip: 'So sánh cấu hình',
                        icon: Badge(
                          isLabelVisible:
                              productProvider.comparedProductIds.isNotEmpty,
                          label: Text(
                            '${productProvider.comparedProductIds.length}',
                          ),
                          child: Icon(
                            Icons.compare_arrows_rounded,
                            color: accent,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ComparePhonesScreen(),
                            ),
                          );
                        },
                      ),
                      // Wishlist Button
                      IconButton(
                        tooltip: 'Yêu thích',
                        icon: Badge(
                          isLabelVisible:
                              wishlistProvider.favoriteProductIds.isNotEmpty,
                          label: Text(
                            '${wishlistProvider.favoriteProductIds.length}',
                          ),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: accent,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WishlistScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),


              // 3. Search Bar in Liquid Glass
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: LiquidGlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    borderRadius: 16,
                    child: TextField(
                      controller: _searchController,
                      onChanged: productProvider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText:
                            'Tìm kiếm iPhone 16, Galaxy S25, Xiaomi, OPPO...',
                        hintStyle: const TextStyle(
                          color: AppColors.inkMuted,
                          fontSize: 13.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.inkMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  productProvider.setSearchQuery('');
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Hero Flagship Section (Streamlined for Mobile)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: LiquidGlassCard(
                    padding: const EdgeInsets.all(18),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'APPLE INTELLIGENCE ĐÃ SẴN SÀNG',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.inkMuted,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0071E3).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '💧 Liquid-Glass',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0071E3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'iPhone 16 Pro Max',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Titanium Siêu Bền. Đẳng Cấp Pro.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.inkSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Center Studio Photography on Pedestal
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 220,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F1722)
                                          .withValues(alpha: 0.12),
                                      blurRadius: 28,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/images/hero_iphone_rock.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Icon(
                                      Icons.phone_iphone_rounded,
                                      size: 100,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.62),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${_finishLabel(_selectedFinish)} • $_selectedStorage',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Price and Finish Swatches
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giá ưu đãi từ:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatVnd(currentPrice),
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                            // 4 Titanium Finishes
                            Row(
                              children: [
                                TitaniumFinishDot(
                                  finishKey: 'desert',
                                  label: 'Titan Sa Mạc',
                                  color: AppColors.desertTitanium,
                                  isSelected: _selectedFinish == 'desert',
                                  onSelected: () =>
                                      setState(() => _selectedFinish = 'desert'),
                                ),
                                const SizedBox(width: 6),
                                TitaniumFinishDot(
                                  finishKey: 'natural',
                                  label: 'Titan Tự Nhiên',
                                  color: AppColors.naturalTitanium,
                                  isSelected: _selectedFinish == 'natural',
                                  onSelected: () =>
                                      setState(() => _selectedFinish = 'natural'),
                                ),
                                const SizedBox(width: 6),
                                TitaniumFinishDot(
                                  finishKey: 'white',
                                  label: 'Titan Trắng',
                                  color: AppColors.whiteTitanium,
                                  isSelected: _selectedFinish == 'white',
                                  onSelected: () =>
                                      setState(() => _selectedFinish = 'white'),
                                ),
                                const SizedBox(width: 6),
                                TitaniumFinishDot(
                                  finishKey: 'black',
                                  label: 'Titan Đen',
                                  color: AppColors.blackTitanium,
                                  isSelected: _selectedFinish == 'black',
                                  onSelected: () =>
                                      setState(() => _selectedFinish = 'black'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Capacity Pills & CTA Row
                        Row(
                          children: [
                            StorageCapacityPill(
                              capacity: '256GB',
                              isSelected: _selectedStorage == '256GB',
                              onSelected: () =>
                                  setState(() => _selectedStorage = '256GB'),
                            ),
                            const SizedBox(width: 8),
                            StorageCapacityPill(
                              capacity: '512GB',
                              isSelected: _selectedStorage == '512GB',
                              onSelected: () =>
                                  setState(() => _selectedStorage = '512GB'),
                            ),
                            const SizedBox(width: 8),
                            StorageCapacityPill(
                              capacity: '1TB',
                              isSelected: _selectedStorage == '1TB',
                              onSelected: () =>
                                  setState(() => _selectedStorage = '1TB'),
                            ),
                            const Spacer(),
                            LiquidPillButton(
                              label: 'Mua Ngay',
                              icon: Icons.bolt_rounded,
                              height: 40,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                      productId: 'iphone_16_pro_max',
                                      initialStorageGB: selectedStorageGB,
                                      initialColorKeyword: _selectedFinish,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. 4 Pro Feature Chips (Compact Horizontal Scroll per user choice)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 64,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _proFeatures.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _proFeatures[index];
                      return LiquidGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 16,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  item['desc'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.inkMuted,
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
              ),

              // 6. Category & Brand Filter Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dòng Sản Phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${products.length} mẫu có sẵn',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _brandFilters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final brand = _brandFilters[index];
                      final isSelected = productProvider.selectedBrand == brand;
                      return GestureDetector(
                        onTap: () => productProvider.loadProducts(brand: brand),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent
                                : Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected ? accent : AppColors.border,
                            ),
                          ),
                          child: Text(
                            brand,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.ink,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 7. Lineup Product Grid (Real Photography & Liquid-Glass Cards)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      final isFav = wishlistProvider.isFavorite(product.id);

                      return LiquidGlassCard(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 18,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.22),
                                    ),
                                  ),
                                  child: Text(
                                    product.brandId,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => wishlistProvider.toggleFavorite(
                                    product.id,
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 18,
                                    color: isFav
                                        ? AppColors.error
                                        : AppColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Center(
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
                            ),
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.ink,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${product.ratingAvg}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.inkSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Đã bán ${product.soldCount}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.inkFaint,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  CurrencyFormatter.formatVnd(
                                    product.priceFromVnd,
                                  ),
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),

              // 8. Official Accessories Ecosystem (Horizontal Scroll per user request)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hệ Sinh Thái Phụ Kiện',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => productProvider.loadProducts(brand: 'Phụ kiện'),
                        child: Row(
                          children: [
                            Text(
                              'Xem tất cả',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 164,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: accessoryProducts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final acc = accessoryProducts[index];
                      return SizedBox(
                        width: 146,
                        child: LiquidGlassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 18,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(productId: acc.id),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: PhoneStudioIllustration(
                                    brandId: acc.brandId,
                                    categoryId: acc.categoryId,
                                    productName: acc.name,
                                    colorHex: acc.defaultColorHex,
                                    imageUrl: acc.thumbnailUrl.isNotEmpty
                                        ? acc.thumbnailUrl
                                        : null,
                                    height: 84,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                acc.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.formatVnd(acc.priceFromVnd),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 9. Verified Customer Testimonial (Liquid-Glass Card)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '★★★★★',
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Đánh giá xác minh',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '"Khung viền Titan Sa Mạc cầm nhẹ và đầm tay bất ngờ. Nút Camera Control mới mở camera tức thì, quay video 4K 120fps đẹp như phim rạp. Thật sự xứng đáng với đẳng cấp Pro Max!"',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            fontStyle: FontStyle.italic,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'HL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hoàng Long',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  'Chủ sở hữu iPhone 16 Pro Max 512GB',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 10. Trust Badges Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTrustBadge(
                        Icons.electric_bolt_rounded,
                        'Giao 2H',
                        'Toàn quốc',
                        accent,
                      ),
                      _buildTrustBadge(
                        Icons.verified_rounded,
                        'Chính Hãng',
                        '1 đổi 1 12T',
                        accent,
                      ),
                      _buildTrustBadge(
                        Icons.credit_card_rounded,
                        'Trả Góp 0%',
                        'Qua thẻ',
                        accent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(
    IconData icon,
    String title,
    String subtitle,
    Color accent,
  ) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9.5,
            color: AppColors.inkMuted,
          ),
        ),
      ],
    );
  }
}
