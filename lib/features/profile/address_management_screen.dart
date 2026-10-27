import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/models/address_model.dart';
import '../../providers/auth_provider.dart';

class AddressManagementScreen extends StatelessWidget {
  const AddressManagementScreen({super.key});

  void _showAddressDialog(BuildContext context, {AddressModel? existing}) {
    final nameCtrl = TextEditingController(
      text: existing?.fullName ?? 'Nguyễn Văn A',
    );
    final phoneCtrl = TextEditingController(
      text: existing?.phone ?? '0901234567',
    );
    final lineCtrl = TextEditingController(text: existing?.addressLine ?? '');
    bool isDefault = existing?.isDefault ?? true;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(
                existing == null
                    ? 'Thêm địa chỉ nhận hàng mới'
                    : 'Chỉnh sửa địa chỉ',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên người nhận',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: lineCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ chi tiết (Số nhà, Đường, Quận/TP)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isDefault,
                      title: const Text('Đặt làm địa chỉ mặc định'),
                      onChanged: (v) =>
                          setDialogState(() => isDefault = v ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (lineCtrl.text.trim().isEmpty) return;
                    final addr = AddressModel(
                      id:
                          existing?.id ??
                          'addr_${DateTime.now().millisecondsSinceEpoch}',
                      fullName: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      addressLine: lineCtrl.text.trim(),
                      isDefault: isDefault,
                    );
                    await context.read<AuthProvider>().addOrUpdateAddress(addr);
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Lưu địa chỉ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final addresses = auth.addresses;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Sổ địa chỉ giao hàng')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final addr = addresses[index];
          return LmMaterialCard(
            selected: addr.isDefault,
            onTap: () => auth.setDefaultAddress(addr.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${addr.fullName} • ${addr.phone}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (addr.isDefault)
                      LmStatusPill(
                        text: 'Mặc định',
                        color: accent,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  addr.addressLine,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!addr.isDefault)
                      TextButton(
                        onPressed: () => auth.setDefaultAddress(addr.id),
                        child: const Text('Đặt mặc định'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () =>
                          _showAddressDialog(context, existing: addr),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      onPressed: () => auth.deleteAddress(addr.id),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LmTintedButton(
            label: 'Thêm địa chỉ nhận hàng mới',
            icon: Icons.add_location_alt_outlined,
            onPressed: () => _showAddressDialog(context),
          ),
        ),
      ),
    );
  }
}
