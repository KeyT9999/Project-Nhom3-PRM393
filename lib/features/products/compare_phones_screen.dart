import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';

class ComparePhonesScreen extends StatelessWidget {
  const ComparePhonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final smartphones = prov.allProducts
        .where((p) => p.isActive && p.categoryId == 'smartphones')
        .toList();

    final List<ProductModel> compared = prov.comparedProducts.isNotEmpty
        ? prov.comparedProducts
        : smartphones.take(3).toList();

    // Tổng hợp động toàn bộ các trường thông số kỹ thuật từ các máy đang so sánh
    final List<String> dynamicSpecKeys = <String>{
      for (final p in compared) ...p.specs.keys,
    }.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('So Sánh Cấu Hình Chi Tiết'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              prov.setComparedProducts(const [
                'iphone_16_pro_max',
                'iphone_16_pro',
                'iphone_16_plus',
                'iphone_16',
              ]);
            },
            icon: Icon(Icons.auto_awesome_rounded, size: 16, color: accent),
            label: Text(
              'iPhone 16 Series',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        ],
      ),
      body: LiquidAmbientCanvas(
        animate: true,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            physics: const BouncingScrollPhysics(),
            children: [
              const Text(
                'SO SÁNH ĐA THƯƠNG HIỆU (TỐI ĐA 4 MÁY)',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chiếc Flagship Nào Hợp Nhất Với Bạn?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chọn nhanh các mẫu máy bên dưới và vuốt ngang để đối chiếu trực tiếp thông số kỹ thuật.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Thanh chọn nhanh sản phẩm cần so sánh (Apple, Samsung, Xiaomi, OPPO...)
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: smartphones.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final phone = smartphones[index];
                    final isSelected = prov.comparedProductIds.contains(
                      phone.id,
                    );
                    return GestureDetector(
                      onTap: () => prov.toggleCompareProduct(phone.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent
                              : Colors.white.withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected ? accent : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              size: 14,
                              color: isSelected ? Colors.white : accent,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              phone.name,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Ma trận so sánh vuốt ngang Liquid-Glass
              LiquidGlassCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 10,
                ),
                borderRadius: 22,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng thẻ đầu: Ảnh Studio, Hãng, Giá & Nút Xem Máy
                      Row(
                        children: List.generate(compared.length, (idx) {
                          final model = compared[idx];
                          final isFirst = idx == 0;
                          return Container(
                            width: 182,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isFirst ? accent : AppColors.border,
                                width: isFirst ? 1.8 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isFirst
                                            ? accent
                                            : accent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        model.brandId.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: isFirst
                                              ? Colors.white
                                              : accent,
                                        ),
                                      ),
                                    ),
                                    if (prov.comparedProductIds.length > 1)
                                      InkWell(
                                        borderRadius: BorderRadius.circular(99),
                                        onTap: () =>
                                            prov.toggleCompareProduct(model.id),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 86,
                                  child: PhoneStudioIllustration(
                                    brandId: model.brandId,
                                    categoryId: model.categoryId,
                                    productName: model.name,
                                    colorHex: model.defaultColorHex,
                                    imageUrl: model.thumbnailUrl.isNotEmpty
                                        ? model.thumbnailUrl
                                        : null,
                                    height: 84,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  model.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Từ ${CurrencyFormatter.formatVnd(model.priceFromVnd)}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFirst
                                          ? accent
                                          : Colors.white,
                                      foregroundColor: isFirst
                                          ? Colors.white
                                          : accent,
                                      side: BorderSide(color: accent),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            productId: model.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Xem Máy',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),

                      // Hàng cố định: Tùy chọn RAM / ROM & Đánh giá
                      _buildComparisonSection(
                        title: 'Tùy Chọn RAM & Bộ Nhớ ROM',
                        accent: accent,
                        values: compared.map((m) {
                          final rams = m.ramOptions
                              .where((r) => r > 0)
                              .map((r) => '${r}GB')
                              .join('/');
                          final roms = m.storageOptions
                              .where((s) => s > 0)
                              .map((s) => s >= 1024 ? '1TB' : '${s}GB')
                              .join(' • ');
                          if (rams.isEmpty && roms.isEmpty) return 'Tiêu chuẩn';
                          return 'RAM $rams\nROM $roms';
                        }).toList(),
                      ),
                      _buildComparisonSection(
                        title: 'Đánh Giá & Doanh Số',
                        accent: accent,
                        values: compared
                            .map(
                              (m) =>
                                  '⭐ ${m.ratingAvg}/5.0 (${m.reviewCount} đánh giá)\nĐã bán ${m.soldCount} máy',
                            )
                            .toList(),
                      ),

                      // Các hàng thông số kỹ thuật động từ `specs`
                      ...dynamicSpecKeys.map((key) {
                        return _buildComparisonSection(
                          title: key,
                          accent: accent,
                          values: compared
                              .map((m) => m.specs[key] ?? '—')
                              .toList(),
                        );
                      }),
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

  Widget _buildComparisonSection({
    required String title,
    required Color accent,
    required List<String> values,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8, left: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: values.map((val) {
              return Container(
                width: 182,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  val,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.35,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
