import 'package:flutter/material.dart';

/// Colors owned and used directly by the dashboard presentation layer.
///
/// Keep these aliases and feature-specific values stable: they form the
/// dashboard's visual regression contract independently of widget structure.
abstract final class DashboardColors {
  static const Color background = Color(0xFF10131A);
  static const Color primary = Color(0xFF2E5BFF);
  static const Color primaryLight = Color(0xFFB8C3FF);
  static const Color surface = Color(0xFF1C1F25);
  static const Color surfaceHighest = Color(0xFF232731);
  static const Color border = Color(0xFF2B303B);
  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textSecondary = Color(0xFF9AA3B2);
  static const Color textMuted = Color(0xFF6F7788);
  static const Color textDisabled = Color(0xFF4B5263);
  static const Color success = Color(0xFF00DCE5);
  static const Color warning = Color(0xFFE8B950);

  static const Color transparent = Color(0x00000000);
  static const Color heroOverlay = Color(0xE610131A);
  static const Color heroGradientStart = Color(0xFF102B3B);
  static const Color heroGradientMiddle = Color(0xFF131B31);
  static const Color heroGradientEnd = Color(0xFF10131A);
  static const Color fuelEventBackground = Color(0xFF30291F);
  static const Color maintenanceEventBackground = Color(0xFF123138);
}
