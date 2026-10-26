import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../maps/store_map_screen.dart';
import '../orders/orders_screen.dart';
import '../products/compare_phones_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'address_management_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật hồ sơ cá nhân (F17)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.updateProfile(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đã cập nhật hồ sơ cá nhân lên Firestore (F17)!',
                  ),
                ),
              );
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản & Cài đặt (F17)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Thẻ thông tin tài khoản
          LmMaterialCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  child: Icon(Icons.person_rounded, size: 30, color: accent),
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
                              user?.name ?? 'Khách vãng lai (Guest)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (auth.isAdmin) ...[
                            const SizedBox(width: 6),
                            LmStatusPill(text: 'ADMIN', color: accent),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user?.email ?? 'Giỏ hàng lưu tại cart_guest.json',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (user != null && user.phone.isNotEmpty)
                        Text(
                          'SĐT: ${user.phone}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (auth.isAuthenticated)
                  IconButton(
                    tooltip: 'Chỉnh sửa hồ sơ (F17)',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditProfileDialog(context),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(105, 40),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Đăng nhập'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Chọn bảng màu Theme chuẩn `UI DESIGN/scripts/lib/lm-themes.json`
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bảng màu giao diện (UI DESIGN Theme Engine)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nền giữ tông trắng tinh khiết, màu nhấn áp dụng cho nút bấm, từ khóa và vòng chọn.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Blue (#2F6BFF)'),
                      selected: auth.themeType == LmThemeType.blue,
                      onSelected: (_) => auth.setThemeType(LmThemeType.blue),
                    ),
                    ChoiceChip(
                      label: const Text('Mono (#1F1E1C)'),
                      selected: auth.themeType == LmThemeType.mono,
                      onSelected: (_) => auth.setThemeType(LmThemeType.mono),
                    ),
                    ChoiceChip(
                      label: const Text('Orange (#F37021)'),
                      selected: auth.themeType == LmThemeType.orange,
                      onSelected: (_) => auth.setThemeType(LmThemeType.orange),
                    ),
                  ],
                ),
                const Divider(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Chế độ Offline Mode (F23 / Test TC07)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Kiểm thử đọc/ghi cart.json & favorites.json khi ngắt mạng',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: auth.isOfflineSimulated,
                  onChanged: auth.toggleOfflineSimulation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Tiện ích mua sắm & Hỗ trợ
          LmMaterialCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.receipt_long_outlined, color: accent),
                  title: const Text(
                    'Lịch sử đơn hàng của tôi (F14, F15, F16)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.location_on_outlined, color: accent),
                  title: const Text(
                    'Sổ địa chỉ nhận hàng (F18)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddressManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.favorite_border_rounded, color: accent),
                  title: const Text(
                    'Danh sách điện thoại yêu thích (F12)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.compare_arrows_rounded, color: accent),
                  title: const Text(
                    'So sánh cấu hình điện thoại',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ComparePhonesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.support_agent_rounded, color: accent),
                  title: const Text(
                    'Chat hỗ trợ trực tuyến với cửa hàng (F20)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.map_outlined, color: accent),
                  title: const Text(
                    'Bản đồ hệ thống cửa hàng SmartStore (F21)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StoreMapScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: accent,
                  ),
                  title: Text(
                    auth.isAdmin
                        ? 'Admin Portal – Quản trị hệ thống (A01–A10)'
                        : 'Mở nhanh Admin Portal (Chế độ Demo Đồ án)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  subtitle: const Text(
                    'Quản lý sản phẩm, biến thể, tồn kho, duyệt đơn & quét QR',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
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
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất tài khoản (TC16)'),
            ),
          ],
        ],
      ),
    );
  }
}
