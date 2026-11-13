import "package:flutter/material.dart";
import "app_colors.dart";

/// Typography scale for CRM Pro Field Sales using Inter font
class AppTypography {
  AppTypography._();

  static const String fontFamily = "Inter";

  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height / fontSize,
      color: color,
    );
  }

  // Display
  static TextStyle displayLarge = _baseStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40,
  );

  static TextStyle displayMedium = _baseStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 36,
  );

  // Headings
  static TextStyle h1 = _baseStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 34,
  );

  static TextStyle h2 = _baseStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 30,
  );

  static TextStyle h3 = _baseStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 26,
  );

  static TextStyle h4 = _baseStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24,
  );

  // Subheadings
  static TextStyle subheadingLarge = _baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22,
  );

  static TextStyle subheadingMedium = _baseStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20,
  );

  // Body
  static TextStyle bodyLarge = _baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24,
  );

  static TextStyle bodyMedium = _baseStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22,
  );

  static TextStyle bodySmall = _baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20,
  );

  // Form Labels & Badges
  static TextStyle formLabel = _baseStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    height: 18,
    color: AppColors.textSecondary,
  );

  static TextStyle statusBadge = _baseStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14,
  );

  // Caption & Micro
  static TextStyle caption = _baseStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16,
    color: AppColors.textTertiary,
  );

  static TextStyle micro = _baseStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 14,
    color: AppColors.textTertiary,
  );

  // Navigation
  static TextStyle navigationLabel = _baseStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 14,
  );

  // Buttons
  static TextStyle buttonPrimary = _baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24,
    color: Colors.white,
  );

  static TextStyle buttonSecondary = _baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20,
    color: AppColors.primary,
  );
}
