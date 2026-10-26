import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvConfig {
  EnvConfig._();

  static final Map<String, String> _env = {};
  static bool _loaded = false;

  static const String _prefClientId = 'payos_client_id_override';
  static const String _prefApiKey = 'payos_api_key_override';
  static const String _prefChecksumKey = 'payos_checksum_key_override';

  /// Đọc file `.env` từ Flutter Assets và kết hợp với cấu hình lưu cục bộ (nếu có)
  static Future<void> load({bool forceReload = false}) async {
    if (_loaded && !forceReload) return;

    try {
      final raw = await rootBundle.loadString('.env');
      for (final line in raw.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eqIdx = trimmed.indexOf('=');
        if (eqIdx <= 0) continue;
        final key = trimmed.substring(0, eqIdx).trim();
        var value = trimmed.substring(eqIdx + 1).trim();
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        if (value.isNotEmpty) {
          _env[key] = value;
        }
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getString(_prefClientId);
      final apiKey = prefs.getString(_prefApiKey);
      final checksumKey = prefs.getString(_prefChecksumKey);

      if ((_env['PAYOS_CLIENT_ID'] ?? '').isEmpty &&
          clientId != null &&
          clientId.isNotEmpty) {
        _env['PAYOS_CLIENT_ID'] = clientId;
      }
      if ((_env['PAYOS_API_KEY'] ?? '').isEmpty &&
          apiKey != null &&
          apiKey.isNotEmpty) {
        _env['PAYOS_API_KEY'] = apiKey;
      }
      if ((_env['PAYOS_CHECKSUM_KEY'] ?? '').isEmpty &&
          checksumKey != null &&
          checksumKey.isNotEmpty) {
        _env['PAYOS_CHECKSUM_KEY'] = checksumKey;
      }
    } catch (_) {}

    _loaded = true;
  }

  static String get payosClientId => (_env['PAYOS_CLIENT_ID'] ?? '').trim();
  static String get payosApiKey => (_env['PAYOS_API_KEY'] ?? '').trim();
  static String get payosChecksumKey =>
      (_env['PAYOS_CHECKSUM_KEY'] ?? '').trim();

  static bool get isPayosConfigured =>
      payosClientId.isNotEmpty &&
      payosApiKey.isNotEmpty &&
      payosChecksumKey.isNotEmpty &&
      !payosClientId.startsWith('your_');

  /// Cho phép lưu/ghi đè bộ khóa PayOS ngay trong ứng dụng nếu chưa kịp build lại `.env`
  static Future<void> saveRuntimePayosKeys({
    required String clientId,
    required String apiKey,
    required String checksumKey,
  }) async {
    _env['PAYOS_CLIENT_ID'] = clientId.trim();
    _env['PAYOS_API_KEY'] = apiKey.trim();
    _env['PAYOS_CHECKSUM_KEY'] = checksumKey.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefClientId, clientId.trim());
      await prefs.setString(_prefApiKey, apiKey.trim());
      await prefs.setString(_prefChecksumKey, checksumKey.trim());
    } catch (_) {}
  }
}
