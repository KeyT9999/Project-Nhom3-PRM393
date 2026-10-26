import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/repositories/product_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import 'admin_brands_banners_screen.dart';
import 'admin_customers_chat_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isSeeding = false;

  Future<void> _handleSeedFirestore() async {
    setState(() => _isSeeding = true);
    try {
      await ProductRepository().seedDemoDataToFirestore();
      if (!mounted) return;
      await context.read<ProductProvider>().loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã đồng bộ toàn bộ sản phẩm, biến thể, thương hiệu & banner lên Cloud Firestore (project-prm393-dc768)!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đẩy dữ liệu lên Firestore: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final orderProv = context.watch<OrderProvider>();
    final palette = context.watch<AuthProvider>().palette;

    final products = prodProv.allProducts;
    final orders = orderProv.orders;
    final totalRevenue = orderProv.totalRevenueVnd;
    final pendingCount = orderProv.pendingOrdersCount;
    final deliveredCount = orders.where((o) => o.status == 'delivered').length;
    final cancelledCount = orders
        .where((o) => o.status == 'cancelled' || o.status == 'failed_delivery')
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Portal – SmartStore (A01–A10)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // A02 + A10: Thẻ tổng quan doanh thu & đơn hàng phong cách UI DESIGN
          LmMaterialCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LmStatusPill(
                      text: 'DOANH THU & THỐNG KÊ (A02, A10)',
                      color: palette.primary,
                    ),
                    Icon(Icons.insights_rounded, color: palette.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.formatVnd(totalRevenue),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng doanh thu hợp lệ từ ${orders.length} đơn hàng (${products.length} dòng sản phẩm đang kinh doanh)',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.ink3),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    _buildMiniStat(
                      label: 'Chờ duyệt',
                      value: '$pendingCount',
                      color: AppColors.warning,
                    ),
                    _buildMiniStat(
                      label: 'Đã giao',
                      value: '$deliveredCount',
                      color: AppColors.success,
                    ),
                    _buildMiniStat(
                      label: 'Đã hủy',
                      value: '$cancelledCount',
                      color: AppColors.danger,
                    ),
                    _buildMiniStat(
                      label: 'Mã giảm giá',
                      value: '${prodProv.coupons.length}',
                      color: palette.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'PHÂN HỆ QUẢN TRỊ CỬA HÀNG (A03 – A09)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 10),
          _buildNavCard(
            context: context,
            palette: palette,
            icon: Icons.smartphone_rounded,
            badge: 'A03 • A04',
            title: 'Quản lý Sản phẩm & Biến thể SKU / Tồn kho',
            subtitle:
                '${products.length} sản phẩm • Thêm/Sửa điện thoại, cấu hình RAM/ROM, màu sắc & số lượng kho',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminProductsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildNavCard(
            context: context,
            palette: palette,
            icon: Icons.local_shipping_outlined,
            badge: 'A06 • S05',
            title: 'Xử lý Đơn hàng & Quét QR Vận đơn',
            subtitle:
                '${orders.length} đơn hàng ($pendingCount chờ xác nhận) • Duyệt đơn, hoàn kho tự động & đẩy thông báo',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildNavCard(
            context: context,
            palette: palette,
            icon: Icons.campaign_outlined,
            badge: 'A05 • A08',
            title: 'Quản lý Thương hiệu & Banner Trang chủ',
            subtitle:
                '${prodProv.allBrandsAdmin.length} thương hiệu • ${prodProv.allBannersAdmin.length} banner chiến dịch',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminBrandsBannersScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildNavCard(
            context: context,
            palette: palette,
            icon: Icons.support_agent_rounded,
            badge: 'A07 • A09',
            title: 'Danh sách Khách hàng & Phản hồi Chat CSKH',
            subtitle: 'Tra cứu tài khoản khách hàng & trả lời tin nhắn hỗ trợ trực tuyến',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminCustomersChatScreen(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          LmTintedButton(
            label: _isSeeding
                ? 'Đang đồng bộ lên Cloud Firestore...'
                : 'Đồng bộ dữ liệu mẫu lên Cloud Firestore',
            icon: Icons.cloud_upload_outlined,
            isLoading: _isSeeding,
            onPressed: _isSeeding ? null : _handleSeedFirestore,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.ink3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required LmPalette palette,
    required IconData icon,
    required String badge,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return LmMaterialCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: palette.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: palette.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LmStatusPill(text: badge, color: palette.primary),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
        ],
      ),
    );
  }
}
