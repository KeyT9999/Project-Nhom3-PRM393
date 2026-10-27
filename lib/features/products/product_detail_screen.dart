import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
import '../../data/models/product_model.dart';
import '../../data/models/variant_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../checkout/checkout_screen.dart';
import 'compare_phones_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final int? initialStorageGB;
  final String? initialColorKeyword;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialStorageGB,
    this.initialColorKeyword,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  String? _selectedVariantId;
  int _quantity = 1;
  int _selectedRating = 5;
  final _reviewController = TextEditingController();

  String _brandHighlightLabel(ProductModel product) {
    if (product.categoryId == 'accessories') {
      return '✓ Phụ Kiện Chính Hãng';
    }
    switch (product.brandId.toLowerCase()) {
      case 'apple':
        return ' Apple Intelligence';
      case 'samsung':
        return '✦ Galaxy AI';
      case 'xiaomi':
        return '⚡ HyperOS AI';
      case 'oppo':
        return '✦ OPPO AI';
      default:
        return '✓ Chính Hãng VN/A';
    }
  }

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
    await prov.loadVariantsForProduct(widget.productId);
    if (!mounted) return;

    final loadedVariants = prov.currentVariants;
    if (loadedVariants.isNotEmpty &&
        (widget.initialStorageGB != null ||
            widget.initialColorKeyword != null)) {
      final kw = widget.initialColorKeyword?.toLowerCase();
      VariantModel? matched;
      for (final v in loadedVariants) {
        final storageOk =
            widget.initialStorageGB == null ||
            v.storageGB == widget.initialStorageGB;
        final colorOk =
            kw == null ||
            v.color.toLowerCase().contains(kw) ||
            v.id.toLowerCase().contains(kw);
        if (storageOk && colorOk) {
          matched = v;
          break;
        }
      }
      matched ??= loadedVariants
          .where(
            (v) =>
                widget.initialStorageGB != null &&
                v.storageGB == widget.initialStorageGB,
          )
          .firstOrNull;
      matched ??= loadedVariants
          .where(
            (v) =>
                kw != null &&
                (v.color.toLowerCase().contains(kw) ||
                    v.id.toLowerCase().contains(kw)),
          )
          .firstOrNull;
      if (matched != null) {
        prov.selectVariant(matched);
      }
    }

    setState(() {
      _product = prod;
      _selectedVariantId = prov.selectedVariant?.id;
    });
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
        content: Text('Cảm ơn bạn đã gửi đánh giá sản phẩm!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final productProvider = context.watch<ProductProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final variants = productProvider.currentVariants.isNotEmpty
        ? productProvider.currentVariants
        : (product != null
            ? productProvider.repository.getCachedVariants(product.id)
            : <VariantModel>[]);
    final selectedVariant = productProvider.selectedVariant ??
        (variants.isEmpty
            ? null
            : variants.firstWhere(
                (v) => v.id == _selectedVariantId,
                orElse: () => variants.firstWhere(
                  (v) => v.isInStock,
                  orElse: () => variants.first,
                ),
              ));

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.brand700),
        ),
      );
    }

    final accent = Theme.of(context).colorScheme.primary;
    final isFav = wishlistProvider.isFavorite(product.id);
    final reviews = productProvider.getReviewsForProduct(product.id);
    final currentPrice = selectedVariant?.priceVnd ?? product.priceFromVnd;
    final isApplePhone =
        product.brandId.toLowerCase() == 'apple' &&
        product.categoryId == 'smartphones';
    final unitWord = product.categoryId == 'accessories' ? 'sản phẩm' : 'máy';

    // Trích xuất danh sách màu duy nhất từ các biến thể thực tế của sản phẩm
    final Map<String, VariantModel> uniqueColorVariants = {};
    for (final v in variants) {
      uniqueColorVariants.putIfAbsent(v.color, () => v);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LiquidAmbientCanvas(
        animate: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Transparent App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      color: AppColors.ink,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Chia sẻ sản phẩm',
                      icon: const Icon(Icons.share_outlined),
                      color: accent,
                      onPressed: () {
                        final priceText = CurrencyFormatter.formatVnd(
                          selectedVariant?.priceVnd ?? product.priceFromVnd,
                        );
                        SharePlus.instance.share(
                          ShareParams(
                            text:
                                '📱 ${product.name} (${selectedVariant?.label ?? 'Chính hãng VN/A'})\n'
                                '💰 Giá ưu đãi tại SmartStore: $priceText\n'
                                '⭐ Đánh giá: ${product.ratingAvg}/5.0 (${product.reviewCount} lượt)\n'
                                '👉 Đặt mua ngay trên ứng dụng SmartStore!',
                          ),
                        );
                      },
                    ),
                    if (product.categoryId == 'smartphones')
                      IconButton(
                        tooltip: 'So sánh cấu hình',
                        icon: const Icon(Icons.compare_arrows_rounded),
                        color: accent,
                        onPressed: () {
                          productProvider.toggleCompareProduct(product.id);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ComparePhonesScreen(),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      tooltip: 'Yêu thích (F12)',
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.error : accent,
                      ),
                      onPressed: () => wishlistProvider.toggleFavorite(product.id),
                    ),
                  ],
                ),
              ),

              // Main Scroll Content
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    // 1. Hero Product Gallery Stage in Liquid Glass
                    LiquidGlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  product.condition,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
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
                                child: Text(
                                  _brandHighlightLabel(product),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0071E3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Real Studio Product Image
                          Center(
                            child: Hero(
                              tag: 'product_img_${product.id}',
                              child: PhoneStudioIllustration(
                                brandId: product.brandId,
                                categoryId: product.categoryId,
                                productName: product.name,
                                colorHex: selectedVariant?.colorHex ??
                                    product.defaultColorHex,
                                imageUrl: product.thumbnailUrl.isNotEmpty
                                    ? product.thumbnailUrl
                                    : null,
                                height: 210,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating and Sold Count Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 17,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.ratingAvg} (${product.reviewCount} đánh giá)',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.inkMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Đã bán ${product.soldCount} $unitWord',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Interactive Finish & Capacity Selectors (F10)
                    LiquidGlassCard(
                      padding: const EdgeInsets.all(18),
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatVnd(currentPrice),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Stock and SKU
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (selectedVariant?.isInStock ?? true)
                                      ? AppColors.successSoft
                                      : AppColors.errorSoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (selectedVariant?.isInStock ?? true)
                                      ? 'Còn hàng: ${selectedVariant?.stock ?? 45} $unitWord'
                                      : 'Tạm hết hàng',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: (selectedVariant?.isInStock ?? true)
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SKU: ${selectedVariant?.sku ?? "VN/A-2026"}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Dynamic Finish Selector Row synced directly to VariantModel
                          if (uniqueColorVariants.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Màu sắc: ${selectedVariant?.color ?? uniqueColorVariants.keys.first}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkSecondary,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  spacing: 6,
                                  children: uniqueColorVariants.entries.map((
                                    entry,
                                  ) {
                                    final colorName = entry.key;
                                    final sampleVar = entry.value;
                                    final isColorSelected =
                                        selectedVariant?.color == colorName;
                                    return TitaniumFinishDot(
                                      finishKey: colorName,
                                      label: colorName,
                                      color: AppColors.fromHex(
                                        sampleVar.colorHex,
                                      ),
                                      isSelected: isColorSelected,
                                      onSelected: () {
                                        final currentRom =
                                            selectedVariant?.storageGB;
                                        final target = variants.firstWhere(
                                          (v) =>
                                              v.color == colorName &&
                                              v.storageGB == currentRom,
                                          orElse: () => variants.firstWhere(
                                            (v) =>
                                                v.color == colorName &&
                                                v.isInStock,
                                            orElse: () => sampleVar,
                                          ),
                                        );
                                        productProvider.selectVariant(target);
                                        setState(() {
                                          _selectedVariantId = target.id;
                                          _quantity = target.stock > 0
                                              ? _quantity.clamp(1, target.stock)
                                              : 1;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Variant / Storage Options Pills
                          Text(
                            product.categoryId == 'accessories'
                                ? 'Phiên bản tùy chọn:'
                                : 'Phiên bản Màu & Bộ nhớ (SKU):',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (variants.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: variants.map((variant) {
                                final isSelected =
                                    selectedVariant?.id == variant.id;
                                return GestureDetector(
                                  onTap: () {
                                    productProvider.selectVariant(variant);
                                    setState(() {
                                      _selectedVariantId = variant.id;
                                      _quantity = variant.stock > 0
                                          ? _quantity.clamp(1, variant.stock)
                                          : 1;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? accent
                                          : Colors.white.withValues(
                                              alpha: 0.82,
                                            ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isSelected
                                            ? accent
                                            : AppColors.border,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      variant.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.ink,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: 16),

                          // Quantity Stepper
                          Row(
                            children: [
                              const Text(
                                'Số lượng:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: _quantity > 1
                                          ? () => setState(() => _quantity--)
                                          : null,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: (selectedVariant != null &&
                                              _quantity < selectedVariant.stock)
                                          ? () => setState(() => _quantity++)
                                          : null,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Camera Macro & Performance Split Banner (chỉ hiển thị cho iPhone)
                    if (isApplePhone) ...[
                      LiquidGlassCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TÍNH NĂNG ĐỘT PHÁ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.inkMuted,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Mọi Khoảnh Khắc Trong Từng Chi Tiết',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Landscape Banner Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                'assets/images/scenic_mountain_banner.jpg',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 140,
                                  color: accent,
                                  child: const Center(
                                    child: Icon(
                                      Icons.landscape_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Macro Lens Close-up with Performance Mini Cards
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/camera_macro_lens.jpg',
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 90,
                                      height: 90,
                                      color: AppColors.brand900,
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cụm Camera 48MP Fusion',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Cảm biến Quad-Pixel thế hệ 2, quay 4K 120fps Dolby Vision điện ảnh và zoom quang học sắc nét.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.inkSecondary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // 4. Specification Table
                    LiquidGlassCard(
                      padding: const EdgeInsets.all(18),
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông Số Kỹ Thuật Chi Tiết',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...product.specs.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 105,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: AppColors.inkMuted,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
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
                              color: AppColors.inkSecondary,
                              height: 1.45,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. Customer Reviews (F22)
                    LiquidGlassCard(
                      padding: const EdgeInsets.all(18),
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đánh Giá Khách Hàng (${reviews.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.ink,
                                ),
                              ),
                              const Text(
                                '★★★★★',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Rating input
                          Row(
                            children: [
                              const Text(
                                'Chấm sao:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...List.generate(5, (index) {
                                final star = index + 1;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedRating = star),
                                  child: Icon(
                                    star <= _selectedRating
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: const Color(0xFFF59E0B),
                                    size: 24,
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _reviewController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhận xét của bạn về máy...',
                                    hintStyle: const TextStyle(
                                      color: AppColors.inkMuted,
                                      fontSize: 12.5,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: accent,
                                ),
                                onPressed: _submitReview,
                                icon: const Icon(Icons.send_rounded, size: 18),
                              ),
                            ],
                          ),

                          if (reviews.isNotEmpty) ...[
                            const Divider(height: 22),
                            ...reviews.map(
                              (rev) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          rev.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                            color: AppColors.ink,
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
                                        fontSize: 12,
                                        color: AppColors.inkSecondary,
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
              ),
            ],
          ),
        ),
      ),

      // 6. Floating Liquid-Glass Bottom Bar
      bottomNavigationBar: ClipRect(
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
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng thanh toán:',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatVnd(currentPrice * _quantity),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Nút icon Giỏ hàng tròn nhỏ (44x44) chuẩn Liquid-Glass
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'Thêm vào giỏ hàng',
                      icon: Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 19,
                        color: accent,
                      ),
                      onPressed: (selectedVariant != null &&
                              !selectedVariant.isInStock)
                          ? null
                          : () async {
                              final variantToUse = selectedVariant ??
                                  VariantModel(
                                    id: '${product.id}_std',
                                    sku: '${product.id.toUpperCase()}-STD',
                                    color: 'Tiêu chuẩn',
                                    colorHex: product.defaultColorHex,
                                    ramGB: product.ramOptions.firstOrNull ?? 0,
                                    storageGB:
                                        product.storageOptions.firstOrNull ?? 0,
                                    priceVnd: currentPrice,
                                    stock: 45,
                                  );

                              try {
                                await context.read<CartProvider>().addVariantToCart(
                                  product: product,
                                  variant: variantToUse,
                                  quantity: _quantity,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã lưu $_quantity x "${product.name} (${variantToUse.label})" vào giỏ hàng!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.error,
                                    content: Text('$e'),
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Nút Mua Ngay viên thuốc lớn
                  Expanded(
                    child: LiquidPillButton(
                      label: (selectedVariant != null && !selectedVariant.isInStock)
                          ? 'Tạm hết hàng'
                          : 'Mua Ngay',
                      icon: Icons.bolt_rounded,
                      height: 44,
                      onPressed: (selectedVariant != null &&
                              !selectedVariant.isInStock)
                          ? null
                          : () async {
                              final auth = context.read<AuthProvider>();
                              final cartProv = context.read<CartProvider>();
                              final variantToUse = selectedVariant ??
                                  VariantModel(
                                    id: '${product.id}_std',
                                    sku: '${product.id.toUpperCase()}-STD',
                                    color: 'Tiêu chuẩn',
                                    colorHex: product.defaultColorHex,
                                    ramGB: product.ramOptions.firstOrNull ?? 0,
                                    storageGB:
                                        product.storageOptions.firstOrNull ?? 0,
                                    priceVnd: currentPrice,
                                    stock: 45,
                                  );

                              try {
                                await cartProv.addVariantToCart(
                                  product: product,
                                  variant: variantToUse,
                                  quantity: _quantity,
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                final alreadyInCart = cartProv.items.any(
                                  (i) => i.variantId == variantToUse.id,
                                );
                                if (!alreadyInCart) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.error,
                                      content: Text('$e'),
                                    ),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Giỏ hàng đã có sẵn số lượng tối đa của phiên bản này (${variantToUse.stock}). Chuyển tới Thanh toán!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                              if (!context.mounted) return;
                              if (auth.isOfflineSimulated) {
                                showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Đang ở chế độ Offline (F23)'),
                                    content: const Text(
                                      'Sản phẩm đã được lưu vào giỏ hàng cục bộ (cart.json).\n\nVui lòng bật lại kết nối mạng để tiếp tục bước Thanh toán (Checkout).',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('Để sau'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          auth.toggleOfflineSimulation(false);
                                          Navigator.of(ctx).pop();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CheckoutScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Bật lại mạng & Checkout',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
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
        ),
      ),
    );
  }
}
