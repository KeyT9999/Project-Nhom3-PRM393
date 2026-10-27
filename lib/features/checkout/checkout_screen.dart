import 'package:flutter/material.dart';
import '../../core/utils/product_display.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/config/env_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/services/payos_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/models/address_model.dart';
import '../../data/models/coupon_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../profile/address_management_screen.dart';
import 'order_success_screen.dart';
import 'payos_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _couponCtrl = TextEditingController();
  CouponModel? _appliedCoupon;
  bool _requireBiometric = false;
  String _paymentMethod = 'cod'; // 'cod' | 'payos'
  bool _isCreatingPayosLink = false;
  late String _requestId;

  @override
  void initState() {
    super.initState();
    _requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    EnvConfig.load();
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  void _applyCoupon(String code) {
    final subtotal = context.read<CartProvider>().subtotalVnd;
    final coupon = context.read<ProductProvider>().validateCoupon(
      code,
      subtotal,
    );
    setState(() {
      _couponCtrl.text = code;
      _appliedCoupon = coupon;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          coupon != null
              ? 'Đã áp dụng mã ${coupon.code}: Giảm ${CurrencyFormatter.formatVnd(coupon.discountVnd)}!'
              : 'Mã giảm giá không hợp lệ hoặc chưa đủ giá trị đơn tối thiểu.',
        ),
      ),
    );
  }

  Future<bool> _verifyBiometricIfNeeded() async {
    if (!_requireBiometric) return true;
    try {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      if (!canCheck) return false;
      return await auth.authenticate(
        localizedReason:
            'Xác thực sinh trắc học để xác nhận đặt đơn hàng SmartStore',
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> _showPayosConfigDialog() async {
    await EnvConfig.load(forceReload: true);
    if (!mounted) return false;

    final clientCtrl = TextEditingController(text: EnvConfig.payosClientId);
    final apiCtrl = TextEditingController(text: EnvConfig.payosApiKey);
    final checksumCtrl = TextEditingController(
      text: EnvConfig.payosChecksumKey,
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu hình khóa PayOS (.env)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn có thể điền trực tiếp vào file .env ở thư mục gốc dự án hoặc dán nhanh tại đây:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clientCtrl,
                decoration: const InputDecoration(
                  labelText: 'PAYOS_CLIENT_ID',
                  hintText: 'Ví dụ: a1b2c3d4-...',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: apiCtrl,
                decoration: const InputDecoration(
                  labelText: 'PAYOS_API_KEY',
                  hintText: 'Ví dụ: e5f6g7h8-...',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: checksumCtrl,
                decoration: const InputDecoration(
                  labelText: 'PAYOS_CHECKSUM_KEY',
                  hintText: 'Chuỗi 64 ký tự hex...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () async {
              await EnvConfig.saveRuntimePayosKeys(
                clientId: clientCtrl.text,
                apiKey: apiCtrl.text,
                checksumKey: checksumCtrl.text,
              );
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop(EnvConfig.isPayosConfigured);
            },
            child: const Text('Lưu cấu hình'),
          ),
        ],
      ),
    );
    setState(() {});
    return saved ?? false;
  }

  Future<void> _submitOrder(AddressModel shippingAddress, int totalVnd) async {
    final cart = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();
    final authProv = context.read<AuthProvider>();
    final notifProv = context.read<NotificationProvider>();
    final prodProv = context.read<ProductProvider>();

    if (cart.items.isEmpty ||
        orderProv.isSubmitting ||
        _isCreatingPayosLink ||
        authProv.isOfflineSimulated) {
      return;
    }

    final bioPassed = await _verifyBiometricIfNeeded();
    if (!bioPassed || !mounted) return;

    String paymentStatus = 'unpaid';

    if (_paymentMethod == 'payos') {
      await EnvConfig.load(forceReload: true);
      if (!EnvConfig.isPayosConfigured) {
        final configured = await _showPayosConfigDialog();
        if (!configured || !mounted) return;
      }

      setState(() => _isCreatingPayosLink = true);
      try {
        final payosOrderCode =
            DateTime.now().millisecondsSinceEpoch % 1000000000;
        final linkData = await PayosService.createPaymentLink(
          orderCode: payosOrderCode,
          amount: totalVnd,
          description: 'SMARTSTORE $payosOrderCode',
          items: cart.items
              .map(
                (e) => {
                  'name': e.productName,
                  'quantity': e.quantity,
                  'price': e.priceVnd,
                },
              )
              .toList(),
        );
        if (!mounted) return;
        setState(() => _isCreatingPayosLink = false);

        final paid = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PayosPaymentScreen(paymentData: linkData),
          ),
        );
        if (paid != true || !mounted) {
          return;
        }
        paymentStatus = 'paid';
      } catch (e) {
        if (!mounted) return;
        setState(() => _isCreatingPayosLink = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text('$e')),
        );
        return;
      }
    }

    try {
      final order = await orderProv.placeOrder(
        userId: authProv.activeUserId,
        items: cart.items,
        shippingAddress: shippingAddress,
        requestId: _requestId,
        couponCode: _appliedCoupon?.code,
        paymentMethod: _paymentMethod,
        paymentStatus: paymentStatus,
      );

      await cart.clearCart();
      await prodProv.loadProducts();

      notifProv.addNotification(
        title: 'Đặt hàng thành công ${order.orderCode}',
        body: _paymentMethod == 'payos'
            ? 'Đơn hàng ${CurrencyFormatter.formatVnd(order.totalVnd)} đã thanh toán qua PayOS.'
            : 'Đơn hàng ${CurrencyFormatter.formatVnd(order.totalVnd)} đang chờ xác nhận.',
        orderId: order.id,
      );

      try {
        await LocalNotificationService.showOrderNotification(
          id: order.hashCode & 0x7fffffff,
          title: 'Đặt hàng thành công! (${order.orderCode})',
          body: _paymentMethod == 'payos'
              ? 'Đã thanh toán ${CurrencyFormatter.formatVnd(order.totalVnd)} qua PayOS VietQR.'
              : 'Đơn hàng trị giá ${CurrencyFormatter.formatVnd(order.totalVnd)} đang chờ SmartStore xác nhận.',
          orderId: order.id,
        );
      } catch (_) {}

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();
    final coupons = context.watch<ProductProvider>().coupons;

    final selectedAddress = auth.defaultAddress;
    final subtotal = cart.subtotalVnd;
    final shippingFee = subtotal <= 10000
        ? 0
        : AppConstants.defaultShippingFeeVnd;
    final discount = _appliedCoupon?.discountVnd ?? 0;
    final totalVnd = (subtotal + shippingFee - discount).clamp(0, 999999999);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Xác Nhận Đặt Hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LiquidAmbientCanvas(
        animate: true,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Địa chỉ giao hàng (F18)
              LiquidGlassCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Địa Chỉ Nhận Hàng',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: AppColors.ink,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddressManagementScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit_location_alt_outlined,
                            size: 17,
                            color: AppColors.brand700,
                          ),
                          label: const Text(
                            'Thay đổi',
                            style: TextStyle(
                              color: AppColors.brand700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${selectedAddress.fullName} • ${selectedAddress.phone}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAddress.addressLine,
                      style: const TextStyle(
                        color: AppColors.inkSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Tóm tắt sản phẩm trong đơn
              LiquidGlassCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sản Phẩm Đặt Mua (${cart.totalQuantity})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: AppColors.ink,
                      ),
                    ),
                    const Divider(height: 20),
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.quantity}x ${ProductDisplay.shortName(item.productName)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    item.variantLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatVnd(item.lineTotalVnd),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: AppColors.brand700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Mã giảm giá & Voucher (S04)
              LiquidGlassCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mã Giảm Giá / Voucher',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponCtrl,
                            decoration: InputDecoration(
                              hintText: 'Nhập mã (VD: SMART500, PRM393)...',
                              hintStyle: const TextStyle(fontSize: 12.5),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(90, 46),
                          ),
                          onPressed: () => _applyCoupon(_couponCtrl.text),
                          child: const Text(
                            'Áp dụng',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: coupons.map((c) {
                        final isSelected = _appliedCoupon?.code == c.code;
                        return ActionChip(
                          label: Text(
                            '${c.code} (-${CurrencyFormatter.formatVnd(c.discountVnd)})',
                          ),
                          backgroundColor: isSelected
                              ? AppColors.brand700
                              : Colors.white.withValues(alpha: 0.8),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.ink,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => _applyCoupon(c.code),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Phương thức thanh toán (COD / PayOS VietQR) & Sinh trắc học
              LiquidGlassCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Phương Thức Thanh Toán',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: AppColors.ink,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cấu hình khóa PayOS (.env)',
                          icon: Icon(
                            Icons.key_rounded,
                            size: 20,
                            color: EnvConfig.isPayosConfigured
                                ? AppColors.success
                                : AppColors.inkMuted,
                          ),
                          onPressed: _showPayosConfigDialog,
                        ),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => setState(() => _paymentMethod = 'cod'),
                      leading: Icon(
                        _paymentMethod == 'cod'
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _paymentMethod == 'cod'
                            ? AppColors.brand700
                            : AppColors.inkMuted,
                      ),
                      title: const Text(
                        'Thanh toán khi nhận hàng (COD)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Kiểm tra nguyên seal máy trước khi thanh toán',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      trailing: const Icon(Icons.payments_outlined),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => setState(() => _paymentMethod = 'payos'),
                      leading: Icon(
                        _paymentMethod == 'payos'
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _paymentMethod == 'payos'
                            ? AppColors.brand700
                            : AppColors.inkMuted,
                      ),
                      title: const Text(
                        'Chuyển khoản VietQR qua PayOS',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Text(
                        EnvConfig.isPayosConfigured
                            ? 'Tự động tạo mã VietQR & đối soát tức thì'
                            : 'Quét mã VietQR thanh toán thực tế',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: EnvConfig.isPayosConfigured
                              ? AppColors.success
                              : AppColors.inkMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.brand700,
                      ),
                    ),
                    const Divider(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppColors.brand700,
                      title: const Text(
                        'Xác thực vân tay / Face ID',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Bảo mật bổ sung cho đơn hàng giá trị cao',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      value: _requireBiometric,
                      onChanged: (v) => setState(() => _requireBiometric = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Chi tiết thanh toán (S03, S04)
              LiquidGlassCard(
                borderRadius: 20,
                child: Column(
                  children: [
                    _buildPriceRow(
                      'Tạm tính:',
                      CurrencyFormatter.formatVnd(subtotal),
                    ),
                    const SizedBox(height: 6),
                    _buildPriceRow(
                      'Phí vận chuyển:',
                      shippingFee == 0
                          ? 'Miễn phí (0 ₫)'
                          : CurrencyFormatter.formatVnd(shippingFee),
                      valueColor: shippingFee == 0 ? AppColors.success : null,
                    ),
                    if (discount > 0) ...[
                      const SizedBox(height: 6),
                      _buildPriceRow(
                        'Giảm giá Voucher (${_appliedCoupon?.code}):',
                        '-${CurrencyFormatter.formatVnd(discount)}',
                        valueColor: AppColors.success,
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng thanh toán:',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatVnd(totalVnd),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brand700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              LiquidPillButton(
                label: _paymentMethod == 'payos'
                    ? 'Tạo Mã VietQR PayOS & Thanh Toán'
                    : 'Xác Nhận Đặt Hàng Ngay',
                icon: _paymentMethod == 'payos'
                    ? Icons.qr_code_scanner_rounded
                    : Icons.check_circle_outline_rounded,
                isLoading: orderProv.isSubmitting || _isCreatingPayosLink,
                onPressed: () => _submitOrder(selectedAddress, totalVnd),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}
