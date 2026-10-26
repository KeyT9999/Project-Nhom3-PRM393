import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/payos_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/lm_glass_widgets.dart';

class PayosPaymentScreen extends StatefulWidget {
  final PayosPaymentLinkData paymentData;

  const PayosPaymentScreen({super.key, required this.paymentData});

  @override
  State<PayosPaymentScreen> createState() => _PayosPaymentScreenState();
}

class _PayosPaymentScreenState extends State<PayosPaymentScreen> {
  Timer? _pollTimer;
  bool _isChecking = false;
  String _currentStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.paymentData.status;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkPaymentStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPaymentStatus({bool manual = false}) async {
    if (_isChecking || !mounted) return;
    setState(() => _isChecking = true);
    try {
      final status = await PayosService.getPaymentStatus(
        widget.paymentData.orderCode,
      );
      if (!mounted) return;
      setState(() => _currentStatus = status);

      if (status == 'PAID') {
        _pollTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'PayOS xác nhận đã nhận tiền thành công! Đang hoàn tất đơn hàng...',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      } else if (status == 'CANCELLED' || status == 'EXPIRED') {
        _pollTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Link thanh toán đã hết hạn hoặc bị hủy ($status).'),
          ),
        );
        Navigator.of(context).pop(false);
      } else if (manual) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trạng thái hiện tại: $status (Đang chờ ngân hàng xác nhận...)',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  void _copyText(String label, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã sao chép $label: $text')));
  }

  Future<void> _openCheckoutUrl() async {
    final uri = Uri.tryParse(widget.paymentData.checkoutUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final data = widget.paymentData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VietQR PayOS'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () async {
            _pollTimer?.cancel();
            await PayosService.cancelPaymentLink(data.orderCode);
            if (!context.mounted) return;
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LmMaterialCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: accent),
                    const SizedBox(width: 8),
                    const Text(
                      'Quét mã VietQR bằng App Ngân hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tự động điền sẵn số tiền & nội dung chuyển khoản',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    data: data.qrCode.isNotEmpty
                        ? data.qrCode
                        : data.checkoutUrl,
                    size: 220,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Đang chờ thanh toán ($_currentStatus) • Tự động kiểm tra 3s/lần',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LmMaterialCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin chuyển khoản PayOS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                const Divider(height: 18),
                _buildInfoRow('Chủ tài khoản:', data.accountName),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Số tài khoản:',
                  data.accountNumber,
                  onCopy: () => _copyText('Số tài khoản', data.accountNumber),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Số tiền:',
                  CurrencyFormatter.formatVnd(data.amount),
                  valueColor: accent,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Nội dung CK:',
                  data.description,
                  onCopy: () =>
                      _copyText('Nội dung chuyển khoản', data.description),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Mã giao dịch PayOS:', '#${data.orderCode}'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LmTintedButton(
            label: 'Tôi đã chuyển khoản • Kiểm tra ngay',
            icon: Icons.verified_rounded,
            isLoading: _isChecking,
            onPressed: () => _checkPaymentStatus(manual: true),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openCheckoutUrl,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Mở trang thanh toán PayOS trên trình duyệt'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: valueColor ?? AppColors.ink,
                  ),
                ),
              ),
              if (onCopy != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onCopy,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.copy_rounded, size: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
