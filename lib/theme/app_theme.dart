import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF1A365D);
  static const Color primaryContainer = Color(0xFF0F2942);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color primaryFixed = Color(0xFFD6E3FF);

  // Semantic Colors
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color pinkAccent = Color(0xFFEC4899);

  // Surface and Background Colors
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFD3E4FE);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF555F70);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color outlineVariant = Color(0xFFE2E8F0);

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A002045), // rgba(0, 32, 69, 0.04)
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> primaryCardShadow = [
    BoxShadow(
      color: Color(0x1F002045), // rgba(0, 32, 69, 0.12)
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> fabShadow = [
    BoxShadow(
      color: Color(0x4D1A365D), // rgba(26, 54, 93, 0.3)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accentBlue,
        surface: surface,
        error: expenseRed,
        onPrimary: textOnPrimary,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto', // Default fallback for clean typography
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
