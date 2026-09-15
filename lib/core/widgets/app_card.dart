import "package:flutter/material.dart";
import "../theme/app_colors.dart";
import "../theme/app_dimensions.dart";
import "../theme/app_spacing.dart";

/// Standardized card container for CRM Pro Field Sales
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.surfaceReference,
      borderRadius: AppDimensions.cardBorderRadius,
      border: border,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.cardBorderRadius,
          child: Ink(
            padding: padding ?? AppSpacing.cardInsets,
            decoration: decoration,
            child: child,
          ),
        ),
      );
    }

    return Container(
      padding: padding ?? AppSpacing.cardInsets,
      decoration: decoration,
      child: child,
    );
  }
}
