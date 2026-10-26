import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import 'product_detail_screen.dart';

class ComparePhonesScreen extends StatelessWidget {
  const ComparePhonesScreen({super.key});

  static const List<Map<String, dynamic>> _models = [
    {
      'id': 'iphone_16_pro_max',
      'name': '16 Pro Max',
      'fullName': 'iPhone 16 Pro Max',
      'price': 'Từ 34.990.000 ₫',
      'image': 'assets/images/lineup_16_promax.jpg',
      'highlight': 'FLAGSHIP',
      'specs': {
        'Màn Hình & Tần Số Quét': '6.9" Super Retina XDR\nProMotion 120Hz Always-On',
        'Chip Xử Lý & GPU': 'Apple A18 Pro (3nm)\nGPU 6 lõi Ray Tracing',
        'Hệ Thống Camera': '3 Camera Pro 48MP\nFusion + Ultra Wide 48MP\n+ Telephoto 5x',
        'Nút Điều Khiển Camera': 'Có (Cảm ứng lực & trượt)',
        'Thời Lượng Xem Video': 'Lên đến 33 giờ\n(Kỷ lục pin tốt nhất)',
        'Chất Liệu Khung Viền': 'Titan cấp 5 hàng không',
        'Cổng Kết Nối & Tốc Độ': 'USB-C (USB 3 - 10Gb/s)',
      },
    },
    {
      'id': 'iphone_16_pro',
      'name': '16 Pro',
      'fullName': 'iPhone 16 Pro',
      'price': 'Từ 28.990.000 ₫',
      'image': 'assets/images/lineup_16_pro.jpg',
      'highlight': 'PRO COMPACT',
      'specs': {
        'Màn Hình & Tần Số Quét': '6.3" Super Retina XDR\nProMotion 120Hz Always-On',
        'Chip Xử Lý & GPU': 'Apple A18 Pro (3nm)\nGPU 6 lõi Ray Tracing',
        'Hệ Thống Camera': '3 Camera Pro 48MP\nFusion + Ultra Wide 48MP\n+ Telephoto 5x',
        'Nút Điều Khiển Camera': 'Có (Cảm ứng lực & trượt)',
        'Thời Lượng Xem Video': 'Lên đến 27 giờ',
        'Chất Liệu Khung Viền': 'Titan cấp 5 hàng không',
        'Cổng Kết Nối & Tốc Độ': 'USB-C (USB 3 - 10Gb/s)',
      },
    },
    {
      'id': 'iphone_16_plus',
      'name': '16 Plus',
      'fullName': 'iPhone 16 Plus',
      'price': 'Từ 25.990.000 ₫',
      'image': 'assets/images/lineup_16_plus.jpg',
      'highlight': 'MÀN HÌNH LỚN',
      'specs': {
        'Màn Hình & Tần Số Quét': '6.7" Super Retina XDR\nTần số quét chuẩn 60Hz',
        'Chip Xử Lý & GPU': 'Apple A18 (3nm)\nGPU 5 lõi',
        'Hệ Thống Camera': 'Camera Kép 48MP\nFusion + Ultra Wide 12MP (2x)',
        'Nút Điều Khiển Camera': 'Có (Cảm ứng lực & trượt)',
        'Thời Lượng Xem Video': 'Lên đến 27 giờ',
        'Chất Liệu Khung Viền': 'Nhôm chuẩn hàng không',
        'Cổng Kết Nối & Tốc Độ': 'USB-C (USB 2 - 480Mb/s)',
      },
    },
    {
      'id': 'iphone_16',
      'name': 'iPhone 16',
      'fullName': 'iPhone 16',
      'price': 'Từ 21.990.000 ₫',
      'image': 'assets/images/lineup_16_standard.jpg',
      'highlight': 'TIÊU CHUẨN',
      'specs': {
        'Màn Hình & Tần Số Quét': '6.1" Super Retina XDR\nTần số quét chuẩn 60Hz',
        'Chip Xử Lý & GPU': 'Apple A18 (3nm)\nGPU 5 lõi',
        'Hệ Thống Camera': 'Camera Kép 48MP\nFusion + Ultra Wide 12MP (2x)',
        'Nút Điều Khiển Camera': 'Có (Cảm ứng lực & trượt)',
        'Thời Lượng Xem Video': 'Lên đến 22 giờ',
        'Chất Liệu Khung Viền': 'Nhôm chuẩn hàng không',
        'Cổng Kết Nối & Tốc Độ': 'USB-C (USB 2 - 480Mb/s)',
      },
    },
  ];

  static const List<String> _specKeys = [
    'Màn Hình & Tần Số Quét',
    'Chip Xử Lý & GPU',
    'Hệ Thống Camera',
    'Nút Điều Khiển Camera',
    'Thời Lượng Xem Video',
    'Chất Liệu Khung Viền',
    'Cổng Kết Nối & Tốc Độ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('So Sánh Cấu Hình iPhone 16'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LiquidAmbientCanvas(
        animate: true,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              // Header title group
              const Text(
                'SO SÁNH CẤU HÌNH CHI TIẾT',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'iPhone Nào Phù Hợp Nhất Với Bạn?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Vuốt ngang để đối chiếu trực tiếp thông số 4 phiên bản thế hệ mới.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Scroll Matrix in Liquid-Glass
              LiquidGlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                borderRadius: 22,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: 4 Phone Cards with Real Image, Price & CTA
                      Row(
                        children: _models.map((model) {
                          return Container(
                            width: 175,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: model['id'] == 'iphone_16_pro_max'
                                    ? AppColors.brand700
                                    : AppColors.border,
                                width: model['id'] == 'iphone_16_pro_max'
                                    ? 1.8
                                    : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: model['id'] == 'iphone_16_pro_max'
                                        ? AppColors.brand700
                                        : AppColors.brand50,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    model['highlight'] as String,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: model['id'] == 'iphone_16_pro_max'
                                          ? Colors.white
                                          : AppColors.brand700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Phone Image
                                SizedBox(
                                  height: 85,
                                  child: Image.asset(
                                    model['image'] as String,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.phone_iphone_rounded,
                                      size: 60,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  model['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  model['price'] as String,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brand700,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // CTA Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          model['id'] == 'iphone_16_pro_max'
                                              ? AppColors.brand700
                                              : Colors.white,
                                      foregroundColor:
                                          model['id'] == 'iphone_16_pro_max'
                                              ? Colors.white
                                              : AppColors.brand700,
                                      side: const BorderSide(
                                        color: AppColors.brand700,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            productId: model['id'] as String,
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
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Specification Matrix Rows
                      ..._specKeys.map((key) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Parameter Section Title
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.brand50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brand700,
                                  ),
                                ),
                              ),

                              // Value Cells for each model
                              Row(
                                children: _models.map((model) {
                                  final specs =
                                      model['specs'] as Map<String, String>;
                                  final val = specs[key] ?? '—';
                                  final isProMax =
                                      model['id'] == 'iphone_16_pro_max';

                                  return Container(
                                    width: 175,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isProMax
                                          ? AppColors.brand50.withValues(alpha: 0.7)
                                          : Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isProMax
                                            ? AppColors.brand300
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      val,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isProMax
                                            ? FontWeight.w700
                                            : FontWeight.w500,
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
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Advice Card
              LiquidGlassDarkCard(
                padding: const EdgeInsets.all(18),
                borderRadius: 20,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4C8B8),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brand900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chuyên gia Apple tư vấn',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Nếu bạn cần màn hình 6.9" lớn nhất và pin 33H, hãy chọn 16 Pro Max. Nếu thích máy gọn nhẹ trong lòng bàn tay, 16 Pro là lựa chọn hoàn hảo.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              height: 1.35,
                            ),
                          ),
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
    );
  }
}
