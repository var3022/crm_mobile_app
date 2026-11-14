import "package:flutter/material.dart";

/// Spacing system based on 8-point grid for CRM Pro Field Sales
class AppSpacing {
  AppSpacing._();

  static const double xs4 = 4.0;
  static const double sm8 = 8.0;
  static const double md12 = 12.0;
  static const double lg16 = 16.0;
  static const double xl20 = 20.0;
  static const double xxl24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;

  // Screen level paddings
  static const double screenHorizontal = 20.0;
  static const double contentArea = 24.0;
  static const double cardPadding = 16.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );
  static const EdgeInsets contentPadding = EdgeInsets.all(contentArea);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
}
