import "package:flutter/material.dart";
import "../theme/app_colors.dart";
import "../theme/app_dimensions.dart";

/// Standardized 40x40 circular back button with chevron-left
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.backButtonSize,
      height: AppDimensions.backButtonSize,
      child: Material(
        color: backgroundColor ?? AppColors.surfaceReference,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: Center(
            child: Icon(
              Icons.chevron_left_rounded,
              size: 24,
              color: iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
