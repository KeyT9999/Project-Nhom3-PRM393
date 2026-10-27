import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';

/// Khung xương (shimmer) thay spinner khi đang tải danh sách sản phẩm.
class ProductSkeleton extends StatelessWidget {
  final bool grid;
  final int count;

  const ProductSkeleton({super.key, this.grid = false, this.count = 6});

  static Widget _box({double? w, double h = 12}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLightSlate,
      highlightColor: Colors.white,
      child: grid ? _gridCard() : _rows(),
    );
  }

  Widget _rows() => Column(
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _box(w: 80, h: 84),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(h: 14),
                        const SizedBox(height: 8),
                        _box(w: 90),
                        const SizedBox(height: 10),
                        _box(w: 110, h: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget _gridCard() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
