import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Construção dos temas Material 3 (claro e escuro) com a identidade
/// visual preto/branco do Vasco e vermelho pontual da Cruz de Malta.
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _base(
        brightness: Brightness.dark,
        background: AppConstants.darkBackground,
        card: AppConstants.darkCard,
        cardAlt: AppConstants.darkCardAlt,
        border: AppConstants.darkBorder,
        onSurface: Colors.white,
        textSecondary: Colors.grey.shade400,
      );

  static ThemeData light() => _base(
        brightness: Brightness.light,
        background: AppConstants.lightBackground,
        card: AppConstants.lightCard,
        cardAlt: AppConstants.lightCardAlt,
        border: AppConstants.lightBorder,
        onSurface: const Color(0xFF1A1A1A),
        textSecondary: Colors.grey.shade600,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color cardAlt,
    required Color border,
    required Color onSurface,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppConstants.vascoRed,
      brightness: brightness,
      surface: background,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(
        primary: isDark ? Colors.white : const Color(0xFF1A1A1A),
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: AppConstants.vascoRed,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: AppConstants.vascoRed.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardAlt,
        contentTextStyle: TextStyle(color: onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: textSecondary,
        indicatorColor: AppConstants.vascoRed,
      ),
    );
  }
}
