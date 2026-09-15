import "package:flutter/material.dart";
import "../theme/app_colors.dart";
import "../theme/app_typography.dart";
import "../theme/app_dimensions.dart";

/// Primary and secondary standardized buttons for CRM Pro Field Sales
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isFullWidth;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.isFullWidth = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final childWidget = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isSecondary ? AppColors.primary : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: isSecondary
                    ? AppTypography.buttonSecondary
                    : AppTypography.buttonPrimary,
              ),
            ],
          );

    final buttonWidget = SizedBox(
      height: AppDimensions.buttonHeight,
      width: isFullWidth ? double.infinity : null,
      child: isSecondary
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.buttonBorderRadius,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: childWidget,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.buttonBorderRadius,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 0,
              ),
              child: childWidget,
            ),
    );

    return buttonWidget;
  }
}
