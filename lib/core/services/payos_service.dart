import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import '../errors/app_exception.dart';

class PayosPaymentLinkData {
  final int orderCode;
  final int amount;
  final String description;
  final String accountNumber;
  final String accountName;
  final String bin;
  final String paymentLinkId;
  final String status;
  final String checkoutUrl;
  final String qrCode;

  const PayosPaymentLinkData({
    required this.orderCode,
    required this.amount,
    required this.description,
    required this.accountNumber,
    required this.accountName,
    required this.bin,
    required this.paymentLinkId,
    required this.status,
    required this.checkoutUrl,
    required this.qrCode,
  });

  factory PayosPaymentLinkData.fromJson(Map<String, dynamic> json) {
    return PayosPaymentLinkData(
      orderCode: (json['orderCode'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      bin: json['bin']?.toString() ?? '',
      paymentLinkId: json['paymentLinkId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      checkoutUrl: json['checkoutUrl']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
    );
  }
}

class PayosService {
  static const String _baseUrl =
      'https://api-merchant.payos.vn/v2/payment-requests';
  static const String _defaultReturnUrl =
      'https://smartstore.prm393.app/payment-success';
  static const String _defaultCancelUrl =
      'https://smartstore.prm393.app/payment-cancel';

  /// Tạo chữ ký HMAC-SHA256 theo đúng chuẩn PayOS v2:
  /// `amount=$amount&cancelUrl=$cancelUrl&description=$description&orderCode=$orderCode&returnUrl=$returnUrl`
  static String createSignature({
    required int amount,
    required String cancelUrl,
    required String description,
    required int orderCode,
    required String returnUrl,
    required String checksumKey,
  }) {
    final rawData =
        'amount=$amount&cancelUrl=$cancelUrl&description=$description&orderCode=$orderCode&returnUrl=$returnUrl';
    final hmac = Hmac(sha256, utf8.encode(checksumKey));
    final digest = hmac.convert(utf8.encode(rawData));
    return digest.toString();
  }

  /// Tạo link thanh toán VietQR thực tế trên PayOS
  static Future<PayosPaymentLinkData> createPaymentLink({
    required int orderCode,
    required int amount,
    required String description,
    List<Map<String, dynamic>> items = const [],
  }) async {
    await EnvConfig.load(forceReload: true);

    if (!EnvConfig.isPayosConfigured) {
      throw const AppException(
        'Chưa cấu hình khóa PayOS trong file .env (PAYOS_CLIENT_ID, PAYOS_API_KEY, PAYOS_CHECKSUM_KEY).',
        code: 'PAYOS_NOT_CONFIGURED',
      );
    }

    // PayOS giới hạn description tối đa 25 ký tự
    final safeDesc = description.trim().length > 25
        ? description.trim().substring(0, 25)
        : description.trim();

    final signature = createSignature(
      amount: amount,
      cancelUrl: _defaultCancelUrl,
      description: safeDesc,
      orderCode: orderCode,
      returnUrl: _defaultReturnUrl,
      checksumKey: EnvConfig.payosChecksumKey,
    );

    final body = <String, dynamic>{
      'orderCode': orderCode,
      'amount': amount,
      'description': safeDesc,
      'cancelUrl': _defaultCancelUrl,
      'returnUrl': _defaultReturnUrl,
      if (items.isNotEmpty) 'items': items,
      'signature': signature,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': EnvConfig.payosClientId,
        'x-api-key': EnvConfig.payosApiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw AppException(
        'Lỗi kết nối PayOS (HTTP ${response.statusCode}): ${response.body}',
        code: 'PAYOS_HTTP_ERROR',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final code = decoded['code']?.toString();
    final desc = decoded['desc']?.toString() ?? 'Lỗi không xác định từ PayOS';

    if (code != '00' || decoded['data'] == null) {
      throw AppException('PayOS từ chối ($code): $desc', code: 'PAYOS_$code');
    }

    return PayosPaymentLinkData.fromJson(
      Map<String, dynamic>.from(decoded['data'] as Map),
    );
  }

  /// Kiểm tra trạng thái thanh toán của đơn hàng trên PayOS (`PENDING`, `PAID`, `CANCELLED`, `EXPIRED`)
  static Future<String> getPaymentStatus(int orderCode) async {
    await EnvConfig.load();
    if (!EnvConfig.isPayosConfigured) return 'PENDING';

    final response = await http.get(
      Uri.parse('$_baseUrl/$orderCode'),
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': EnvConfig.payosClientId,
        'x-api-key': EnvConfig.payosApiKey,
      },
    );

    if (response.statusCode != 200) return 'PENDING';
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['code']?.toString() != '00' || decoded['data'] == null) {
      return 'PENDING';
    }
    final data = Map<String, dynamic>.from(decoded['data'] as Map);
    return data['status']?.toString().toUpperCase() ?? 'PENDING';
  }

  /// Hủy link thanh toán trên PayOS nếu khách hàng đóng màn hình QR
  static Future<void> cancelPaymentLink(int orderCode) async {
    try {
      await EnvConfig.load();
      if (!EnvConfig.isPayosConfigured) return;
      await http.post(
        Uri.parse('$_baseUrl/$orderCode/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'x-client-id': EnvConfig.payosClientId,
          'x-api-key': EnvConfig.payosApiKey,
        },
        body: jsonEncode({'cancellationReason': 'Khach hang huy tren app'}),
      );
    } catch (_) {}
  }
}
