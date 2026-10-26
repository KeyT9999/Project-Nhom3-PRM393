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
    '256GB': 34990000,
    '512GB': 40990000,
    '1TB': 46990000,
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

  static const List<Map<String, String>> _accessories = [
    {
      'name': 'AirPods Pro 2 (USB-C)',
      'price': '6.190.000 ₫',
      'image': 'assets/images/acc_airpods_pro.jpg',
    },
    {
      'name': 'Ốp Trong Suốt MagSafe',
      'price': '1.490.000 ₫',
      'image': 'assets/images/acc_clear_case.jpg',
    },
    {
      'name': 'Sạc MagSafe Nhanh 25W',
      'price': '1.190.000 ₫',
      'image': 'assets/images/acc_magsafe_charger.jpg',
    },
    {
      'name': 'Ví MagSafe FineWoven',
      'price': '1.690.000 ₫',
      'image': 'assets/images/acc_finewoven_wallet.jpg',
    },
  ];

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
    final currentPrice = _storagePrices[_selectedStorage] ?? 34990000;

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
                          color: AppColors.brand700,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brand700.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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
                            'Apple Store Pro',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Chính Hãng VN/A • Slate Navy Edition',
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
                          child: const Icon(
                            Icons.compare_arrows_rounded,
                            color: AppColors.brand700,
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
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            color: AppColors.brand700,
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
                        hintText: 'Tìm kiếm iPhone 16 Pro Max, phụ kiện...',
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
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.phone_iphone_rounded,
                                      size: 100,
                                      color: AppColors.brand700,
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
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brand700,
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
                                    builder: (_) => const ProductDetailScreen(
                                      productId: 'iphone_16_pro_max',
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
                                color: AppColors.brand700.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 16,
                                color: AppColors.brand700,
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brand700,
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
                                ? AppColors.brand700
                                : Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.brand700
                                  : AppColors.border,
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
                                    color: AppColors.brand50,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.brand200),
                                  ),
                                  child: Text(
                                    product.brandId,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brand700,
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
                                  style: const TextStyle(
                                    color: AppColors.brand700,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: AppColors.brand700,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brand700
                                            .withValues(alpha: 0.25),
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
                        child: const Row(
                          children: [
                            Text(
                              'Xem tất cả',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brand700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppColors.brand700,
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
                  height: 154,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _accessories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _accessories[index];
                      return SizedBox(
                        width: 140,
                        child: LiquidGlassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 18,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã chọn ${item['name']}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    item['image']!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.headphones_rounded,
                                      size: 40,
                                      color: AppColors.brand700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['name']!,
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
                                item['price']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brand700,
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
                        const Row(
                          children: [
                            Text(
                              '★★★★★',
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Đánh giá xác minh',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.brand700,
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
                              decoration: const BoxDecoration(
                                color: AppColors.brand700,
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
                      ),
                      _buildTrustBadge(
                        Icons.verified_rounded,
                        'Apple VN/A',
                        '1 đổi 1 12T',
                      ),
                      _buildTrustBadge(
                        Icons.credit_card_rounded,
                        'Trả Góp 0%',
                        'Qua thẻ',
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

  Widget _buildTrustBadge(IconData icon, String title, String subtitle) {
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
          child: Icon(icon, size: 18, color: AppColors.brand700),
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
