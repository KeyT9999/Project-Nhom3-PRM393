import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../core/widgets/phone_studio_illustration.dart';
import '../../providers/product_provider.dart';

class ComparePhonesScreen extends StatelessWidget {
  const ComparePhonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final compared = prov.comparedProducts;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('So sánh cấu hình điện thoại')),
      body: compared.isEmpty
          ? const Center(
              child: Text(
                'Chưa có sản phẩm nào trong danh sách so sánh.\nHãy chọn "+ So sánh" tại Danh mục hoặc Chi tiết sản phẩm.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: compared.map((product) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: LmMaterialCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () =>
                                      prov.toggleCompareProduct(product.id),
                                  child: const Icon(Icons.close, size: 18),
                                ),
                              ),
                              PhoneStudioIllustration(
                                brandId: product.brandId,
                                productName: product.name,
                                colorHex: product.defaultColorHex,
                                height: 85,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.formatVnd(
                                  product.priceFromVnd,
                                ),
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                LmMaterialCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bảng đối chiếu thông số kỹ thuật',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildSpecRow(
                        'Thương hiệu',
                        compared.map((p) => p.brandId).toList(),
                      ),
                      _buildSpecRow(
                        'Màn hình',
                        compared
                            .map((p) => p.specs['Màn hình'] ?? 'Đang cập nhật')
                            .toList(),
                      ),
                      _buildSpecRow(
                        'Chip xử lý',
                        compared
                            .map(
                              (p) => p.specs['Chip xử lý'] ?? 'Đang cập nhật',
                            )
                            .toList(),
                      ),
                      _buildSpecRow(
                        'Camera',
                        compared
                            .map((p) => p.specs['Camera'] ?? 'Đang cập nhật')
                            .toList(),
                      ),
                      _buildSpecRow(
                        'Pin & Sạc',
                        compared
                            .map(
                              (p) =>
                                  p.specs['Pin & Sạc'] ??
                                  p.specs['Pin'] ??
                                  'Đang cập nhật',
                            )
                            .toList(),
                      ),
                      _buildSpecRow(
                        'Đánh giá',
                        compared
                            .map((p) => '⭐ ${p.ratingAvg} (${p.reviewCount})')
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSpecRow(String label, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: values.map((val) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    val,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
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
