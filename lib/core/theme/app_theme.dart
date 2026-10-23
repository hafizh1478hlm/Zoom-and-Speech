import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();
  static const _heading = 'Lexend';
  static const _body = 'AtkinsonHyperlegible';

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: _body,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontFamily: _heading, fontWeight: FontWeight.w700, fontSize: 32, height: 1.2, color: AppColors.textPrimary),
          headlineMedium: TextStyle(fontFamily: _heading, fontWeight: FontWeight.w600, fontSize: 22, height: 1.3, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 18, height: 1.5, color: AppColors.textPrimary),
          labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          bodySmall: TextStyle(fontSize: 16, height: 1.4, color: AppColors.textSecondary),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
}