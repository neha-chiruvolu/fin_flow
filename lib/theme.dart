import 'package:flutter/material.dart';

/// Blue + green palette with a mustard accent.
class AppColors {
  static const navy = Color(0xFF0A3D62);
  static const blue = Color(0xFF1B6CA8);
  static const sky = Color(0xFFDCEEF8);
  static const teal = Color(0xFF16A085);
  static const green = Color(0xFF2E9E6B);
  static const mint = Color(0xFFDDF5EA);
  static const mustard = Color(0xFFE0A800);
  static const bg = Color(0xFFF3F8FA);
  static const ink = Color(0xFF12313F);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.blue,
    secondary: AppColors.green,
    tertiary: AppColors.mustard,
    surface: Colors.white,
  );

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.ink,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: border(AppColors.sky),
      enabledBorder: border(AppColors.sky),
      focusedBorder: border(AppColors.blue, 2),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.mustard,
      foregroundColor: AppColors.ink,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.mint,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.mint,
    ),
  );
}

class Breakpoints {
  static bool isMobile(double w) => w < 600;
  static bool isTablet(double w) => w >= 600 && w < 900;
  static bool isDesktop(double w) => w >= 900;
}
