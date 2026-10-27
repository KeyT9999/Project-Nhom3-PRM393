import 'package:flutter/material.dart';

enum LmThemeType { titanium, blue, mono, orange }

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

/// Hệ thống màu sắc trích xuất chuẩn từ `ui_template_kit/styles.css`
/// & tài liệu đặc tả `IphoneDesign/Test_UI.md`
class AppColors {
  AppColors._();

  // Primary Titanium Brand Palette (#243342 - Slate Navy)
  static const Color brand50 = Color(0xFFF0F4F8);
  static const Color brand100 = Color(0xFFD9E2EC);
  static const Color brand200 = Color(0xFFBCCCDC);
  static const Color brand300 = Color(0xFF9FB3C8);
  static const Color brand400 = Color(0xFF627D98);
  static const Color brand500 = Color(0xFF3E566E); // Active / Hover
  static const Color brand600 = Color(0xFF2E3F52);
  static const Color brand700 = Color(0xFF243342); // PRIMARY BRAND (Slate Navy)
  static const Color brand800 = Color(0xFF1A2530);
  static const Color brand900 = Color(0xFF0F1722); // Deep Dark Navy

  // iPhone 16 Pro Titanium Finishes
  static const Color desertTitanium = Color(0xFFD4C8B8);
  static const Color naturalTitanium = Color(0xFF9C968F);
  static const Color whiteTitanium = Color(0xFFF5F5F7);
  static const Color blackTitanium = Color(0xFF28282B);

  // Surfaces & Ink Tokens
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLightSlate = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color line = border;
  static const Color ink = Color(0xFF0F172A);
  static const Color inkSecondary = Color(0xFF334155);
  static const Color inkMuted = Color(0xFF64748B);
  static const Color inkFaint = Color(0xFF94A3B8);
  static const Color ink2 = inkSecondary;
  static const Color ink3 = inkMuted;
  static const Color ink4 = inkFaint;
  static const Color textPrimary = ink;
  static const Color textSecondary = inkMuted;
  static const Color textFaint = inkFaint;

  // Primary Brand Defaults
  static const Color primary = brand700; // #243342
  static const Color primaryDark = brand900; // #0F1722
  static const Color primaryDeep = brand900;
  static const Color primaryHighlight = brand500; // #3E566E
  static const Color secondary = ink;

  // Liquid-Glass Refraction Tokens
  static const double glassBlur = 24.0;
  static const Color glassBorder = Color(0xD9FFFFFF); // rgba(255, 255, 255, 0.85)
  static const Color glassDarkBorder = Color(0x2EFFFFFF); // rgba(255, 255, 255, 0.18)

  // Semantic Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color danger = error;
  static const Color errorSoft = Color(0xFFFEE2E2);

  // Flagship Titanium Slate Navy Palette (#243342) - Default UI Template Kit
  static const LmPalette titaniumPalette = LmPalette(
    type: LmThemeType.titanium,
    label: 'Titanium Slate Navy (#243342)',
    ramp: [
      brand50,
      brand100,
      brand200,
      brand300,
      brand400,
      brand500,
      brand700,
      brand900,
    ],
    accent: brand700,
    accentDark: brand900,
    accentLightBg: brand50,
    accentText: brand700,
    bg: background,
  );

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
      case LmThemeType.titanium:
        return titaniumPalette;
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
