import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';

class StoreBranch {
  final String name;
  final String shortName;
  final String address;
  final String hours;
  final String hotline;
  final double lat;
  final double lng;

  const StoreBranch({
    required this.name,
    required this.shortName,
    required this.address,
    required this.hours,
    required this.hotline,
    required this.lat,
    required this.lng,
  });

  LatLng get latLng => LatLng(lat, lng);
}

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  int _selectedBranchIndex = 0;
  late final MapController _mapController;
  double _currentZoom = 16.0;

  static const List<StoreBranch> _branches = [
    StoreBranch(
      name: 'SmartStore Flagship – Khu Công Nghệ Cao (TP. Thủ Đức)',
      shortName: 'SmartStore Thủ Đức',
      address: 'Lô E2a-7, Đường D1, Khu Công Nghệ Cao, TP. Thủ Đức, TP.HCM',
      hours: '08:00 – 21:30 (Tất cả các ngày trong tuần)',
      hotline: '0901234567',
      lat: 10.8412,
      lng: 106.8099,
    ),
    StoreBranch(
      name: 'SmartStore Center – Quận 1 (Bitexco)',
      shortName: 'SmartStore Bitexco Q1',
      address: 'Số 2 Hải Triều, Phường Bến Nghé, Quận 1, TP.HCM',
      hours: '08:30 – 22:00 (Thứ 2 – Chủ Nhật)',
      hotline: '0909888999',
      lat: 10.7716,
      lng: 106.7044,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onSelectBranch(int index) {
    setState(() {
      _selectedBranchIndex = index;
    });
    final target = _branches[index];
    _mapController.move(target.latLng, _currentZoom);
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(10.0, 19.0);
    });
    final target = _branches[_selectedBranchIndex];
    _mapController.move(target.latLng, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(10.0, 19.0);
    });
    final target = _branches[_selectedBranchIndex];
    _mapController.move(target.latLng, _currentZoom);
  }

  void _recenter() {
    final target = _branches[_selectedBranchIndex];
    _mapController.move(target.latLng, 16.0);
    setState(() {
      _currentZoom = 16.0;
    });
  }

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
      appBar: AppBar(
        title: const Text('Bản đồ cửa hàng SmartStore'),
        actions: [
          IconButton(
            tooltip: 'Về vị trí chi nhánh',
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _recenter,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Khung bản đồ đường phố thật 100% trong app (OpenStreetMap Live Tiles)
          LmMaterialCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 290,
                child: Stack(
                  children: [
                    // Bản đồ tương tác trực tiếp trong app
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: branch.latLng,
                        initialZoom: _currentZoom,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.prm393.smartstore',
                        ),
                        MarkerLayer(
                          markers: _branches.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final b = entry.value;
                            final isCurrent = idx == _selectedBranchIndex;
                            return Marker(
                              point: b.latLng,
                              width: 140,
                              height: 72,
                              child: GestureDetector(
                                onTap: () => _onSelectBranch(idx),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? accent
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.18),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: isCurrent
                                              ? Colors.white
                                              : AppColors.border,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Text(
                                        b.shortName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10.5,
                                          color: isCurrent
                                              ? Colors.white
                                              : AppColors.ink,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: isCurrent ? 36 : 28,
                                      color: isCurrent
                                          ? accent
                                          : Colors.grey.shade700,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // Badge góc trên bên trái: Trạng thái Live Map
                    Positioned(
                      top: 12,
                      left: 12,
                      child: LmGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        borderRadius: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Bản đồ đường phố thực tế (Live OSM)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Điều khiển Zoom (+ / -) nổi góc dưới bên phải bản đồ
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'map_zoom_in',
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.ink,
                            elevation: 3,
                            onPressed: _zoomIn,
                            child: const Icon(Icons.add_rounded, size: 20),
                          ),
                          const SizedBox(height: 6),
                          FloatingActionButton.small(
                            heroTag: 'map_zoom_out',
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.ink,
                            elevation: 3,
                            onPressed: _zoomOut,
                            child: const Icon(Icons.remove_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),

                    // Badge góc dưới bên trái: Tọa độ GPS & Trạng thái mở cửa
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: LmGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        borderRadius: 12,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GPS: ${branch.lat}° N, ${branch.lng}° E',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
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

          // 2. Danh sách chọn chi nhánh
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
                onTap: () => _onSelectBranch(idx),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: accent, size: 20),
                      ],
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

          // 3. Nút mở ngoài bằng Google Maps để chỉ đường turn-by-turn
          LmTintedButton(
            label: 'Mở chỉ đường ngoài ứng dụng Google Maps',
            icon: Icons.directions_rounded,
            onPressed: () => _openGoogleMaps(branch),
          ),
          const SizedBox(height: 10),

          // 4. Hotline
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
