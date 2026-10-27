import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';

// ============================================================================
// 1. AMBIENT LIQUID MESH GRADIENT CANVAS
// Moving colored light orbs (Slate Navy #243342, Desert Amber #D4C8B8, Cyber Blue #0071E3)
// that shine through translucent glass cards.
// ============================================================================
class LiquidAmbientCanvas extends StatefulWidget {
  final Widget? child;
  final bool animate;

  const LiquidAmbientCanvas({
    super.key,
    this.child,
    this.animate = true,
  });

  @override
  State<LiquidAmbientCanvas> createState() => _LiquidAmbientCanvasState();
}

class _LiquidAmbientCanvasState extends State<LiquidAmbientCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: AppColors.background),
        ),
        Positioned.fill(
          child: widget.animate
              ? AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _LiquidOrbPainter(progress: _controller.value),
                    );
                  },
                )
              : CustomPaint(
                  painter: _LiquidOrbPainter(progress: 0.5),
                ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _LiquidOrbPainter extends CustomPainter {
  final double progress;

  _LiquidOrbPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    // Orb 1: Slate Navy (#243342) - Top Left
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF243342).withValues(alpha: 0.40),
          const Color(0xFF3E566E).withValues(alpha: 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.15 + math.sin(t) * 35,
            size.height * 0.08 + math.cos(t) * 25,
          ),
          radius: size.width * 0.65,
        ),
      );
    canvas.drawCircle(
      Offset(
        size.width * 0.15 + math.sin(t) * 35,
        size.height * 0.08 + math.cos(t) * 25,
      ),
      size.width * 0.65,
      paint1,
    );

    // Orb 2: Desert Titanium Amber (#D4C8B8) - Top Right
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD4C8B8).withValues(alpha: 0.48),
          const Color(0xFFE2A866).withValues(alpha: 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.85 - math.cos(t) * 30,
            size.height * 0.25 + math.sin(t) * 35,
          ),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(
        size.width * 0.85 - math.cos(t) * 30,
        size.height * 0.25 + math.sin(t) * 35,
      ),
      size.width * 0.55,
      paint2,
    );

    // Orb 3: Cyber Refraction Blue (#0071E3) - Bottom Center
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0071E3).withValues(alpha: 0.25),
          const Color(0xFF60A5FA).withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.35 + math.cos(t) * 40,
            size.height * 0.75 - math.sin(t) * 30,
          ),
          radius: size.width * 0.60,
        ),
      );
    canvas.drawCircle(
      Offset(
        size.width * 0.35 + math.cos(t) * 40,
        size.height * 0.75 - math.sin(t) * 30,
      ),
      size.width * 0.60,
      paint3,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================================
// 2. LIQUID-GLASS CARD (LIGHT / REFRACTIVE)
// Faithful reproduction of .liquid-glass-card from ui_template_kit
// ============================================================================
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
    this.borderRadius = 20,
    this.blurSigma = 24,
    this.onTap,
    this.isSelected = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ??
        (isSelected
            ? AppColors.brand700
            : Colors.white.withValues(alpha: 0.88));

    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.75),
            blurRadius: 1,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.78),
                  const Color(0xFFF0F4F8).withValues(alpha: 0.44),
                ],
              ),
              border: Border.all(
                color: effectiveBorderColor,
                width: isSelected ? 2.0 : 1.3,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap == null) return cardContent;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap!();
      },
      child: cardContent,
    );
  }
}

// ============================================================================
// 3. LIQUID-GLASS DARK CARD (PREMIUM TITANIUM DEEP SECTION)
// Faithful reproduction of .liquid-glass-dark from ui_template_kit
// ============================================================================
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
    this.borderRadius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1722).withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brand700.withValues(alpha: 0.90),
                  AppColors.brand900.withValues(alpha: 0.96),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.4,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap == null) return box;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
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
    final fgColor = isDark ? Colors.white : accent;
    final disabled = onPressed == null || isLoading;

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? accent : const Color(0xFF0F172A))
                  .withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
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
    final accent = Theme.of(context).colorScheme.primary;
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
              color: isSelected ? accent : Colors.transparent,
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
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? accent : AppColors.border,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
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
    this.borderRadius = 20,
    this.blurSigma = 20,
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
    this.borderRadius = 18,
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
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
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
