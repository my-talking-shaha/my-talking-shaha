import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

/// Colors owned and used directly by the dashboard presentation layer.
///
/// Keep these aliases and feature-specific values stable: they form the
/// dashboard's visual regression contract independently of widget structure.
abstract final class DashboardColors {
  static const Color background = AppColors.background;
  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color surface = AppColors.surfaceHigh;
  static const Color surfaceHighest = AppColors.surfaceHighest;
  static const Color border = AppColors.border;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  static const Color textDisabled = AppColors.textDisabled;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;

  static const Color transparent = Color(0x00000000);
  static const Color heroOverlay = Color(0xE610131A);
  static const Color heroGradientStart = Color(0xFF102B3B);
  static const Color heroGradientMiddle = Color(0xFF131B31);
  static const Color heroGradientEnd = Color(0xFF10131A);
  static const Color fuelEventBackground = Color(0xFF30291F);
  static const Color maintenanceEventBackground = Color(0xFF123138);
}
