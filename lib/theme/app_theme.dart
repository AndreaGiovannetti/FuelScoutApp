import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color bg          = Color(0xFF0B0D12);
  static const Color surface     = Color(0xFF13161F);
  static const Color surfaceAlt  = Color(0xFF1C2030);
  static const Color card        = Color(0xFF181B27);
  static const Color cardBorder  = Color(0xFF252A3A);

  static const Color amber       = Color(0xFFFF6B00);
  static const Color amberLight  = Color(0xFFFF8C33);
  static const Color amberGlow   = Color(0x40FF6B00);

  static const Color cyan        = Color(0xFF00D4FF);
  static const Color cyanGlow    = Color(0x3000D4FF);

  static const Color green       = Color(0xFF00E676);
  static const Color greenGlow   = Color(0x3000E676);

  static const Color red         = Color(0xFFFF3D3D);
  static const Color redGlow     = Color(0x40FF3D3D);

  static const Color textPrimary   = Color(0xFFF0F2F8);
  static const Color textSecondary = Color(0xFF8B91A8);
  static const Color textMuted     = Color(0xFF4A5068);

  // Fuel type colours
  static const Color diesel  = Color(0xFF4FC3F7);
  static const Color gasoline = Color(0xFFFFD54F);
  static const Color lpg     = Color(0xFFAED581);
  static const Color electric = Color(0xFF64FFDA);

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
    displayLarge: _syne(48, FontWeight.w800, textPrimary),
    displayMedium: _syne(36, FontWeight.w700, textPrimary),
    displaySmall: _syne(28, FontWeight.w700, textPrimary),
    headlineLarge: _syne(24, FontWeight.w700, textPrimary),
    headlineMedium: _syne(20, FontWeight.w600, textPrimary),
    headlineSmall: _syne(18, FontWeight.w600, textPrimary),
    titleLarge: _dm(18, FontWeight.w600, textPrimary),
    titleMedium: _dm(16, FontWeight.w500, textPrimary),
    titleSmall: _dm(14, FontWeight.w500, textPrimary),
    bodyLarge: _dm(16, FontWeight.w400, textSecondary),
    bodyMedium: _dm(14, FontWeight.w400, textSecondary),
    bodySmall: _dm(12, FontWeight.w400, textMuted),
    labelLarge: _dm(14, FontWeight.w600, textPrimary),
    labelMedium: _dm(12, FontWeight.w600, textSecondary),
    labelSmall: _dm(10, FontWeight.w600, textMuted, letterSpacing: 1.2),
  );

  static TextStyle _syne(double size, FontWeight weight, Color color, {double letterSpacing = 0}) =>
      TextStyle(fontFamily: 'Syne', fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);

  static TextStyle _dm(double size, FontWeight weight, Color color, {double letterSpacing = 0}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: amber,
      secondary: cyan,
      surface: surface,
      error: red,
      onPrimary: bg,
      onSecondary: bg,
      onSurface: textPrimary,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: _syne(20, FontWeight.w700, textPrimary),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: amber, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: _dm(15, FontWeight.w400, textMuted),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: amber,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: cardBorder, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceAlt,
      contentTextStyle: _dm(14, FontWeight.w500, textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient amberGradient = LinearGradient(
    colors: [amber, Color(0xFFFF9A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [cyan, Color(0xFF0099CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bg, Color(0xFF0E1018)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1E2E), Color(0xFF13161F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get amberShadow => [
    BoxShadow(color: amber.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get cyanShadow => [
    BoxShadow(color: cyan.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8)),
  ];
}
