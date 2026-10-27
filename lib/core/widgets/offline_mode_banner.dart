import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class OfflineModeBanner extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onToggleSimulate;

  const OfflineModeBanner({
    super.key,
    required this.isOffline,
    this.onToggleSimulate,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.warningSoft,
        border: Border(bottom: BorderSide(color: Color(0xFFFDE68A))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Đang offline: giỏ hàng và yêu thích được lưu trên máy.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onToggleSimulate != null)
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
              ),
              onPressed: onToggleSimulate,
              child: const Text(
                'Bật lại mạng',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
