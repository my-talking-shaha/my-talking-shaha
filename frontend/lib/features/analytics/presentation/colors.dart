import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

/// Color contract for the analytics presentation layer.
///
/// These aliases intentionally preserve the original analytics palette while
/// keeping every feature color reference in one place.
abstract final class AnalyticsColors {
  static const background = AppColors.background;
  static const backgroundDark = AppColors.backgroundDark;
  static const surface = AppColors.surface;
  static const surfaceHigh = AppColors.surfaceHigh;
  static const border = AppColors.border;
  static const primaryLight = AppColors.primaryLight;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textMuted = AppColors.textMuted;
  static const success = AppColors.success;
  static const warning = AppColors.warning;
  static const transparent = Colors.transparent;
}
