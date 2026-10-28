import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../providers/auth_provider.dart';
import 'address_management_screen.dart';

/// Trang chuyên biệt Cập nhật Hồ sơ Cá nhân (F17).
/// Thay thế hoàn toàn hộp thoại AlertDialog sơ sài trước đây bằng trải nghiệm
/// trang riêng chuẩn ứng dụng TMĐT cao cấp.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  String? _selectedPhotoUrl;
  bool _clearPhoto = false;
  bool _isSaving = false;
  bool _isSendingReset = false;
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    final rawPhone = user?.phone.trim() ?? '';
    _phoneCtrl = TextEditingController(
      text: rawPhone == '0901234567' ? '' : rawPhone,
    );
    _selectedPhotoUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

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
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool _hasChanges(AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null) return false;
    final cleanStoredPhone =
        user.phone.trim() == '0901234567' ? '' : user.phone.trim();
    final currentPhone = _phoneCtrl.text.replaceAll(RegExp(r'[\s\.\-]'), '');
    if (_nameCtrl.text.trim() != user.name.trim()) return true;
    if (currentPhone != cleanStoredPhone) return true;
    if (_clearPhoto && user.photoUrl != null) return true;
    if (!_clearPhoto && _selectedPhotoUrl != user.photoUrl) return true;
    return false;
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final uid = context.read<AuthProvider>().activeUserId;
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final dir = await getApplicationDocumentsDirectory();
      final savedPath =
          '${dir.path}/avatar_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(picked.path).copy(savedPath);

      if (!mounted) return;
      setState(() {
        _selectedPhotoUrl = savedPath;
        _clearPhoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Không thể mở thư viện ảnh trên thiết bị này.'),
        ),
      );
    }
  }

  void _showAvatarOptionsSheet(Color accent) {
    final hasCustomPhoto =
        !_clearPhoto &&
        _selectedPhotoUrl != null &&
        _selectedPhotoUrl!.trim().isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ảnh đại diện hồ sơ',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              _buildSheetOption(
                icon: Icons.photo_library_outlined,
                title: 'Chọn ảnh từ thư viện',
                color: accent,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              _buildSheetOption(
                icon: Icons.photo_camera_outlined,
                title: 'Chụp ảnh mới từ Camera',
                color: accent,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAvatar(ImageSource.camera);
                },
              ),
              if (hasCustomPhoto) ...[
                const SizedBox(height: 8),
                _buildSheetOption(
                  icon: Icons.delete_outline_rounded,
                  title: 'Gỡ ảnh, dùng chữ cái mặc định',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _selectedPhotoUrl = null;
                      _clearPhoto = true;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color == AppColors.error
                      ? AppColors.error
                      : AppColors.ink,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: AppColors.inkFaint,
            ),
          ],
        ),
      ),
    );
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final cleanPhone = _phoneCtrl.text.replaceAll(RegExp(r'[\s\.\-]'), '');

    String? nameErr;
    String? phoneErr;

    if (name.length < 2) {
      nameErr = 'Họ và tên cần ít nhất 2 ký tự';
    }
    if (cleanPhone.isNotEmpty &&
        !RegExp(r'^(0|\+84)[0-9]{8,10}$').hasMatch(cleanPhone)) {
      phoneErr = 'Số điện thoại chưa đúng định dạng (10 số, bắt đầu bằng 0)';
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
    });

    return nameErr == null && phoneErr == null;
  }

  Future<void> _saveProfile() async {
    if (_isSaving || !_validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthProvider>();
      final cleanPhone = _phoneCtrl.text.replaceAll(RegExp(r'[\s\.\-]'), '');

      await auth.updateProfile(
        name: _nameCtrl.text.trim(),
        phone: cleanPhone,
        photoUrl: _clearPhoto ? null : _selectedPhotoUrl,
        clearPhoto: _clearPhoto,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu thay đổi hồ sơ cá nhân thành công!'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text('$e')),
      );
    }
  }

  Future<void> _sendPasswordReset(String email) async {
    if (_isSendingReset || email.trim().isEmpty) return;
    setState(() => _isSendingReset = true);
    try {
      await context.read<AuthProvider>().sendPasswordReset(email.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi liên kết đổi mật khẩu tới hộp thư $email.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Không thể gửi email đặt lại mật khẩu: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final accent = Theme.of(context).colorScheme.primary;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
        body: const Center(
          child: Text('Vui lòng đăng nhập để chỉnh sửa hồ sơ.'),
        ),
      );
    }

    final liveName = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : user.name;
    final shortUid = user.uid.length > 8
        ? user.uid.substring(0, 8).toUpperCase()
        : user.uid.toUpperCase();
    final hasChanges = _hasChanges(auth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Hồ sơ cá nhân'),
      ),
      body: LiquidAmbientCanvas(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            // 1. Thẻ Avatar & Định danh tài khoản
            LiquidGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showAvatarOptionsSheet(accent),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildAvatarPreview(liveName, accent),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    liveName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      LmStatusPill(
                        text: user.isAdmin
                            ? 'Quản trị viên'
                            : 'Thành viên SmartStore',
                        color: accent,
                        icon: user.isAdmin
                            ? Icons.verified_user_outlined
                            : Icons.verified_outlined,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'ID: #$shortUid',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: accent,
                    ),
                    onPressed: () => _showAvatarOptionsSheet(accent),
                    icon: const Icon(Icons.photo_camera_outlined, size: 16),
                    label: const Text(
                      'Thay đổi ảnh đại diện',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Nhóm Thông tin cá nhân
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'THÔNG TIN CÁ NHÂN',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Họ và tên hiển thị', requiredField: true),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _nameCtrl,
                    hintText: 'Nhập họ và tên của bạn',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    errorText: _nameError,
                    accent: accent,
                    onChanged: (_) {
                      setState(() {
                        if (_nameError != null) _nameError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel('Số điện thoại liên hệ'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _phoneCtrl,
                    hintText: 'Ví dụ: 0912345678',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    errorText: _phoneError,
                    accent: accent,
                    onChanged: (_) {
                      setState(() {
                        if (_phoneError != null) _phoneError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Số điện thoại giúp tự động điền nhanh khi bạn thêm địa chỉ nhận hàng mới.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel('Email đăng nhập'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLightSlate,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mail_outline_rounded,
                          size: 19,
                          color: AppColors.inkMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const LmStatusPill(
                          text: 'Đã xác thực',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Email là định danh tài khoản chính nên không thể thay đổi.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Nhóm Bảo mật & Địa chỉ giao hàng
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'BẢO MẬT & ĐỊA CHỈ GIAO HÀNG',
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
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressManagementScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 19,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sổ địa chỉ nhận hàng',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.ink,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Thêm hoặc đổi địa chỉ giao hàng mặc định',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LmStatusPill(
                            text: '${auth.addresses.length} địa chỉ',
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.inkFaint,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 62),
                  InkWell(
                    onTap: _isSendingReset
                        ? null
                        : () => _sendPasswordReset(user.email),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 19,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đổi / Đặt lại mật khẩu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.ink,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Gửi liên kết đặt lại mật khẩu qua Email đăng ký',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isSendingReset)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent,
                              ),
                            )
                          else
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: AppColors.inkFaint,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      foregroundColor: AppColors.inkSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: LiquidPillButton(
                  label: 'Lưu thay đổi',
                  icon: Icons.check_rounded,
                  height: 46,
                  isLoading: _isSaving,
                  onPressed: hasChanges ? _saveProfile : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(String name, Color accent) {
    final path = _clearPhoto ? null : _selectedPhotoUrl?.trim();
    ImageProvider? provider;
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        provider = NetworkImage(path);
      } else if (File(path).existsSync()) {
        provider = FileImage(File(path));
      }
    }

    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 2,
        ),
        image: provider != null
            ? DecorationImage(image: provider, fit: BoxFit.cover)
            : null,
      ),
      child: provider == null
          ? Center(
              child: Text(
                _initialsOf(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFieldLabel(String text, {bool requiredField = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.inkSecondary,
          ),
        ),
        if (requiredField)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required Color accent,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.inkFaint,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 11.5),
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: Icon(prefixIcon, size: 19, color: AppColors.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
    );
  }
}
