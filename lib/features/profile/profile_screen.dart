import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../maps/store_map_screen.dart';
import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'address_management_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<({LmThemeType type, String name, Color swatch})>
  _themeOptions = [
    (
      type: LmThemeType.titanium,
      name: 'Titan',
      swatch: Color(0xFF243342),
    ),
    (
      type: LmThemeType.blue,
      name: 'Xanh dương',
      swatch: Color(0xFF2F6BFF),
    ),
    (
      type: LmThemeType.mono,
      name: 'Đen trắng',
      swatch: Color(0xFF1F1E1C),
    ),
    (
      type: LmThemeType.orange,
      name: 'Cam',
      swatch: Color(0xFFF37021),
    ),
  ];

  String _initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'SM';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final first = parts.first.substring(0, 1);
    final last = parts.last.substring(0, 1);
    return '$first$last'.toUpperCase();
  }

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wishlistCount =
        context.watch<WishlistProvider>().favoriteProductIds.length;
    final orderCount = context
        .watch<OrderProvider>()
        .ordersByStatus('all', userId: auth.activeUserId)
        .length;
    final addressCount = auth.addresses.length;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tài khoản & Cài đặt')),
      body: LiquidAmbientCanvas(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            // 1. Thẻ hồ sơ tài khoản (Đã xử lý triệt để lỗi gãy dòng & ẩn text kỹ thuật)
            _buildAccountCard(context, auth, accent),
            const SizedBox(height: 12),

            // 2. Thanh truy cập nhanh (Đơn hàng • Yêu thích • Sổ địa chỉ)
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Đơn mua',
                    badgeText: '$orderCount',
                    accent: accent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickStatTile(
                    icon: Icons.favorite_border_rounded,
                    label: 'Yêu thích',
                    badgeText: '$wishlistCount',
                    accent: accent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WishlistScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickStatTile(
                    icon: Icons.location_on_outlined,
                    label: 'Sổ địa chỉ',
                    badgeText: '$addressCount',
                    accent: accent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressManagementScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Cá nhân hóa giao diện (Lưới 2x2 chấm màu thật cân đối) & Ngoại tuyến
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildIconBadge(Icons.palette_outlined, accent),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Màu giao diện',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Đồng bộ màu nhấn cho nút bấm, giá bán và thanh điều hướng',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Lưới 2x2 cân đối tuyệt đối (không bao giờ rớt lẻ 1 nút)
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOptionTile(
                          option: _themeOptions[0],
                          isSelected: auth.themeType == _themeOptions[0].type,
                          onTap: () => auth.setThemeType(_themeOptions[0].type),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildThemeOptionTile(
                          option: _themeOptions[1],
                          isSelected: auth.themeType == _themeOptions[1].type,
                          onTap: () => auth.setThemeType(_themeOptions[1].type),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOptionTile(
                          option: _themeOptions[2],
                          isSelected: auth.themeType == _themeOptions[2].type,
                          onTap: () => auth.setThemeType(_themeOptions[2].type),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildThemeOptionTile(
                          option: _themeOptions[3],
                          isSelected: auth.themeType == _themeOptions[3].type,
                          onTap: () => auth.setThemeType(_themeOptions[3].type),
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),

                  // Chế độ ngoại tuyến
                  Row(
                    children: [
                      _buildIconBadge(
                        Icons.cloud_off_rounded,
                        auth.isOfflineSimulated ? AppColors.warning : accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Chế độ ngoại tuyến',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                    color: AppColors.ink,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (auth.isOfflineSimulated) ...[
                                  const SizedBox(width: 8),
                                  const LmStatusPill(
                                    text: 'Đang bật',
                                    color: AppColors.warning,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Duyệt sản phẩm, giỏ hàng và danh sách yêu thích không cần mạng',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: auth.isOfflineSimulated,
                        activeTrackColor: accent,
                        onChanged: auth.toggleOfflineSimulation,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Tiện ích mua sắm & Hỗ trợ khách hàng
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'TIỆN ÍCH & HỖ TRỢ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            LiquidGlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _buildMenuRow(
                    icon: Icons.support_agent_rounded,
                    title: 'Chat hỗ trợ trực tuyến',
                    subtitle: 'Tư vấn chọn máy, trả góp 0% & bảo hành chính hãng',
                    accent: accent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuRow(
                    icon: Icons.storefront_outlined,
                    title: 'Hệ thống cửa hàng SmartStore',
                    subtitle: 'Xem bản đồ và chỉ đường tới chi nhánh gần nhất',
                    accent: accent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StoreMapScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Quản trị hệ thống (Tách riêng thẻ chuyên nghiệp)
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'QUẢN TRỊ HỆ THỐNG',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            LiquidGlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _buildMenuRow(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin Portal – Quản trị cửa hàng',
                subtitle: 'Quản lý sản phẩm, biến thể, tồn kho, duyệt đơn & QR',
                accent: accent,
                trailingBadge: LmStatusPill(
                  text: auth.isAdmin ? 'ADMIN' : 'DEMO',
                  color: accent,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
            ),

            if (auth.isAuthenticated) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                  backgroundColor: AppColors.surface,
                ),
                onPressed: () async {
                  await auth.signOut();
                  if (!context.mounted) return;
                  await context.read<CartProvider>().loadCart(auth.activeUserId);
                  if (!context.mounted) return;
                  await context.read<WishlistProvider>().loadWishlist(
                    auth.activeUserId,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 19),
                label: const Text('Đăng xuất tài khoản'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AuthProvider auth,
    Color accent,
  ) {
    final user = auth.currentUser;

    if (!auth.isAuthenticated || user == null) {
      return LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 26,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'Khách vãng lai',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                                color: AppColors.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          LmStatusPill(text: 'Chưa đăng nhập', color: accent),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Đăng nhập để đồng bộ giỏ hàng, theo dõi đơn mua và nhận ưu đãi thành viên.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LiquidPillButton(
              label: 'Đăng nhập / Đăng ký tài khoản',
              icon: Icons.login_rounded,
              height: 44,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      );
    }

    final photoPath = user.photoUrl?.trim();
    ImageProvider? avatarProvider;
    if (photoPath != null && photoPath.isNotEmpty) {
      if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
        avatarProvider = NetworkImage(photoPath);
      } else if (File(photoPath).existsSync()) {
        avatarProvider = FileImage(File(photoPath));
      }
    }

    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _openEditProfile(context),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(14),
              image: avatarProvider != null
                  ? DecorationImage(image: avatarProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: avatarProvider == null
                ? Center(
                    child: Text(
                      _initialsOf(user.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.5,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (auth.isAdmin) ...[
                      const SizedBox(width: 8),
                      LmStatusPill(text: 'ADMIN', color: accent),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (user.phone.isNotEmpty && user.phone != '0901234567') ...[
                  const SizedBox(height: 2),
                  Text(
                    'SĐT: ${user.phone}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              border: Border.all(color: accent.withValues(alpha: 0.20)),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 15, color: accent),
                const SizedBox(width: 4),
                Text(
                  'Hồ sơ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatTile({
    required IconData icon,
    required String label,
    required String badgeText,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: accent),
              const SizedBox(width: 6),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionTile({
    required ({LmThemeType type, String name, Color swatch}) option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final palette = AppColors.paletteOf(option.type);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? palette.accentLightBg : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? option.swatch : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: option.swatch,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? option.swatch : AppColors.ink,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: option.swatch,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 19, color: color),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
    Widget? trailingBadge,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            _buildIconBadge(icon, accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.ink,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingBadge != null) ...[
              const SizedBox(width: 8),
              trailingBadge,
            ],
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.inkFaint,
            ),
          ],
        ),
      ),
    );
  }
}
