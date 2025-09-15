import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 40.0;

  // Radii
  static const double borderRadius = 16.0;
  static const double cardRadius = 16.0;

  // Icons
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 28.0;

  // Breakpoints
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
}

extension ContextSpacing on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
}