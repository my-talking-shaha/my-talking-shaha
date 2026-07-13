import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

/// Exact color tokens used by the auth presentation.
///
/// These values intentionally mirror the pre-refactoring UI. Keep auth widgets
/// dependent on this palette so their colors can be audited in one place.
abstract final class AuthColors {
  static const background = AppColors.background;
  static const surface = AppColors.surface;
  static const surfaceHigh = AppColors.surfaceHigh;
  static const surfaceHighest = AppColors.surfaceHighest;

  static const border = AppColors.border;
  static const formBorder = Color(0xFF3A4153);

  static const primary = AppColors.primary;
  static const primaryLight = AppColors.primaryLight;

  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textMuted = AppColors.textMuted;
  static const textDisabled = AppColors.textDisabled;

  static const error = AppColors.error;
  static const white = AppColors.white;
  static const black = AppColors.black;
}
