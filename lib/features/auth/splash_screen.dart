import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const SplashScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: LmMaterialCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 2),
                    ),
                    child: Icon(
                      Icons.smartphone_rounded,
                      size: 36,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SmartStore',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Điện thoại & phụ kiện chính hãng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LmTintedButton(
                    label: 'Khám phá ngay',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onContinue,
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
