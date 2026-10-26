import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ lọc nâng cao (F07)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          prov.applyFilters(clearAll: true);
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Đặt lại'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mức giá tối đa:',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả mức giá'),
                        selected: selectedMaxPrice == null,
                        onSelected: (_) =>
                            setModalState(() => selectedMaxPrice = null),
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
                  const SizedBox(height: 12),
                  const Text(
                    'Dung lượng RAM:',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
                  const SizedBox(height: 12),
                  const Text(
                    'Bộ nhớ trong (ROM):',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Chỉ hiện còn hàng'),
                    value: onlyInStock,
                    onChanged: (value) =>
                        setModalState(() => onlyInStock = value),
                  ),
                  LmTintedButton(
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
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục & Tìm kiếm (F05–F08)'),
        actions: [
          IconButton(
            tooltip: 'Bộ lọc nâng cao (F07)',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: prov.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên máy, hãng, model (F06)...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          // Thanh sắp xếp (F08)
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('Bán chạy nhất'),
                  selected: prov.sortOption == ProductSortOption.bestSelling,
                  onSelected: (_) =>
                      prov.setSortOption(ProductSortOption.bestSelling),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Mới nhất'),
                  selected: prov.sortOption == ProductSortOption.newest,
                  onSelected: (_) =>
                      prov.setSortOption(ProductSortOption.newest),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Giá tăng dần ↑'),
                  selected: prov.sortOption == ProductSortOption.priceAsc,
                  onSelected: (_) =>
                      prov.setSortOption(ProductSortOption.priceAsc),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Giá giảm dần ↓'),
                  selected: prov.sortOption == ProductSortOption.priceDesc,
                  onSelected: (_) =>
                      prov.setSortOption(ProductSortOption.priceDesc),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.textFaint,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Không tìm thấy sản phẩm phù hợp bộ lọc.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => prov.applyFilters(clearAll: true),
                          child: const Text('Xóa toàn bộ bộ lọc'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isCompared = prov.comparedProductIds.contains(
                        product.id,
                      );

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
                              width: 72,
                              child: PhoneStudioIllustration(
                                brandId: product.brandId,
                                categoryId: product.categoryId,
                                productName: product.name,
                                colorHex: product.defaultColorHex,
                                height: 84,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      LmStatusPill(
                                        text: product.brandId,
                                        color: accent,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '⭐ ${product.ratingAvg}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.condition,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
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
                                        style: TextStyle(
                                          color: accent,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          prov.toggleCompareProduct(product.id);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              action: SnackBarAction(
                                                label: 'Xem so sánh',
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const ComparePhonesScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                              content: Text(
                                                'Đã cập nhật danh sách so sánh (${prov.comparedProductIds.length} máy)',
                                              ),
                                            ),
                                          );
                                        },
                                        child: LmStatusPill(
                                          text: isCompared
                                              ? 'Đang so sánh'
                                              : '+ So sánh',
                                          color: isCompared
                                              ? AppColors.success
                                              : AppColors.textSecondary,
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
    );
  }
}
