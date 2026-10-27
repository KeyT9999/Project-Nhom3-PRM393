import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/product_display.dart';
import '../../core/utils/product_images.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/product_skeleton.dart';
import '../../data/models/product_model.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _precached = false;

  static const List<String> _brandFilters = [
    'Tất cả',
    'Apple',
    'Samsung',
    'Xiaomi',
    'OPPO',
    'Phụ kiện',
  ];

  static const String _bannerProductId = 'iphone_16_pro_max';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProduct(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      _precacheHomeImages();
    }
  }

  /// Nạp trước ảnh banner và 6 sản phẩm đầu để cuộn/vào trang không bị khựng.
  Future<void> _precacheHomeImages() async {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final bucket = ProductImage.cacheBucket((width - 44) / 2, dpr);
    final lookup = ProductImages.instance;
    final products = context.read<ProductProvider>().products;
    precacheImage(
      const ResizeImage(
        AssetImage('assets/images/hero_iphone_rock.jpg'),
        width: 450,
      ),
      context,
      onError: (_, _) {},
    );
    await lookup.ensureLoaded();
    if (!mounted) return;
    for (final p in products.take(6)) {
      final path = lookup.main(p.id);
      if (path == null) continue;
      precacheImage(
        ResizeImage(AssetImage(path), width: bucket),
        context,
        onError: (_, _) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LiquidAmbientCanvas(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Consumer2<ProductProvider, WishlistProvider>(
                  builder: (_, products, wishlist, _) =>
                      _buildHeader(products, wishlist),
                ),
              ),
              SliverToBoxAdapter(child: _buildSearch(productProvider)),
              SliverToBoxAdapter(
                child: Selector<ProductProvider, ProductModel?>(
                  selector: (_, p) {
                    for (final item in p.products) {
                      if (item.id == _bannerProductId) return item;
                    }
                    return null;
                  },
                  builder: (_, banner, _) => banner == null
                      ? const SizedBox.shrink()
                      : _buildBanner(banner),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sản phẩm',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Selector<ProductProvider, int>(
                        selector: (_, p) => p.products.length,
                        builder: (_, count, _) => Text(
                          '$count sản phẩm',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Selector<ProductProvider, String>(
                  selector: (_, p) => p.selectedBrand,
                  builder: (_, _, _) => _buildBrandFilters(productProvider),
                ),
              ),
              Consumer2<ProductProvider, WishlistProvider>(
                builder: (context, prov, wishlist, _) {
                  final products = prov.products;
                  if (prov.isLoading && products.isEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      sliver: SliverGrid.builder(
                        gridDelegate: _gridDelegate,
                        itemCount: 6,
                        itemBuilder: (_, _) =>
                            const ProductSkeleton(grid: true),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    sliver: SliverGrid.builder(
                      gridDelegate: _gridDelegate,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          isFavorite: wishlist.isFavorite(product.id),
                          onTap: () => _openProduct(product.id),
                          onToggleFavorite: () =>
                              wishlistProvider.toggleFavorite(product.id),
                        );
                      },
                    ),
                  );
                },
              ),
              Consumer<ProductProvider>(
                builder: (context, prov, _) {
                  final accessories = prov.products
                      .where(
                        (p) => p.categoryId.toLowerCase().contains('accessor'),
                      )
                      .toList();
                  if (accessories.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverMainAxisGroup(
                    slivers: [
                      _accessoriesTitle(prov),
                      SliverToBoxAdapter(child: _accessoriesList(accessories)),
                    ],
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildServiceItem(
                        Icons.local_shipping_outlined,
                        'Giao hàng nhanh',
                      ),
                      _buildServiceItem(
                        Icons.verified_outlined,
                        'Hàng chính hãng',
                      ),
                      _buildServiceItem(
                        Icons.autorenew_rounded,
                        'Đổi trả 30 ngày',
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

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.66,
  );

  Widget _accessoriesTitle(ProductProvider productProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Phụ kiện',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            GestureDetector(
              onTap: () => productProvider.loadProducts(brand: 'Phụ kiện'),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accessoriesList(List<ProductModel> accessories) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: accessories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = accessories[index];
          return SizedBox(
            width: 140,
            child: LiquidGlassCard(
              padding: const EdgeInsets.all(10),
              onTap: () => _openProduct(item.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: RepaintBoundary(
                        child: ProductImage(
                          productId: item.id,
                          fallbackUrl: item.thumbnailUrl,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ProductDisplay.shortName(item.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatVnd(item.priceFromVnd),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProductProvider products, WishlistProvider wishlist) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          const Text(
            'SmartStore',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'So sánh cấu hình',
            icon: Badge(
              isLabelVisible: products.comparedProductIds.isNotEmpty,
              label: Text('${products.comparedProductIds.length}'),
              child: const Icon(Icons.compare_arrows_rounded, color: AppColors.ink),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ComparePhonesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Yêu thích',
            icon: Badge(
              isLabelVisible: wishlist.favoriteProductIds.isNotEmpty,
              label: Text('${wishlist.favoriteProductIds.length}'),
              child: const Icon(Icons.favorite_border_rounded, color: AppColors.ink),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ProductProvider productProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        borderRadius: 10,
        child: TextField(
          controller: _searchController,
          onChanged: productProvider.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Tìm điện thoại, phụ kiện...',
            hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GestureDetector(
        onTap: () => _openProduct(product.id),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: AppColors.brand800,
            height: 170,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ProductDisplay.shortName(product.name),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Từ ${CurrencyFormatter.formatVnd(product.priceFromVnd)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Xem chi tiết',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 170,
                  child: Image.asset(
                    'assets/images/hero_iphone_rock.jpg',
                    fit: BoxFit.cover,
                    cacheWidth: 450,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandFilters(ProductProvider productProvider) {
    return SizedBox(
      height: 36,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                brand,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.ink,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.inkSecondary),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(11)),
                    child: RepaintBoundary(
                      child: ProductImage(
                        productId: product.id,
                        fallbackUrl: product.thumbnailUrl,
                        aspectRatio: null,
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Yêu thích',
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: isFavorite ? AppColors.error : AppColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ProductDisplay.shortName(product.name),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.ink,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      '${product.ratingAvg} · Đã bán ${product.soldCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.formatVnd(product.priceFromVnd),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
