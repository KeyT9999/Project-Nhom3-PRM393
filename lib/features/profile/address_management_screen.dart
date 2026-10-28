import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/models/address_model.dart';
import '../../providers/auth_provider.dart';

/// Mở Bottom Sheet thêm hoặc chỉnh sửa địa chỉ nhận hàng chuẩn Mobile E-Commerce.
/// Trả về [AddressModel] vừa lưu, hoặc `null` nếu người dùng đóng hộp thoại.
Future<AddressModel?> showAddressFormSheet(
  BuildContext context, {
  AddressModel? existing,
}) {
  return showModalBottomSheet<AddressModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddressFormSheet(existing: existing),
  );
}

class _AddressFormSheet extends StatefulWidget {
  final AddressModel? existing;

  const _AddressFormSheet({this.existing});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  static const List<String> _quickAreas = [
    'Đà Nẵng',
    'TP. Hồ Chí Minh',
    'Hà Nội',
    'Cần Thơ',
  ];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _streetCtrl;

  late bool _isDefault;
  bool _isSaving = false;
  String? _nameError;
  String? _phoneError;
  String? _areaError;
  String? _streetError;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final existing = widget.existing;

    String initialName = '';
    String initialPhone = '';
    String initialStreet = '';
    String initialArea = '';

    if (existing != null) {
      initialName = existing.fullName;
      initialPhone = existing.phone;
      final rawLine = existing.addressLine.trim();
      final commaIdx = rawLine.indexOf(',');
      if (commaIdx > 0 && commaIdx < rawLine.length - 1) {
        initialStreet = rawLine.substring(0, commaIdx).trim();
        initialArea = rawLine.substring(commaIdx + 1).trim();
      } else {
        initialStreet = rawLine;
      }
    } else if (user != null) {
      initialName = user.name.trim();
      final cleanPhone = user.phone.trim();
      if (cleanPhone.isNotEmpty && cleanPhone != '0901234567') {
        initialPhone = cleanPhone;
      }
    }

    _nameCtrl = TextEditingController(text: initialName);
    _phoneCtrl = TextEditingController(text: initialPhone);
    _areaCtrl = TextEditingController(text: initialArea);
    _streetCtrl = TextEditingController(text: initialStreet);
    _isDefault = existing?.isDefault ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _areaCtrl.dispose();
    _streetCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final rawPhone = _phoneCtrl.text.replaceAll(RegExp(r'[\s\.\-]'), '');
    final area = _areaCtrl.text.trim();
    final street = _streetCtrl.text.trim();

    String? nameErr;
    String? phoneErr;
    String? areaErr;
    String? streetErr;

    if (name.length < 2) {
      nameErr = 'Vui lòng nhập họ và tên người nhận';
    }
    if (!RegExp(r'^(0|\+84)[0-9]{8,10}$').hasMatch(rawPhone)) {
      phoneErr = 'Số điện thoại không hợp lệ (gồm 10 số, bắt đầu bằng 0)';
    }
    if (area.isEmpty && widget.existing == null) {
      areaErr = 'Vui lòng nhập Tỉnh/Thành phố, Quận/Huyện, Phường/Xã';
    }
    if (street.length < 3) {
      streetErr = 'Vui lòng nhập số nhà, tên đường hoặc tòa nhà cụ thể';
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
      _areaError = areaErr;
      _streetError = streetErr;
    });

    return nameErr == null &&
        phoneErr == null &&
        areaErr == null &&
        streetErr == null;
  }

  Future<void> _save() async {
    if (_isSaving || !_validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isSaving = true);
    final street = _streetCtrl.text.trim();
    final area = _areaCtrl.text.trim();
    final fullAddress = [
      street,
      if (area.isNotEmpty) area,
    ].join(', ');

    final auth = context.read<AuthProvider>();
    final forceDefault = auth.addresses.isEmpty;

    final addr = AddressModel(
      id:
          widget.existing?.id ??
          'addr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.replaceAll(RegExp(r'[\s\.\-]'), ''),
      addressLine: fullAddress,
      isDefault: forceDefault ? true : _isDefault,
    );

    await auth.addOrUpdateAddress(addr);
    if (!mounted) return;
    Navigator.of(context).pop(addr);
  }

  void _applyQuickCity(String city) {
    HapticFeedback.selectionClick();
    final current = _areaCtrl.text.trim();
    if (current.isEmpty) {
      _areaCtrl.text = city;
    } else if (!current.toLowerCase().contains(city.toLowerCase())) {
      _areaCtrl.text = '$current, $city';
    }
    _areaCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _areaCtrl.text.length),
    );
    if (_areaError != null) {
      setState(() => _areaError = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final auth = context.watch<AuthProvider>();
    final isFirstAddress = auth.addresses.isEmpty && widget.existing == null;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh nắm kéo (Drag Handle)
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

              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      widget.existing == null
                          ? Icons.add_location_alt_outlined
                          : Icons.edit_location_alt_outlined,
                      color: accent,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existing == null
                              ? 'Thêm địa chỉ nhận hàng'
                              : 'Cập nhật địa chỉ nhận hàng',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Thông tin dùng để giao sản phẩm tận tay bạn',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.inkMuted,
                      size: 21,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // 1. Họ và tên người nhận
              _buildFieldLabel('Họ và tên người nhận'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nameCtrl,
                hintText: 'Ví dụ: Trần Kim Thắng',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                errorText: _nameError,
                accent: accent,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 14),

              // 2. Số điện thoại
              _buildFieldLabel('Số điện thoại liên hệ'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _phoneCtrl,
                hintText: 'Ví dụ: 0912345678',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                errorText: _phoneError,
                accent: accent,
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),
              const SizedBox(height: 14),

              // 3. Khu vực Tỉnh/Thành, Quận/Huyện, Phường/Xã
              _buildFieldLabel('Tỉnh/Thành phố, Quận/Huyện, Phường/Xã'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _areaCtrl,
                hintText: 'VD: Phường Hòa Hải, Quận Ngũ Hành Sơn, Đà Nẵng',
                prefixIcon: Icons.map_outlined,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                errorText: _areaError,
                accent: accent,
                onChanged: (_) {
                  if (_areaError != null) setState(() => _areaError = null);
                },
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Chọn nhanh:',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ..._quickAreas.map(
                      (city) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => _applyQuickCity(city),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '+ $city',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Số nhà, tên đường cụ thể
              _buildFieldLabel('Địa chỉ cụ thể (Số nhà, tên đường, tòa nhà)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _streetCtrl,
                hintText: 'VD: Số 18 Khu đô thị FPT City',
                prefixIcon: Icons.home_work_outlined,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                errorText: _streetError,
                accent: accent,
                onChanged: (_) {
                  if (_streetError != null) setState(() => _streetError = null);
                },
              ),
              const SizedBox(height: 14),

              // 5. Đặt làm địa chỉ mặc định
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 19,
                      color: (isFirstAddress || _isDefault)
                          ? accent
                          : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đặt làm địa chỉ mặc định',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            isFirstAddress
                                ? 'Địa chỉ đầu tiên sẽ tự động dùng làm mặc định'
                                : 'Tự động chọn địa chỉ này khi thanh toán',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isFirstAddress ? true : _isDefault,
                      activeTrackColor: accent,
                      onChanged: isFirstAddress
                          ? null
                          : (v) => setState(() => _isDefault = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 6. Hàng nút Hủy & Lưu địa chỉ chia ngang cân đối
              Row(
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
                      label: widget.existing == null
                          ? 'Lưu địa chỉ'
                          : 'Cập nhật địa chỉ',
                      icon: Icons.check_rounded,
                      height: 46,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSecondary,
            ),
          ),
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required Color accent,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
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

class AddressManagementScreen extends StatelessWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final addresses = auth.addresses;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sổ địa chỉ nhận hàng')),
      body: LiquidAmbientCanvas(
        child: addresses.isEmpty
            ? _buildEmptyState(context, accent)
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                itemCount: addresses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  return LiquidGlassCard(
                    isSelected: addr.isDefault,
                    padding: const EdgeInsets.all(15),
                    onTap: () => auth.setDefaultAddress(addr.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: addr.isDefault
                                    ? accent.withValues(alpha: 0.12)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                addr.isDefault
                                    ? Icons.location_on_rounded
                                    : Icons.location_on_outlined,
                                size: 20,
                                color: addr.isDefault
                                    ? accent
                                    : AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          addr.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        addr.phone,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.inkSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    addr.addressLine,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (addr.isDefault) ...[
                              const SizedBox(width: 8),
                              LmStatusPill(
                                text: 'Mặc định',
                                color: accent,
                              ),
                            ],
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 12, bottom: 4),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!addr.isDefault)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: accent,
                                ),
                                onPressed: () =>
                                    auth.setDefaultAddress(addr.id),
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Đặt mặc định',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppColors.inkSecondary,
                              ),
                              onPressed: () =>
                                  showAddressFormSheet(context, existing: addr),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text(
                                'Sửa',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppColors.error,
                              ),
                              onPressed: () => auth.deleteAddress(addr.id),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Xóa',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: addresses.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: LiquidPillButton(
                  label: 'Thêm địa chỉ nhận hàng mới',
                  icon: Icons.add_location_alt_outlined,
                  onPressed: () => showAddressFormSheet(context),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: LiquidGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_location_alt_outlined,
                  size: 32,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có địa chỉ nhận hàng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Thêm họ tên, số điện thoại và địa chỉ giao hàng để đặt mua điện thoại nhanh chóng hơn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              LiquidPillButton(
                label: 'Thêm địa chỉ nhận hàng ngay',
                icon: Icons.add_rounded,
                height: 46,
                width: double.infinity,
                onPressed: () => showAddressFormSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
