import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';

class StoreBranch {
  final String name;
  final String address;
  final String hours;
  final String hotline;
  final double lat;
  final double lng;

  const StoreBranch({
    required this.name,
    required this.address,
    required this.hours,
    required this.hotline,
    required this.lat,
    required this.lng,
  });
}

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  int _selectedBranchIndex = 0;

  static const List<StoreBranch> _branches = [
    StoreBranch(
      name: 'SmartStore Flagship – Khu Công Nghệ Cao (TP. Thủ Đức)',
      address: 'Lô E2a-7, Đường D1, Khu Công Nghệ Cao, TP. Thủ Đức, TP.HCM',
      hours: '08:00 – 21:30 (Tất cả các ngày trong tuần)',
      hotline: '0901234567',
      lat: 10.8412,
      lng: 106.8099,
    ),
    StoreBranch(
      name: 'SmartStore Center – Quận 1 (Bitexco)',
      address: 'Số 2 Hải Triều, Phường Bến Nghé, Quận 1, TP.HCM',
      hours: '08:30 – 22:00 (Thứ 2 – Chủ Nhật)',
      hotline: '0909888999',
      lat: 10.7716,
      lng: 106.7044,
    ),
  ];

  Future<void> _openGoogleMaps(StoreBranch branch) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${branch.lat},${branch.lng}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _callHotline(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final branch = _branches[_selectedBranchIndex];
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ cửa hàng SmartStore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bản đồ trực quan phong cách Frosted-Glass & Clean White (Không cần Visa API Key)
          LmMaterialCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 230,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _InteractiveMapCanvasPainter(
                        accentColor: accent,
                      ),
                    ),
                    // Điểm ghim cửa hàng (Pin Marker)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LmGlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            borderRadius: 99,
                            child: Text(
                              branch.name.split('–').first.trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.location_on_rounded,
                            size: 44,
                            color: accent,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: LmGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        borderRadius: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GPS: ${branch.lat}° N, ${branch.lng}° E',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            LmStatusPill(
                              text: 'Đang mở cửa',
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Chọn chi nhánh cửa hàng:',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
          ),
          const SizedBox(height: 10),
          ...List.generate(_branches.length, (idx) {
            final item = _branches[idx];
            final isSelected = idx == _selectedBranchIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LmMaterialCard(
                selected: isSelected,
                onTap: () => setState(() => _selectedBranchIndex = idx),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📍 ${item.address}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🕒 Giờ mở cửa: ${item.hours}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📞 Hotline: ${item.hotline}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          LmTintedButton(
            label: 'Mở chỉ đường trên Google Maps Android',
            icon: Icons.directions_rounded,
            onPressed: () => _openGoogleMaps(branch),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _callHotline(branch.hotline),
            icon: const Icon(Icons.phone_in_talk_outlined),
            label: Text('Gọi Hotline chi nhánh (${branch.hotline})'),
          ),
        ],
      ),
    );
  }
}

class _InteractiveMapCanvasPainter extends CustomPainter {
  final Color accentColor;

  const _InteractiveMapCanvasPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFEEF2F8);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Vẽ lưới đường phố mô phỏng bản đồ sạch sẽ
    final gridPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;
    for (double x = 30; x < size.width; x += 65) {
      canvas.drawLine(Offset(x, 0), Offset(x + 20, size.height), gridPaint);
    }
    for (double y = 25; y < size.height; y += 55) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 10), gridPaint);
    }

    // Vẽ trục đại lộ chính
    final highwayPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
      ..strokeWidth = 12;
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.32),
      highwayPaint,
    );

    // Vòng bán kính định vị вокруг điểm ghim
    final pulsePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 + 12),
      42,
      pulsePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _InteractiveMapCanvasPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
