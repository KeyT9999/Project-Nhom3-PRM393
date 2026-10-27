import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';
import '../../data/models/variant_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  void _showProductDialog(BuildContext context, {ProductModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final brandCtrl = TextEditingController(text: existing?.brandId ?? 'Apple');
    final priceCtrl = TextEditingController(
      text: existing != null ? '${existing.priceFromVnd}' : '24990000',
    );
    final descCtrl = TextEditingController(
      text:
          existing?.description ??
          'Flagship mới chính hãng VN/A bảo hành 12 tháng tại SmartStore.',
    );
    bool isActive = existing?.isActive ?? true;
    bool isFeatured = existing?.isFeatured ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null
                      ? 'Thêm sản phẩm mới'
                      : 'Cập nhật sản phẩm',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    prefixIcon: Icon(Icons.smartphone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: brandCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Hãng (Brand)',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá khởi điểm (VND)',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả sản phẩm',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isActive,
                  onChanged: (v) => setModalState(() => isActive = v),
                  title: const Text(
                    'Đang mở bán (Active)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isFeatured,
                  onChanged: (v) => setModalState(() => isFeatured = v),
                  title: const Text(
                    'Hiển thị nổi bật (Featured)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                LmTintedButton(
                  label: 'Lưu sản phẩm',
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final price =
                        int.tryParse(priceCtrl.text.trim()) ?? 19990000;
                    final id =
                        existing?.id ??
                        name.toLowerCase().replaceAll(
                          RegExp(r'[^a-z0-9]+'),
                          '_',
                        );
                    final product = ProductModel(
                      id: id,
                      name: name,
                      slug: id.replaceAll('_', '-'),
                      brandId: brandCtrl.text.trim(),
                      categoryId: existing?.categoryId ?? 'smartphones',
                      description: descCtrl.text.trim(),
                      thumbnailUrl: existing?.thumbnailUrl ?? '',
                      specs:
                          existing?.specs ??
                          const {
                            'Màn hình': '6.7" Super AMOLED 120Hz',
                            'Chip xử lý': 'Flagship Processor 3nm',
                            'Camera': '50MP OIS Pro Camera',
                            'Pin & Sạc': '5000 mAh, Sạc nhanh',
                            'Hệ điều hành': 'Phiên bản mới nhất',
                          },
                      priceFromVnd: price,
                      ramOptions: existing?.ramOptions ?? const [8, 12],
                      storageOptions:
                          existing?.storageOptions ?? const [256, 512],
                      ratingAvg: existing?.ratingAvg ?? 4.9,
                      reviewCount: existing?.reviewCount ?? 12,
                      soldCount: existing?.soldCount ?? 5,
                      isFeatured: isFeatured,
                      isActive: isActive,
                      createdAt: existing?.createdAt ?? DateTime.now(),
                    );
                    await context.read<ProductProvider>().upsertProduct(
                      product,
                    );
                    if (!context.mounted) return;
                    if (existing == null) {
                      await context.read<ProductProvider>().upsertVariant(
                        id,
                        VariantModel(
                          id: 'var_${id}_default',
                          sku: '${id.toUpperCase()}-256-BLK',
                          color: 'Black Titanium',
                          colorHex: '#3C3B37',
                          ramGB: 8,
                          storageGB: 256,
                          priceVnd: price,
                          stock: 15,
                          isActive: true,
                        ),
                      );
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVariantsSheet(BuildContext context, ProductModel product) async {
    final provider = context.read<ProductProvider>();
    await provider.loadVariantsForProduct(product.id);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<ProductProvider>(
        builder: (ctx, prodProv, _) {
          final variants = prodProv.currentVariants;
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            builder: (ctx, scrollCtrl) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quản lý biến thể SKU & Tồn kho',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink3,
                              ),
                            ),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _showEditVariantDialog(ctx, product.id),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm SKU'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollCtrl,
                      itemCount: variants.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final v = variants[index];
                        return LmMaterialCard(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.fromHex(v.colorHex),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.line),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${v.color} • ${v.ramGB}GB/${v.storageGB}GB',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SKU: ${v.sku} • ${CurrencyFormatter.formatVnd(v.priceVnd)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.ink3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              LmStatusPill(
                                text: 'Kho: ${v.stock}',
                                color: v.stock > 0
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showEditVariantDialog(
                                  ctx,
                                  product.id,
                                  existing: v,
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
          );
        },
      ),
    );
  }

  void _showEditVariantDialog(
    BuildContext context,
    String productId, {
    VariantModel? existing,
  }) {
    final skuCtrl = TextEditingController(
      text:
          existing?.sku ??
          'SKU-${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
    final colorCtrl = TextEditingController(
      text: existing?.color ?? 'Natural Titanium',
    );
    final hexCtrl = TextEditingController(
      text: existing?.colorHex ?? '#C5B9A5',
    );
    final ramCtrl = TextEditingController(text: '${existing?.ramGB ?? 8}');
    final romCtrl = TextEditingController(
      text: '${existing?.storageGB ?? 256}',
    );
    final priceCtrl = TextEditingController(
      text: '${existing?.priceVnd ?? 28990000}',
    );
    final stockCtrl = TextEditingController(text: '${existing?.stock ?? 15}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? 'Thêm SKU mới' : 'Cập nhật SKU & Tồn kho',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: skuCtrl,
                decoration: const InputDecoration(labelText: 'Mã SKU'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: colorCtrl,
                      decoration: const InputDecoration(labelText: 'Tên màu'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: hexCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mã Hex (#)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ramCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'RAM (GB)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: romCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ROM (GB)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Giá (VND)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tồn kho'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final variant = VariantModel(
                id:
                    existing?.id ??
                    'var_${DateTime.now().millisecondsSinceEpoch}',
                sku: skuCtrl.text.trim(),
                color: colorCtrl.text.trim(),
                colorHex: hexCtrl.text.trim(),
                ramGB: int.tryParse(ramCtrl.text.trim()) ?? 8,
                storageGB: int.tryParse(romCtrl.text.trim()) ?? 256,
                priceVnd: int.tryParse(priceCtrl.text.trim()) ?? 25000000,
                stock: int.tryParse(stockCtrl.text.trim()) ?? 10,
                isActive: true,
              );
              await context.read<ProductProvider>().upsertVariant(
                productId,
                variant,
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Lưu SKU'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().allProducts;
    final palette = context.watch<AuthProvider>().palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm & Biến thể SKU'),
        actions: [
          IconButton(
            onPressed: () => _showProductDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm sản phẩm',
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return LmMaterialCard(
            padding: const EdgeInsets.all(14),
            borderRadius: 18,
            child: Row(
              children: [
                SizedBox(
                  width: 68,
                  child: ProductImage(
                    productId: p.id,
                    fallbackUrl: p.thumbnailUrl,
                    padding: const EdgeInsets.all(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LmStatusPill(text: p.brandId, color: palette.primary),
                          const SizedBox(width: 6),
                          if (!p.isActive)
                            const LmStatusPill(
                              text: 'Đã ẩn',
                              color: AppColors.danger,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Từ ${CurrencyFormatter.formatVnd(p.priceFromVnd)} • Đã bán ${p.soldCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      tooltip: 'Quản lý SKU & Kho',
                      icon: Icon(
                        Icons.inventory_2_outlined,
                        color: palette.primary,
                      ),
                      onPressed: () => _showVariantsSheet(context, p),
                    ),
                    IconButton(
                      tooltip: 'Chỉnh sửa',
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showProductDialog(context, existing: p),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
