import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "app_colors.dart";
import "app_typography.dart";
import "app_dimensions.dart";

/// Master ThemeData for CRM Pro Field Sales
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        toolbarHeight: 72,
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          textStyle: AppTypography.buttonPrimary,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceReference,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.cardBorderRadius,
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
        trackVisibility: WidgetStatePropertyAll(false),
        interactive: false,
      ),
    );
  }
}
