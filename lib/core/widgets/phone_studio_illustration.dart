import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Hiển thị hình ảnh Studio của Điện thoại / Phụ kiện theo đúng màu sắc biến thể (`colorHex`)
/// Hỗ trợ cả URL ảnh từ Firebase Storage lẫn hình minh họa vector Studio chất lượng cao.
class PhoneStudioIllustration extends StatelessWidget {
  final String brandId;
  final String categoryId;
  final String productName;
  final String colorHex;
  final String? imageUrl;
  final double height;

  const PhoneStudioIllustration({
    super.key,
    required this.brandId,
    this.categoryId = 'smartphones',
    required this.productName,
    this.colorHex = '#1C1C1E',
    this.imageUrl,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    final bodyColor = AppColors.fromHex(colorHex);
    final isLightColor = bodyColor.computeLuminance() > 0.72;
    final frameBorderColor = isLightColor
        ? const Color(0xFFD0D5DD)
        : Colors.white.withValues(alpha: 0.22);

    final assetPath = _resolveAssetPath();

    if (imageUrl != null && imageUrl!.startsWith('assets/')) {
      return SizedBox(
        height: height,
        child: Image.asset(
          imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              _buildStudioVector(bodyColor, frameBorderColor),
        ),
      );
    }

    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return SizedBox(
        height: height,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.contain,
          placeholder: (_, _) =>
              _buildStudioVector(bodyColor, frameBorderColor),
          errorWidget: (_, _, _) =>
              _buildStudioVector(bodyColor, frameBorderColor),
        ),
      );
    }

    if (assetPath != null) {
      return SizedBox(
        height: height,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              _buildStudioVector(bodyColor, frameBorderColor),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: _buildStudioVector(bodyColor, frameBorderColor),
    );
  }

  String? _resolveAssetPath() {
    final lower = productName.toLowerCase();
    if (lower.contains('16 pro max')) {
      return 'assets/images/lineup_16_promax.jpg';
    }
    if (lower.contains('16 pro')) {
      return 'assets/images/lineup_16_pro.jpg';
    }
    if (lower.contains('16 plus')) {
      return 'assets/images/lineup_16_plus.jpg';
    }
    if (lower.contains('iphone 16')) {
      return 'assets/images/lineup_16_standard.jpg';
    }
    if (lower.contains('airpods')) {
      return 'assets/images/acc_airpods_pro.jpg';
    }
    if (lower.contains('ví') ||
        lower.contains('finewoven') ||
        lower.contains('wallet')) {
      return 'assets/images/acc_finewoven_wallet.jpg';
    }
    if (lower.contains('ốp')) {
      return 'assets/images/acc_clear_case.jpg';
    }
    if (lower.contains('magsafe') || lower.contains('sạc')) {
      return 'assets/images/acc_magsafe_charger.jpg';
    }
    return null;
  }

  Widget _buildStudioVector(Color bodyColor, Color frameBorderColor) {
    final isAccessory =
        categoryId.toLowerCase().contains('accessories') ||
        productName.toLowerCase().contains('airpods') ||
        productName.toLowerCase().contains('sạc') ||
        productName.toLowerCase().contains('ốp');

    if (isAccessory) {
      return Center(
        child: Container(
          width: height * 0.72,
          height: height * 0.72,
          decoration: BoxDecoration(
            color: bodyColor,
            borderRadius: BorderRadius.circular(height * 0.24),
            border: Border.all(color: frameBorderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: bodyColor.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            productName.toLowerCase().contains('airpods')
                ? Icons.headphones_rounded
                : Icons.bolt_rounded,
            size: height * 0.36,
            color: bodyColor.computeLuminance() > 0.65
                ? AppColors.ink
                : Colors.white,
          ),
        ),
      );
    }

    final width = height * 0.54;
    final brandLower = brandId.toLowerCase();

    return Center(
      child: Container(
        width: width,
        height: height * 0.92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(bodyColor, Colors.white, 0.18) ?? bodyColor,
              bodyColor,
              Color.lerp(bodyColor, Colors.black, 0.15) ?? bodyColor,
            ],
          ),
          borderRadius: BorderRadius.circular(width * 0.22),
          border: Border.all(color: frameBorderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B1220).withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Cụm camera đặc trưng theo từng hãng (Apple, Samsung, Xiaomi, OPPO)
            Positioned(
              top: 8,
              left: 8,
              child: _buildCameraIsland(brandLower, width, bodyColor),
            ),
            // Logo / Nhãn thương hiệu tinh tế ở mặt lưng
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Text(
                  brandId.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: bodyColor.computeLuminance() > 0.6
                        ? AppColors.ink.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraIsland(String brandLower, double width, Color bodyColor) {
    final lensColor = const Color(0xFF0B1220);
    final islandColor = Color.lerp(bodyColor, Colors.black, 0.18) ?? bodyColor;

    if (brandLower.contains('samsung')) {
      // Cụm 3 ống kính dọc đặc trưng dòng Galaxy S25
      return Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 3),
            width: width * 0.22,
            height: width * 0.22,
            decoration: BoxDecoration(
              color: lensColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
          ),
        ),
      );
    }

    if (brandLower.contains('oppo') || brandLower.contains('xiaomi')) {
      // Cụm camera tròn lớn Leica / Hasselblad
      return Container(
        width: width * 0.54,
        height: width * 0.54,
        decoration: BoxDecoration(
          color: lensColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: const Center(
          child: Icon(Icons.camera_rounded, size: 12, color: Colors.white54),
        ),
      );
    }

    // Cụm camera vuông bo góc đặc trưng iPhone 16 / 16 Pro
    return Container(
      width: width * 0.44,
      height: width * 0.44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: islandColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.13,
            height: width * 0.13,
            decoration: const BoxDecoration(
              color: Color(0xFF0B1220),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: width * 0.13,
            height: width * 0.13,
            decoration: const BoxDecoration(
              color: Color(0xFF0B1220),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
