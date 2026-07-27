import 'package:flutter/material.dart';

class AppTheme {
  static bool isDarkMode = false;

  // Brand Colors
  static Color get primary => isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF1A365D);
  static Color get primaryContainer => isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFF0F2942);
  static Color get accentBlue => isDarkMode ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
  static Color get primaryFixed => isDarkMode ? const Color(0xFF1D4ED8) : const Color(0xFFD6E3FF);
  static const Color defaultPrimary = Color(0xFF2563EB);

  static Color getAdaptiveColor(Color color) {
    if (!isDarkMode) return color;
    // Map known dark or muted colors to neon / bright luminous pastel equivalents
    if (color.value == 0xFF1A365D || color.value == 0xFF0F2942 || color.value == 0xFF2563EB || color.value == 0xFF1E3A8A || color == Colors.blue || color == Colors.indigo) {
      return const Color(0xFF60A5FA); // Vibrant Sky Azure
    }
    if (color == Colors.teal || color.value == 0xFF0D9488 || color.value == 0xFF00AED6) {
      return const Color(0xFF2DD4BF); // Luminous Teal / Cyan
    }
    if (color == Colors.orange || color.value == 0xFFEA580C || color.value == 0xFFF59E0B || color.value == 0xFFB45309) {
      return const Color(0xFFFBBF24); // Neon Luminous Amber/Gold
    }
    if (color.value == 0xFF10B981 || color == Colors.green || color.value == 0xFF059669) {
      return const Color(0xFF34D399); // Luminous Emerald Green
    }
    if (color.value == 0xFFEF4444 || color == Colors.red || color.value == 0xFFDC2626) {
      return const Color(0xFFF87171); // Vibrant Rose Coral
    }
    if (color.value == 0xFF8B5CF6 || color == Colors.purple || color.value == 0xFF7C3AED) {
      return const Color(0xFFA78BFA); // Luminous Neon Lavender
    }
    if (color.value == 0xFFEC4899 || color == Colors.pink || color.value == 0xFFDB2777) {
      return const Color(0xFFF472B6); // Luminous Pink
    }
    // General mathematical brightness lift for any low-lightness color in Dark Mode
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.68 && hsl.saturation > 0.1) {
      return hsl.withLightness(0.72).toColor();
    }
    return color;
  }

  // Semantic Colors
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color pinkAccent = Color(0xFFEC4899);

  // Surface and Background Colors (Onyx #020202 for Dark Mode)
  static Color get background => isDarkMode ? const Color(0xFF020202) : const Color(0xFFF8F9FF);
  static Color get surface => isDarkMode ? const Color(0xFF0E1520) : const Color(0xFFFFFFFF);
  static Color get surfaceContainer => isDarkMode ? const Color(0xFF1A2638) : const Color(0xFFE5EEFF);
  static Color get surfaceContainerLow => isDarkMode ? const Color(0xFF141D2C) : const Color(0xFFEFF4FF);
  static Color get surfaceContainerLowest => isDarkMode ? const Color(0xFF0C121A) : const Color(0xFFFFFFFF);
  static Color get surfaceVariant => isDarkMode ? const Color(0xFF1E2D42) : const Color(0xFFD3E4FE);

  // Text Colors
  static Color get textPrimary => isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0B1C30);
  static Color get textSecondary => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF555F70);
  static Color get textLight => isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border Colors
  static Color get outlineVariant => isDarkMode ? const Color(0xFF1E2E44) : const Color(0xFFE2E8F0);

  // Shadows
  static List<BoxShadow> get cardShadow => isDarkMode
      ? [
          const BoxShadow(
            color: Color(0x40000000), // rgba(0, 0, 0, 0.25)
            blurRadius: 20,
            offset: Offset(0, 4),
          )
        ]
      : const [
          BoxShadow(
            color: Color(0x0A002045), // rgba(0, 32, 69, 0.04)
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ];

  static List<BoxShadow> get primaryCardShadow => isDarkMode
      ? [
          const BoxShadow(
            color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
            blurRadius: 32,
            offset: Offset(0, 12),
          )
        ]
      : const [
          BoxShadow(
            color: Color(0x1F002045), // rgba(0, 32, 69, 0.12)
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ];

  static List<BoxShadow> get fabShadow => isDarkMode
      ? const [
          BoxShadow(
            color: Color(0x6660A5FA), // rgba(96, 165, 250, 0.4) for luminous glowing button in night mode
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x4D1A365D), // rgba(26, 54, 93, 0.3)
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ];

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: isDarkMode
          ? ColorScheme.dark(
              primary: primary,
              secondary: accentBlue,
              surface: surface,
              error: expenseRed,
              onPrimary: textOnPrimary,
              onSurface: textPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: accentBlue,
              surface: surface,
              error: expenseRed,
              onPrimary: textOnPrimary,
              onSurface: textPrimary,
            ),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? textPrimary : primary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
