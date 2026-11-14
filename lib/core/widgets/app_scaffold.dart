import "package:flutter/material.dart";
import "../theme/app_colors.dart";
import "../theme/app_dimensions.dart";

/// Responsive application scaffold for CRM Pro Field Sales
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool applyMaxContentWidth;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.applyMaxContentWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (applyMaxContentWidth) {
      content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: SafeArea(child: content),
      bottomNavigationBar: bottomNavigationBar != null && applyMaxContentWidth
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxContentWidth,
                ),
                child: bottomNavigationBar,
              ),
            )
          : bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
