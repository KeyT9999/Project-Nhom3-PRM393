import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/product_display.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/product_skeleton.dart';
import '../../providers/product_provider.dart';
import 'compare_phones_screen.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  void _showFilterBottomSheet(BuildContext context) {
    final prov = context.read<ProductProvider>();
    int? selectedMaxPrice = prov.maxPriceVnd;
    int? selectedRam = prov.filterRamGB;
    int? selectedStorage = prov.filterStorageGB;
    bool onlyInStock = prov.onlyInStock;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ Lọc Sản Phẩm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          prov.applyFilters(clearAll: true);
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(
                            color: AppColors.brand700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Mức giá tối đa:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: selectedMaxPrice == null,
                        onSelected: (_) =>
                            setModalState(() => selectedMaxPrice = null),
                      ),
                      ChoiceChip(
                        label: const Text('Dưới 10 triệu'),
                        selected: selectedMaxPrice == 10000000,
                        onSelected: (_) =>
                            setModalState(() => selectedMaxPrice = 10000000),
                      ),
                      ChoiceChip(
                        label: const Text('Dưới 20 triệu'),
                        selected: selectedMaxPrice == 20000000,
                        onSelected: (_) =>
                            setModalState(() => selectedMaxPrice = 20000000),
                      ),
                      ChoiceChip(
                        label: const Text('Dưới 30 triệu'),
                        selected: selectedMaxPrice == 30000000,
                        onSelected: (_) =>
                            setModalState(() => selectedMaxPrice = 30000000),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Dung lượng RAM:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [null, 8, 12, 16].map((ram) {
                      return ChoiceChip(
                        label: Text(ram == null ? 'Tất cả' : '${ram}GB RAM'),
                        selected: selectedRam == ram,
                        onSelected: (_) =>
                            setModalState(() => selectedRam = ram),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Bộ nhớ trong (ROM):',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [null, 128, 256, 512, 1024].map((rom) {
                      final label = rom == null
                          ? 'Tất cả'
                          : (rom == 1024 ? '1TB' : '${rom}GB');
                      return ChoiceChip(
                        label: Text(label),
                        selected: selectedStorage == rom,
                        onSelected: (_) =>
                            setModalState(() => selectedStorage = rom),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Chỉ hiện còn hàng',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: onlyInStock,
                    activeThumbColor: AppColors.brand700,
                    onChanged: (value) =>
                        setModalState(() => onlyInStock = value),
                  ),
                  const SizedBox(height: 10),
                  LiquidPillButton(
                    label: 'Áp dụng bộ lọc',
                    icon: Icons.filter_alt_rounded,
                    onPressed: () {
                      prov.applyFilters(
                        maxPriceVnd: selectedMaxPrice,
                        ramGB: selectedRam,
                        storageGB: selectedStorage,
                        onlyInStock: onlyInStock,
                      );
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final products = prov.products;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        actions: [
          IconButton(
            tooltip: 'Bộ lọc nâng cao',
            icon: const Icon(Icons.tune_rounded, color: AppColors.brand700),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            tooltip: 'Xem so sánh',
            icon: Badge(
              isLabelVisible: prov.comparedProductIds.isNotEmpty,
              label: Text('${prov.comparedProductIds.length}'),
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
        ],
      ),
      body: LiquidAmbientCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Search Input in Glass Card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: LiquidGlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  borderRadius: 16,
                  child: TextField(
                    onChanged: prov.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Tìm điện thoại, phụ kiện...',
                      hintStyle: TextStyle(
                        color: AppColors.inkMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.inkMuted,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),

              // Sorting Chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildSortPill(
                      context,
                      label: 'Bán chạy nhất',
                      selected: prov.sortOption == ProductSortOption.bestSelling,
                      onTap: () =>
                          prov.setSortOption(ProductSortOption.bestSelling),
                    ),
                    const SizedBox(width: 8),
                    _buildSortPill(
                      context,
                      label: 'Mới nhất',
                      selected: prov.sortOption == ProductSortOption.newest,
                      onTap: () => prov.setSortOption(ProductSortOption.newest),
                    ),
                    const SizedBox(width: 8),
                    _buildSortPill(
                      context,
                      label: 'Giá thấp đến cao',
                      selected: prov.sortOption == ProductSortOption.priceAsc,
                      onTap: () => prov.setSortOption(ProductSortOption.priceAsc),
                    ),
                    const SizedBox(width: 8),
                    _buildSortPill(
                      context,
                      label: 'Giá cao đến thấp',
                      selected: prov.sortOption == ProductSortOption.priceDesc,
                      onTap: () =>
                          prov.setSortOption(ProductSortOption.priceDesc),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Product List
              Expanded(
                child: prov.isLoading && products.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: ProductSkeleton(),
                      )
                    : products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.inkFaint,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Không tìm thấy sản phẩm phù hợp bộ lọc.',
                              style: TextStyle(
                                color: AppColors.inkSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () => prov.applyFilters(clearAll: true),
                              child: const Text(
                                'Xóa toàn bộ bộ lọc',
                                style: TextStyle(
                                  color: AppColors.brand700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isCompared = prov.comparedProductIds.contains(
                            product.id,
                          );

                          return LiquidGlassCard(
                            padding: const EdgeInsets.all(12),
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
                                  width: 80,
                                  height: 84,
                                  child: Center(
                                    child: RepaintBoundary(
                                      child: ProductImage(
                                        productId: product.id,
                                        fallbackUrl: product.thumbnailUrl,
                                        heroTag: ProductImage.heroTagFor(
                                          product.id,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ProductDisplay.shortName(product.name),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${product.ratingAvg} ★ · Đã bán ${product.soldCount}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            CurrencyFormatter.formatVnd(
                                              product.priceFromVnd,
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              prov.toggleCompareProduct(
                                                product.id,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  action: SnackBarAction(
                                                    label: 'Xem so sánh',
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).push(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              const ComparePhonesScreen(),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  content: Text(
                                                    isCompared
                                                        ? 'Đã bỏ ${ProductDisplay.shortName(product.name)} khỏi so sánh'
                                                        : 'Đã thêm vào danh sách so sánh!',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isCompared
                                                    ? AppColors.brand700
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: AppColors.brand700,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isCompared
                                                        ? Icons.check_rounded
                                                        : Icons
                                                            .compare_arrows_rounded,
                                                    size: 13,
                                                    color: isCompared
                                                        ? Colors.white
                                                        : AppColors.brand700,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isCompared
                                                        ? 'Đã chọn'
                                                        : 'So sánh',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: isCompared
                                                        ? Colors.white
                                                        : AppColors.brand700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
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
    );
  }

  Widget _buildSortPill(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand700 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.brand700 : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
