import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
import '../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../checkout/checkout_screen.dart';
import 'compare_phones_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  int _quantity = 1;
  int _selectedRating = 5;
  final _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prov = context.read<ProductProvider>();
    final prod = await prov.repository.getProductById(widget.productId);
    if (!mounted) return;
    setState(() => _product = prod);
    await prov.loadVariantsForProduct(widget.productId);
  }

  Future<void> _submitReview() async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final prodProv = context.read<ProductProvider>();

    await prodProv.submitReview(
      productId: widget.productId,
      userId: auth.activeUserId,
      userName: auth.currentUser?.name ?? 'Khách hàng SmartStore',
      rating: _selectedRating,
      comment: text,
    );

    _reviewController.clear();
    final updated = await prodProv.repository.getProductById(widget.productId);
    if (!mounted) return;
    setState(() => _product = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cảm ơn bạn đã gửi đánh giá sản phẩm (F22)!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final productProvider = context.watch<ProductProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final selectedVariant = productProvider.selectedVariant;
    final variants = productProvider.currentVariants;
    final accent = Theme.of(context).colorScheme.primary;

    if (product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isFav = wishlistProvider.isFavorite(product.id);
    final reviews = productProvider.getReviewsForProduct(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            tooltip: 'So sánh cấu hình',
            icon: const Icon(Icons.compare_arrows_rounded),
            onPressed: () {
              productProvider.toggleCompareProduct(product.id);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComparePhonesScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Yêu thích (F12)',
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.error : AppColors.ink,
            ),
            onPressed: () => wishlistProvider.toggleFavorite(product.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // 1. Studio Gallery Card trên nền trắng chuẩn UI DESIGN
          LmMaterialCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                PhoneStudioIllustration(
                  brandId: product.brandId,
                  categoryId: product.categoryId,
                  productName: product.name,
                  colorHex:
                      selectedVariant?.colorHex ?? product.defaultColorHex,
                  height: 170,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    LmStatusPill(
                      text: product.condition,
                      color: accent,
                      icon: Icons.verified_outlined,
                    ),
                    LmStatusPill(
                      text:
                          '⭐ ${product.ratingAvg} (${product.reviewCount} đánh giá)',
                      color: const Color(0xFFD97706),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Giá bán, SKU & Tồn kho theo biến thể đang chọn (F09, F10)
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                if (selectedVariant != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.formatVnd(selectedVariant.priceVnd),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                      LmStatusPill(
                        text: selectedVariant.isInStock
                            ? 'Còn hàng: ${selectedVariant.stock} máy'
                            : 'Tạm hết hàng (0 máy)',
                        color: selectedVariant.isInStock
                            ? AppColors.success
                            : AppColors.error,
                        icon: selectedVariant.isInStock
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mã SKU: ${selectedVariant.sku} • Phiên bản: ${selectedVariant.label}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const Divider(height: 24),
                const Text(
                  'Chọn phiên bản Màu sắc & Dung lượng (F10):',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: variants.map((variant) {
                    final isSelected = selectedVariant?.id == variant.id;
                    final dotColor = AppColors.fromHex(variant.colorHex);
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        productProvider.selectVariant(variant);
                        setState(
                          () => _quantity = variant.stock > 0
                              ? _quantity.clamp(1, variant.stock)
                              : 1,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent.withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? accent : AppColors.border,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black26,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  variant.label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  '${CurrencyFormatter.formatVnd(variant.priceVnd)} • Kho: ${variant.stock}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: variant.isInStock
                                        ? AppColors.textSecondary
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      'Số lượng mua:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          (selectedVariant != null &&
                              _quantity < selectedVariant.stock)
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Chính sách bảo hành & Mô tả (F09)
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 20, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.warrantyPolicy,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22),
                const Text(
                  'Thông số kỹ thuật chi tiết:',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                ...product.specs.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 115,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 22),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Đánh giá sản phẩm & Chấm sao (F22)
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đánh giá khách hàng (${reviews.length}) • F22',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Chấm sao:', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) {
                      final star = index + 1;
                      return InkWell(
                        onTap: () => setState(() => _selectedRating = star),
                        child: Icon(
                          star <= _selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 26,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _reviewController,
                        decoration: const InputDecoration(
                          hintText: 'Viết nhận xét của bạn về sản phẩm...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _submitReview,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
                if (reviews.isNotEmpty) ...[
                  const Divider(height: 24),
                  ...reviews.map(
                    (rev) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rev.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '⭐' * rev.rating,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            rev.comment,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      (selectedVariant == null ||
                          !selectedVariant.isInStock ||
                          context.watch<AuthProvider>().isOfflineSimulated)
                      ? null
                      : () async {
                          await context.read<CartProvider>().addVariantToCart(
                            product: product,
                            variant: selectedVariant,
                            quantity: _quantity,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã lưu $_quantity x "${product.name} (${selectedVariant.label})" vào cart.json!',
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Thêm vào giỏ'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LmTintedButton(
                  label: selectedVariant != null && selectedVariant.isInStock
                      ? 'Mua ngay'
                      : 'Tạm hết hàng',
                  icon: Icons.flash_on_rounded,
                  onPressed:
                      (selectedVariant == null || !selectedVariant.isInStock)
                      ? null
                      : () async {
                          await context.read<CartProvider>().addVariantToCart(
                            product: product,
                            variant: selectedVariant,
                            quantity: _quantity,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
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
}
