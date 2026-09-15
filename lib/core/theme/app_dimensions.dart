import "package:flutter/material.dart";

/// Component dimensions and corner radii for CRM Pro Field Sales
class AppDimensions {
  AppDimensions._();

  // Reference Viewport
  static const double referenceWidth = 390.0;
  static const double referenceHeight = 844.0;
  static const double maxContentWidth = 600.0;

  // Corner Radii
  static const double radiusCard = 12.0;
  static const double radiusButton = 12.0;
  static const double radiusInput = 12.0;
  static const double radiusPill = 20.0;
  static const double radiusTag = 6.0;
  static const double radiusCircle = 100.0;
  static const double radiusBackButton = 20.0;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(radiusCard);
  static BorderRadius get buttonBorderRadius => BorderRadius.circular(radiusButton);
  static BorderRadius get inputBorderRadius => BorderRadius.circular(radiusInput);
  static BorderRadius get pillBorderRadius => BorderRadius.circular(radiusPill);
  static BorderRadius get tagBorderRadius => BorderRadius.circular(radiusTag);

  // Component Heights
  static const double buttonHeight = 52.0;
  static const double inputHeight = 50.0;
  static const double filterPillHeight = 32.0;
  static const double statusTagHeight = 20.0;
  static const double backButtonSize = 40.0;
  static const double bottomNavHeight = 89.0;
  static const double bottomNavIconSize = 24.0;
}
