import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color palette ──────────────────────────────────────────────────────────────
abstract final class AppColors {
  AppColors._();

  // Orange
  static const orangeBright = Color(0xFFF57C00);
  static const orangePrimary = Color(0xFFE65100);
  static const orangeDim = Color(0xFFBF360C);

  // Blue (light / dark variants)
  static const blueLight = Color(0xFF1565C0);
  static const blueDark = Color(0xFF5A7ACD);

  // Light theme surfaces
  static const backgroundLight = Color(0xFFF5F2F2);
  static const surfaceLight = Color(0xFFFFFFFF);

  // Dark theme surfaces
  static const backgroundDark = Color(0xFF1A1410);
  static const surfaceDark = Color(0xFF1E1A17);

  // Neutral
  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF5F6368);
  static const textHintLight = Color(0xFF9AA0A6);
  static const borderLight = Color(0xFFE8EAED);

  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFB0B0B0);

  // Semantic
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFB71C1C);
  static const warning = Color(0xFFF9A825);
}

// ── Text theme helper ──────────────────────────────────────────────────────────
TextTheme _buildTextTheme(Color primary, Color secondary) {
  final sora = GoogleFonts.soraTextTheme().apply(
    bodyColor: primary,
    displayColor: primary,
  );

  return sora.copyWith(
    // Display / headline → Sora (already set above)
    bodyLarge: sora.bodyLarge?.copyWith(color: primary),
    bodyMedium: sora.bodyMedium?.copyWith(color: primary),
    bodySmall: sora.bodySmall?.copyWith(color: secondary),
    labelSmall: sora.labelSmall?.copyWith(color: secondary),
  );
}

// ── Light theme ────────────────────────────────────────────────────────────────
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.orangeBright,
    secondary: AppColors.blueLight,
    surface: AppColors.surfaceLight,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimaryLight,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.backgroundLight,
  textTheme: _buildTextTheme(
    AppColors.textPrimaryLight,
    AppColors.textSecondaryLight,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.orangeBright,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.sora(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.orangeBright,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: const StadiumBorder(),
      elevation: 0,
      textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textSecondaryLight,
      minimumSize: const Size(double.infinity, 50),
      shape: const StadiumBorder(),
      side: const BorderSide(color: AppColors.borderLight),
      textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.orangeBright, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    hintStyle: GoogleFonts.sora(fontSize: 13, color: AppColors.textHintLight),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceLight,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.borderLight),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.borderLight,
    thickness: 1,
    space: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.textPrimaryLight,
    contentTextStyle: GoogleFonts.sora(fontSize: 13, color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.orangeBright,
    unselectedItemColor: AppColors.textHintLight,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);

// ── Dark theme ─────────────────────────────────────────────────────────────────
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.orangeBright,
    secondary: AppColors.blueDark,
    surface: AppColors.surfaceDark,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimaryDark,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  textTheme: _buildTextTheme(
    AppColors.textPrimaryDark,
    AppColors.textSecondaryDark,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.sora(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.orangeBright,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: const StadiumBorder(),
      elevation: 0,
      textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textSecondaryDark,
      minimumSize: const Size(double.infinity, 50),
      shape: const StadiumBorder(),
      side: BorderSide(color: Colors.white.withOpacity(0.15)),
      textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.orangeBright, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    hintStyle: GoogleFonts.sora(
      fontSize: 13,
      color: AppColors.textSecondaryDark,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Colors.white.withOpacity(0.08)),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.white.withOpacity(0.10),
    thickness: 1,
    space: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.surfaceDark,
    contentTextStyle: GoogleFonts.sora(fontSize: 13, color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.orangeBright,
    unselectedItemColor: AppColors.textSecondaryDark,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);
