import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';

class _OnboardingSlideData {
  final String eyebrow;
  final String title;
  final String description;
  final String imageAsset;
  final IconData fallbackIcon;
  final String topBadge;
  final String bottomBadge;
  final IconData bottomBadgeIcon;
  final List<String> highlights;

  const _OnboardingSlideData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.topBadge,
    required this.bottomBadge,
    required this.bottomBadgeIcon,
    required this.highlights,
  });
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const SplashScreen({super.key, required this.onContinue});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      eyebrow: 'THẾ GIỚI FLAGSHIP CHÍNH HÃNG',
      title: 'Tuyệt tác công nghệ\ntrong tầm tay bạn',
      description:
          'Quy tụ các dòng điện thoại đầu bảng Apple, Samsung, Xiaomi, OPPO cùng hệ sinh thái phụ kiện chuẩn hãng nguyên seal.',
      imageAsset: 'assets/images/hero_iphone_rock.jpg',
      fallbackIcon: Icons.smartphone_rounded,
      topBadge: 'Apple • Samsung • Xiaomi • OPPO',
      bottomBadge: 'Nguyên seal chính hãng • Bảo hành 12 tháng',
      bottomBadgeIcon: Icons.verified_rounded,
      highlights: ['Chính hãng 100%', '1 đổi 1 uy tín', 'Sẵn hàng đủ màu'],
    ),
    _OnboardingSlideData(
      eyebrow: 'CHỌN MÁY CHUẨN XÁC',
      title: 'Tìm kiếm thông minh &\nlọc thông số tức thì',
      description:
          'Lọc nhanh theo thương hiệu, RAM, bộ nhớ trong, tầm giá và xem đánh giá thực tế để chọn đúng chiếc điện thoại hợp nhu cầu nhất.',
      imageAsset: 'assets/images/camera_macro_lens.jpg',
      fallbackIcon: Icons.tune_rounded,
      topBadge: 'Bộ lọc đa tiêu chí • Đánh giá xác thực',
      bottomBadge: 'Duyệt mượt & lưu giỏ hàng ngay cả khi Offline',
      bottomBadgeIcon: Icons.bolt_rounded,
      highlights: ['Lọc RAM / ROM', 'Đánh giá thực tế', 'Hỗ trợ Offline'],
    ),
    _OnboardingSlideData(
      eyebrow: 'THANH TOÁN & GIAO NHẬN',
      title: 'Quét VietQR siêu tốc,\ngiao nhanh tận tay',
      description:
          'Tích hợp thanh toán VietQR PayOS tự động đối soát hoặc nhận hàng kiểm tra nguyên seal (COD), theo dõi đơn theo thời gian thực.',
      imageAsset: 'assets/images/footer_phone_dark.jpg',
      fallbackIcon: Icons.qr_code_scanner_rounded,
      topBadge: 'VietQR PayOS • COD tận nơi',
      bottomBadge: 'Hỗ trợ trực tuyến & tra cứu bản đồ cửa hàng',
      bottomBadgeIcon: Icons.local_shipping_outlined,
      highlights: ['VietQR PayOS', 'Voucher ưu đãi', 'Giao hỏa tốc 2H'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleNext() {
    if (_currentPage < _slides.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      HapticFeedback.lightImpact();
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LiquidAmbientCanvas(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Thanh Header thương hiệu & nút Bỏ qua
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 4),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.smartphone_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'SmartStore',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    if (!isLastPage)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.inkSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: widget.onContinue,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bỏ qua',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, size: 18),
                          ],
                        ),
                      )
                    else
                      LmStatusPill(
                        text: 'Sẵn sàng',
                        color: accent,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                  ],
                ),
              ),

              // 2. Slide 3 trang giới thiệu ứng dụng
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildSlidePage(_slides[index], index, accent);
                  },
                ),
              ),

              // 3. Thanh điều hướng Dots & Nút bấm dưới đáy
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chỉ báo trang (Animated Pill Indicators)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (idx) {
                        final selected = idx == _currentPage;
                        return GestureDetector(
                          onTap: () => _goToPage(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected ? accent : AppColors.border,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),

                    // Hàng nút quay lại & Tiếp tục / Khám phá ngay
                    Row(
                      children: [
                        if (_currentPage > 0) ...[
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(48, 48),
                                side: const BorderSide(color: AppColors.border),
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _goToPage(_currentPage - 1),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: LiquidPillButton(
                            label: isLastPage ? 'Khám phá ngay' : 'Tiếp tục',
                            icon: Icons.arrow_forward_rounded,
                            height: 48,
                            onPressed: _handleNext,
                          ),
                        ),
                      ],
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

  Widget _buildSlidePage(
    _OnboardingSlideData slide,
    int pageIndex,
    Color accent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 470;
        final imageHeight = (constraints.maxHeight * (isCompact ? 0.43 : 0.50))
            .clamp(135.0, 330.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Khung ảnh Studio bo góc kèm huy hiệu thông tin nổi
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      slide.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: accent.withValues(alpha: 0.08),
                        child: Center(
                          child: Icon(
                            slide.fallbackIcon,
                            size: 64,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                    // Lớp phủ tối nhẹ ở đáy ảnh để nổi bật huy hiệu thông tin
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 82,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.68),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Huy hiệu góc trên
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          slide.topBadge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    // Số thứ tự slide góc trên phải
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.52),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '0${pageIndex + 1} / 0${_slides.length}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Huy hiệu cam kết dưới đáy ảnh
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Row(
                        children: [
                          Icon(
                            slide.bottomBadgeIcon,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              slide.bottomBadge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isCompact ? 12 : 22),

              // Nhãn phụ Eyebrow
              Text(
                slide.eyebrow,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: isCompact ? 4 : 8),

              // Tiêu đề chính
              Text(
                slide.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isCompact ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  height: 1.18,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: isCompact ? 6 : 10),

              // Mô tả chi tiết
              Text(
                slide.description,
                maxLines: isCompact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isCompact ? 12.5 : 13.5,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              SizedBox(height: isCompact ? 10 : 14),

              // 3 Chip điểm nhấn tính năng
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: slide.highlights
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: accent,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
