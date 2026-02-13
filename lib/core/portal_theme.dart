import 'package:flutter/material.dart';

/// Design tokens aligned with design/assets/styles.css and portal mocks.
abstract final class PortalTheme {
  // Celadon primary (from CSS --primary-*)
  static const Color primary50 = Color(0xFFf0f9f4);
  static const Color primary100 = Color(0xFFdcf2e3);
  static const Color primary500 = Color(0xFF3a9662);
  static const Color primary600 = Color(0xFF2a7850);
  static const Color primary700 = Color(0xFF236042);

  // Grays
  static const Color gray50 = Color(0xFFf9fafb);
  static const Color gray100 = Color(0xFFf3f4f6);
  static const Color gray200 = Color(0xFFe5e7eb);
  static const Color gray400 = Color(0xFF9ca3af);
  static const Color gray500 = Color(0xFF6b7280);
  static const Color gray600 = Color(0xFF4b5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);

  // Spacing (4px base: 4,8,12,16,24,32,48)
  static const double spacing1 = 4;
  static const double spacing2 = 8;
  static const double spacing3 = 12;
  static const double spacing4 = 16;
  static const double spacing6 = 24;
  static const double spacing12 = 48;

  // Radius
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusFull = 9999;

  // Typography
  static const double fontSizeSm = 14;
  static const double fontSizeBase = 16;
  static const double fontSizeXl = 20;
}
