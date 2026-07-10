import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

/// Color contract for the settings presentation layer.
///
/// These aliases preserve the original settings palette while keeping every
/// feature-owned color reference in one place.
abstract final class SettingsColors {
  static const background = AppColors.background;
  static const surface = AppColors.surface;
  static const surfaceHighest = AppColors.surfaceHighest;
  static const border = AppColors.border;
  static const primary = AppColors.primary;
  static const primaryLight = AppColors.primaryLight;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textMuted = AppColors.textMuted;
  static const textDisabled = AppColors.textDisabled;
  static const white = AppColors.white;
  static const transparent = Colors.transparent;
}
