import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6759E8);
  static const secondary = Color(0xFF8B80F9);
  static const lightBackground = Color(0xFFF7F7FB);
  static const darkBackground = Color(0xFF111116);
  static const lightCard = Colors.white;
  static const darkCard = Color(0xFF1C1C24);
  static const success = Color(0xFF24A875);
  static const danger = Color(0xFFE05260);
}

class AppTheme {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: brightness);
    return ThemeData(
      useMaterial3: true, brightness: brightness, colorScheme: scheme,
      scaffoldBackgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBarTheme: AppBarTheme(backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
        foregroundColor: dark ? Colors.white : const Color(0xFF191923), elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(color: dark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: dark ? AppColors.darkCard : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? AppColors.darkCard : Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: .15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
    );
  }
}
