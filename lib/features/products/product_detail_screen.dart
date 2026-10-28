import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/product_display.dart';
import '../../core/widgets/product_skeleton.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/models/product_model.dart';
import '../../data/models/variant_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../checkout/checkout_screen.dart';
import 'product_gallery.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  String? _selectedVariantId;
  int _quantity = 1;
  int _selectedRating = 5;
  String _selectedFinishKey = 'desert';
  String _selectedStorageKey = '256GB';
  final _reviewController = TextEditingController();

  /// Suy ra khóa màu Titan từ tên màu của biến thể (null nếu không phải Titan).
  static String? _finishKeyOf(String? color) {
    if (color == null) return null;
    if (color.contains('Sa Mạc')) return 'desert';
    if (color.contains('Tự Nhiên')) return 'natural';
    if (color.contains('Trắng')) return 'white';
    if (color.contains('Đen')) return 'black';
    return null;
  }

  /// Chọn màu: chuyển sang biến thể cùng màu, ưu tiên cùng dung lượng.
  void _selectFinish(
    ProductProvider prov,
    List<VariantModel> variants,
    VariantModel? current,
    String key,
  ) {
    final matches =
        variants.where((v) => _finishKeyOf(v.color) == key).toList();
    if (matches.isEmpty) return;
    final target = matches.firstWhere(
      (v) => v.storageGB == current?.storageGB,
      orElse: () => matches.first,
    );
    prov.selectVariant(target);
    setState(() {
      _selectedFinishKey = key;
      _selectedVariantId = target.id;
    });
  }

  static const Map<String, String> _finishNames = {
    'desert': 'Titan Sa Mạc (Desert Titanium)',
    'natural': 'Titan Tự Nhiên (Natural Titanium)',
    'white': 'Titan Trắng (White Titanium)',
    'black': 'Titan Đen (Black Titanium)',
  };

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

    // Synchronize initial variant
    if (prov.selectedVariant != null) {
      final v = prov.selectedVariant!;
      if (v.storageGB > 0) {
        _selectedStorageKey = v.storageGB >= 1024 ? '1TB' : '${v.storageGB}GB';
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

    final finishKey =
        _finishKeyOf(selectedVariant?.color) ?? _selectedFinishKey;

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: ProductSkeleton(count: 3),
        ),
      );
    }

    final isFav = wishlistProvider.isFavorite(product.id);
    final reviews = productProvider.getReviewsForProduct(product.id);
    final currentPrice = selectedVariant?.priceVnd ?? product.priceFromVnd;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LiquidAmbientCanvas(
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
                        ProductDisplay.shortName(product.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Chia sẻ sản phẩm',
                      icon: const Icon(Icons.share_outlined),
                      color: AppColors.brand700,
                      onPressed: () {
                        final priceText = CurrencyFormatter.formatVnd(
                          selectedVariant?.priceVnd ?? product.priceFromVnd,
                        );
                        SharePlus.instance.share(
                          ShareParams(
                            text:
                                '${ProductDisplay.shortName(product.name)} (${selectedVariant?.label ?? 'Chính hãng VN/A'})\n'
                                'Giá tại SmartStore: $priceText\n'
                                'Đánh giá: ${product.ratingAvg}/5.0 (${product.reviewCount} lượt)\n'
                                'Xem trên ứng dụng SmartStore',
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Yêu thích',
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.error : AppColors.brand700,
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
                                  color: AppColors.brand50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.brand200),
                                ),
                                child: Text(
                                  product.condition,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brand700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Real Studio Product Image
                          Center(
                            child: ProductGallery(
                              productId: product.id,
                              fallbackUrl: product.thumbnailUrl.isNotEmpty
                                  ? product.thumbnailUrl
                                  : (selectedVariant?.imageUrls.isNotEmpty ?? false)
                                      ? selectedVariant!.imageUrls.first
                                      : null,
                              height: 280,
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
                                'Đã bán ${product.soldCount} máy',
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
                                  ProductDisplay.shortName(product.name),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatVnd(currentPrice),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
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
                                      ? 'Còn hàng: ${selectedVariant?.stock ?? 45} máy'
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

                          // Màu Titan chỉ áp dụng cho iPhone 16 Pro
                          if (product.id.startsWith('iphone_16_pro')) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedVariant?.color ?? _finishNames[finishKey] ?? 'Màu sắc titan',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                              Row(
                                children: [
                                  for (final f in const [
                                    ('desert', 'Titan Sa Mạc', AppColors.desertTitanium),
                                    ('natural', 'Titan Tự Nhiên', AppColors.naturalTitanium),
                                    ('white', 'Titan Trắng', AppColors.whiteTitanium),
                                    ('black', 'Titan Đen', AppColors.blackTitanium),
                                  ])
                                    if (variants.isEmpty ||
                                        variants.any(
                                          (v) => _finishKeyOf(v.color) == f.$1,
                                        ))
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: TitaniumFinishDot(
                                          finishKey: f.$1,
                                          label: f.$2,
                                          color: f.$3,
                                          isSelected: finishKey == f.$1,
                                          onSelected: () => _selectFinish(
                                            productProvider,
                                            variants,
                                            selectedVariant,
                                            f.$1,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ],

                          // Storage Options Pills
                          Text(
                            product.categoryId.toLowerCase().contains('accessor')
                                ? 'Phiên bản:'
                                : 'Dung lượng bộ nhớ:',
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
                                final isSelected = selectedVariant?.id == variant.id;
                                return GestureDetector(
                                  onTap: () {
                                    productProvider.selectVariant(variant);
                                    setState(() {
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
                                          ? AppColors.brand700
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.brand700
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
                            )
                          else
                            Row(
                              children: [
                                StorageCapacityPill(
                                  capacity: '256GB',
                                  isSelected: _selectedStorageKey == '256GB',
                                  onSelected: () =>
                                      setState(() => _selectedStorageKey = '256GB'),
                                ),
                                const SizedBox(width: 8),
                                StorageCapacityPill(
                                  capacity: '512GB',
                                  isSelected: _selectedStorageKey == '512GB',
                                  onSelected: () =>
                                      setState(() => _selectedStorageKey = '512GB'),
                                ),
                                const SizedBox(width: 8),
                                StorageCapacityPill(
                                  capacity: '1TB',
                                  isSelected: _selectedStorageKey == '1TB',
                                  onSelected: () =>
                                      setState(() => _selectedStorageKey = '1TB'),
                                ),
                              ],
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
                                  borderRadius: BorderRadius.circular(8),
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
                                  backgroundColor: AppColors.brand700,
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
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
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
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brand700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Nút icon Giỏ hàng tròn nhỏ (44x44) chuẩn Apple Store
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brand700.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: IconButton(
                      tooltip: 'Thêm vào giỏ hàng',
                      icon: const Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 19,
                        color: AppColors.brand700,
                      ),
                      onPressed: (selectedVariant != null &&
                              !selectedVariant.isInStock)
                          ? null
                          : () async {
                              final variantToUse = selectedVariant ??
                                  VariantModel(
                                    id: '${product.id}_std',
                                    sku: '${product.id.toUpperCase()}-STD',
                                    color: _finishNames[_selectedFinishKey] ??
                                        'Titan',
                                    colorHex: product.defaultColorHex,
                                    ramGB: product.ramOptions.firstOrNull ?? 8,
                                    storageGB: 256,
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

                  // Nút Mua Ngay viên thuốc lớn chuẩn Apple
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
                              final variantToUse = selectedVariant ??
                                  VariantModel(
                                    id: '${product.id}_std',
                                    sku: '${product.id.toUpperCase()}-STD',
                                    color: _finishNames[_selectedFinishKey] ??
                                        'Titan',
                                    colorHex: product.defaultColorHex,
                                    ramGB: product.ramOptions.firstOrNull ?? 8,
                                    storageGB: 256,
                                    priceVnd: currentPrice,
                                    stock: 45,
                                  );

                              try {
                                await context.read<CartProvider>().addVariantToCart(
                                  product: product,
                                  variant: variantToUse,
                                  quantity: _quantity,
                                );
                              } catch (_) {}
                              if (!context.mounted) return;
                              if (auth.isOfflineSimulated) {
                                showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Đang ở chế độ Offline'),
                                    content: const Text(
                                      'Sản phẩm đã được lưu vào giỏ hàng trên máy.\n\nVui lòng bật lại kết nối mạng để tiếp tục bước Thanh toán (Checkout).',
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
