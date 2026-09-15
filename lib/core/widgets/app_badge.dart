import "package:flutter/material.dart";
import "../theme/app_colors.dart";
import "../theme/app_typography.dart";
import "../theme/app_dimensions.dart";

enum BadgeVariant { success, error, warning, info, neutral }

/// Standardized status tag for CRM Pro Field Sales
class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final Color? customColor;
  final Color? customBackgroundColor;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.customColor,
    this.customBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    switch (variant) {
      case BadgeVariant.success:
        textColor = AppColors.success;
        bgColor = AppColors.successLight;
        break;
      case BadgeVariant.error:
        textColor = AppColors.error;
        bgColor = AppColors.errorLight;
        break;
      case BadgeVariant.warning:
        textColor = AppColors.warning;
        bgColor = AppColors.warningLight;
        break;
      case BadgeVariant.info:
        textColor = AppColors.info;
        bgColor = AppColors.infoLight;
        break;
      case BadgeVariant.neutral:
        textColor = AppColors.textSecondary;
        bgColor = AppColors.surfaceTertiary;
        break;
    }

    if (customColor != null) textColor = customColor!;
    if (customBackgroundColor != null) bgColor = customBackgroundColor!;

    return Container(
      height: AppDimensions.statusTagHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppDimensions.tagBorderRadius,
      ),
      child: Text(
        label,
        style: AppTypography.statusBadge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
