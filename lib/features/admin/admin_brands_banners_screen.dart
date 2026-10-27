import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/brand_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class AdminBrandsBannersScreen extends StatelessWidget {
  const AdminBrandsBannersScreen({super.key});

  void _showAddBrandDialog(BuildContext context, {BrandModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final countryCtrl = TextEditingController(
      text: existing?.origin ?? 'Mỹ / Hàn Quốc',
    );
    bool isActive = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            existing == null ? 'Thêm Thương hiệu' : 'Sửa Thương hiệu',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên hãng'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: countryCtrl,
                decoration: const InputDecoration(labelText: 'Quốc gia'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isActive,
                onChanged: (v) => setState(() => isActive = v),
                title: const Text('Hiển thị trên trang chủ'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final brand = BrandModel(
                  id: existing?.id ?? name.toLowerCase(),
                  name: name,
                  slug: name.toLowerCase().replaceAll(' ', '-'),
                  origin: countryCtrl.text.trim(),
                  isActive: isActive,
                );
                await context.read<ProductProvider>().upsertBrand(brand);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBannerDialog(BuildContext context, {BannerModel? existing}) {
    final badgeCtrl = TextEditingController(
      text: existing?.badge ?? 'KHUYẾN MÃI MỚI',
    );
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subCtrl = TextEditingController(text: existing?.subtitle ?? '');
    bool isActive = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            existing == null
                ? 'Thêm Banner Trang chủ'
                : 'Cập nhật Banner',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: badgeCtrl,
                decoration: const InputDecoration(labelText: 'Nhãn Eyebrow'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tiêu đề chính'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả phụ'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isActive,
                onChanged: (v) => setState(() => isActive = v),
                title: const Text('Đang hiển thị'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                final banner = BannerModel(
                  id:
                      existing?.id ??
                      'bn_${DateTime.now().millisecondsSinceEpoch}',
                  badge: badgeCtrl.text.trim(),
                  title: title,
                  subtitle: subCtrl.text.trim(),
                  targetProductId:
                      existing?.targetProductId ?? 'iphone_16_pro_max',
                  sortOrder: existing?.sortOrder ?? 1,
                  isActive: isActive,
                );
                await context.read<ProductProvider>().upsertBanner(banner);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('Lưu Banner'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final brands = prodProv.allBrandsAdmin;
    final banners = prodProv.allBannersAdmin;
    final palette = context.watch<AuthProvider>().palette;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thương hiệu & Banner'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thương hiệu'),
              Tab(text: 'Banner quảng cáo'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Brands (A05)
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LmTintedButton(
                  label: 'Thêm thương hiệu mới',
                  icon: Icons.add,
                  onPressed: () => _showAddBrandDialog(context),
                ),
                const SizedBox(height: 16),
                ...brands.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LmMaterialCard(
                      padding: const EdgeInsets.all(14),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: palette.primarySoft,
                            child: Text(
                              b.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Xuất xứ: ${b.origin}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.ink3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LmStatusPill(
                            text: b.isActive ? 'Đang bật' : 'Đã ẩn',
                            color: b.isActive
                                ? AppColors.success
                                : AppColors.ink4,
                          ),
                          IconButton(
                            onPressed: () =>
                                _showAddBrandDialog(context, existing: b),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Tab 2: Banners (A08)
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LmTintedButton(
                  label: 'Thêm Banner chiến dịch mới',
                  icon: Icons.add_photo_alternate_outlined,
                  onPressed: () => _showAddBannerDialog(context),
                ),
                const SizedBox(height: 16),
                ...banners.map(
                  (bn) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LmMaterialCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LmStatusPill(
                                text: bn.badge,
                                color: palette.primary,
                              ),
                              Row(
                                children: [
                                  LmStatusPill(
                                    text: bn.isActive ? 'Hiển thị' : 'Tạm ẩn',
                                    color: bn.isActive
                                        ? AppColors.success
                                        : AppColors.ink4,
                                  ),
                                  IconButton(
                                    onPressed: () => _showAddBannerDialog(
                                      context,
                                      existing: bn,
                                    ),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bn.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bn.subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
