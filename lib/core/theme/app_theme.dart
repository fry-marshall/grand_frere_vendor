import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData get main => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.maroon,
        ),
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.buttonVertical,
              horizontal: AppSpacing.buttonHorizontal,
            ),
            textStyle: AppTextStyles.buttonLabel,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.maroon,
            side: const BorderSide(color: AppColors.maroon, width: 1.5),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.buttonVertical,
              horizontal: AppSpacing.buttonHorizontal,
            ),
            textStyle: AppTextStyles.buttonLabel,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brown,
            shape: const StadiumBorder(),
            textStyle: AppTextStyles.buttonLabel,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.line, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.line, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.mute),
          errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.inputVertical,
            horizontal: AppSpacing.inputHorizontal,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.line,
          thickness: 1,
          space: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.maroon,
          unselectedItemColor: AppColors.mute,
          selectedLabelStyle: AppTextStyles.tabActive,
          unselectedLabelStyle: AppTextStyles.tabInactive,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );

  static ColorScheme get _colorScheme => ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.gold,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.goldSoft,
        onPrimaryContainer: AppColors.maroon,
        secondary: AppColors.maroon,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.paper,
        onSecondaryContainer: AppColors.ink,
        tertiary: AppColors.violetDeep,
        onTertiary: AppColors.white,
        tertiaryContainer: AppColors.violetSurface,
        onTertiaryContainer: AppColors.violetDeep,
        error: AppColors.danger,
        onError: AppColors.white,
        errorContainer: AppColors.dangerSurface,
        onErrorContainer: AppColors.dangerText,
        surface: AppColors.white,
        onSurface: AppColors.ink,
        surfaceContainerLowest: AppColors.cream,
        surfaceContainer: AppColors.paper,
        outline: AppColors.line,
        outlineVariant: AppColors.paper2,
      );

  static TextTheme get _textTheme => TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        titleLarge: AppTextStyles.h3,
        titleMedium: AppTextStyles.buttonLabel,
        titleSmall: AppTextStyles.buttonSmall,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.cardBody,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.label,
        labelMedium: AppTextStyles.tabActive,
        labelSmall: AppTextStyles.monoSmall,
      );
}
