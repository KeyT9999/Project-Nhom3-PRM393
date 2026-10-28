import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';

// ============================================================================
// Bộ widget nền tảng của giao diện. Tên lớp giữ nguyên để không phải sửa nơi
// gọi, nhưng kiểu dáng đã đơn giản hóa: nền tĩnh, thẻ trắng viền mảnh 1px,
// không blur, không gradient, không đổ bóng.
// ============================================================================

/// Nền màn hình tĩnh. [animate] được giữ để tương thích, không còn tác dụng.
class LiquidAmbientCanvas extends StatelessWidget {
  final Widget? child;
  final bool animate;

  const LiquidAmbientCanvas({
    super.key,
    this.child,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox.expand(child: child),
    );
  }
}

/// Thẻ trắng viền 1px. [blurSigma] giữ để tương thích, không còn dùng.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? borderColor;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 12,
    this.blurSigma = 0,
    this.onTap,
    this.isSelected = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(borderRadius > 14 ? 12 : borderRadius);
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? (isSelected ? accent : AppColors.border),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(color: Colors.transparent, child: child),
    );

    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: card,
    );
  }
}

/// Khối nền đậm (một màu, không gradient).
class LiquidGlassDarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const LiquidGlassDarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.brand800,
        borderRadius: BorderRadius.circular(borderRadius > 14 ? 12 : borderRadius),
      ),
      child: Material(color: Colors.transparent, child: child),
    );

    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: box,
    );
  }
}

// ============================================================================
// 4. LIQUID PILL BUTTON (APPLE STYLE)
// .btn-pill-dark / .btn-pill-white
// ============================================================================
class LiquidPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isDark;
  final bool isLoading;
  final double height;
  final double? width;

  const LiquidPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDark = true,
    this.isLoading = false,
    this.height = 46,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bgColor = isDark ? accent : Colors.white;
    final fgColor = isDark ? Colors.white : AppColors.brand900;
    final disabled = onPressed == null || isLoading;

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isDark ? null : Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: fgColor,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, size: 16, color: fgColor),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              label,
                              style: TextStyle(
                                color: fgColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. TITANIUM FINISH SWATCH SELECTOR
// Color circles for Desert, Natural, White, Black Titanium
// ============================================================================
class TitaniumFinishDot extends StatelessWidget {
  final String finishKey;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onSelected;

  const TitaniumFinishDot({
    super.key,
    required this.finishKey,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected();
      },
      child: Tooltip(
        message: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.brand700 : Colors.transparent,
              width: 2.2,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 6. STORAGE CAPACITY PILL
// 256GB, 512GB, 1TB capacity selector
// ============================================================================
class StorageCapacityPill extends StatelessWidget {
  final String capacity;
  final bool isSelected;
  final VoidCallback onSelected;

  const StorageCapacityPill({
    super.key,
    required this.capacity,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand700 : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brand700 : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          capacity,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.ink,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 7. DYNAMIC ISLAND PILL
// Floating black glass notification / order island
// ============================================================================
class DynamicIslandPill extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingText;
  final VoidCallback? onTap;

  const DynamicIslandPill({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1722).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFD4C8B8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F1722),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailingText,
              style: const TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 8. BACKWARD COMPATIBILITY ALIASES
// ============================================================================
class LmGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  const LmGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 12,
    this.blurSigma = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: padding,
      borderRadius: borderRadius,
      blurSigma: blurSigma,
      child: child,
    );
  }
}

class LmMaterialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool selected;
  final Color? selectionColor;

  const LmMaterialCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 12,
    this.onTap,
    this.selected = false,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      isSelected: selected,
      borderColor: selected ? selectionColor : null,
      child: child,
    );
  }
}

class LmTintedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;

  const LmTintedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidPillButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      height: height,
    );
  }
}

class LmStatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const LmStatusPill({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
