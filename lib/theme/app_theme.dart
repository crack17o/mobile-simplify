import 'package:flutter/material.dart';

/// Style premium fintech : fond #000000, or #D09915, blanc pour contraste.
class AppTheme {
  AppTheme._();

  // Or accent (CTA, montants, indicateurs) — #D09915
  static const Color primary = Color(0xFFD09915);
  static const Color primaryForeground = Color(0xFF000000);

  // Success / crédit
  static const Color success = Color(0xFF2E7D32);
  static const Color successForeground = Color(0xFFFFFFFF);

  // Destructive
  static const Color destructive = Color(0xFFE53935);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  // Warning
  static const Color warning = Color(0xFFF9A825);
  static const Color warningForeground = Color(0xFF000000);

  // Fond principal et navbar
  static const Color surfaceDark = Color(0xFF000000);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardDarkElevated = Color(0xFF262626);

  static const Color sidebarBackground = Color(0xFF000000);
  static const Color sidebarForeground = Color(0xFFFFFFFF);

  // Radius comme le site (0.75rem ≈ 12)
  static const double radius = 12.0;
  static const double radiusSmall = 8.0;
  static const double radiusLarge = 20.0;

  // Ombres légères pour donner du relief
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: primaryForeground,
        secondary: const Color(0xFFF5F5F5),
        onSecondary: Colors.black87,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: destructive,
        onError: destructiveForeground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: sidebarBackground,
        foregroundColor: sidebarForeground,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      fontFamily: 'Montserrat',
    );
  }
}
