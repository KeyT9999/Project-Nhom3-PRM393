import 'package:flutter/material.dart';

enum LmThemeType { blue, mono, orange }

class LmPalette {
  final LmThemeType type;
  final String label;
  final List<Color> ramp;
  final Color accent;
  final Color accentDark;
  final Color accentLightBg;
  final Color accentText;
  final Color bg;

  const LmPalette({
    required this.type,
    required this.label,
    required this.ramp,
    required this.accent,
    required this.accentDark,
    required this.accentLightBg,
    required this.accentText,
    required this.bg,
  });

  Color get primary => accent;
  Color get primarySoft => accentLightBg;
}

/// Hệ thống màu sắc trích xuất chuẩn từ `UI DESIGN/scripts/lib/lm-themes.json`
/// và `UI DESIGN/references/project/index.html`
class AppColors {
  AppColors._();

  // Neutral Surface & Typography Tokens (--bg, --surface, --line, --ink, --muted, --faint)
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE3E8F0);
  static const Color line = border;
  static const Color ink = Color(0xFF0B1220);
  static const Color ink2 = Color(0xFF344054);
  static const Color ink3 = Color(0xFF667085);
  static const Color ink4 = Color(0xFF98A2B3);
  static const Color textPrimary = Color(0xFF0B1220);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textFaint = Color(0xFF98A2B3);

  // Default Blue Accent Tokens (--blue, --b600, --b700)
  static const Color primary = Color(0xFF2F6BFF);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryDeep = Color(0xFF1638A8);
  static const Color secondary = Color(0xFF0B1220);

  // Semantic Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color danger = error;
  static const Color errorSoft = Color(0xFFFEE2E2);

  // 3 Bảng màu chuẩn từ UI DESIGN/scripts/lib/lm-themes.json
  static const LmPalette bluePalette = LmPalette(
    type: LmThemeType.blue,
    label: 'Blue (#2F6BFF)',
    ramp: [
      Color(0xFFEAF1FF),
      Color(0xFFC9DAFF),
      Color(0xFF8FB2FF),
      Color(0xFF6E9BFF),
      Color(0xFF4D8DFF),
      Color(0xFF2F6BFF),
      Color(0xFF1D4ED8),
      Color(0xFF1638A8),
    ],
    accent: Color(0xFF2F6BFF),
    accentDark: Color(0xFF1D4ED8),
    accentLightBg: Color(0xFFEAF1FF),
    accentText: Color(0xFF2F6BFF),
    bg: Color(0xFFF8F9FB),
  );

  static const LmPalette monoPalette = LmPalette(
    type: LmThemeType.mono,
    label: 'Mono (#1F1E1C)',
    ramp: [
      Color(0xFFF1F1EF),
      Color(0xFFE3E2DF),
      Color(0xFFC4C3BF),
      Color(0xFFA5A4A0),
      Color(0xFF6E6D69),
      Color(0xFF1F1E1C),
      Color(0xFF121110),
      Color(0xFF000000),
    ],
    accent: Color(0xFF1F1E1C),
    accentDark: Color(0xFF000000),
    accentLightBg: Color(0xFFF1F1EF),
    accentText: Color(0xFF1F1E1C),
    bg: Color(0xFFFAFAFA),
  );

  static const LmPalette orangePalette = LmPalette(
    type: LmThemeType.orange,
    label: 'Orange (#F37021)',
    ramp: [
      Color(0xFFFFF2E9),
      Color(0xFFFFDDC6),
      Color(0xFFFFBE92),
      Color(0xFFFFA672),
      Color(0xFFFF8C4A),
      Color(0xFFF37021),
      Color(0xFFD2550C),
      Color(0xFFA3400A),
    ],
    accent: Color(0xFFF37021),
    accentDark: Color(0xFFD2550C),
    accentLightBg: Color(0xFFFFF2E9),
    accentText: Color(0xFFF37021),
    bg: Color(0xFFFBFAF9),
  );

  static LmPalette paletteOf(LmThemeType type) {
    switch (type) {
      case LmThemeType.mono:
        return monoPalette;
      case LmThemeType.orange:
        return orangePalette;
      case LmThemeType.blue:
        return bluePalette;
    }
  }

  /// Chuyển chuỗi mã màu Hex (VD: '#1C1C1E') thành đối tượng Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    final cleaned = hexString.replaceFirst('#', '').trim();
    if (cleaned.length == 6) buffer.write('ff');
    buffer.write(cleaned);
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFF1C1C1E);
  }
}
