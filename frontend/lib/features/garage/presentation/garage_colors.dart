import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

/// The complete color palette used by the garage presentation layer.
///
/// Values intentionally mirror the pre-refactor UI so moving widgets between
/// files cannot silently change the feature's appearance.
abstract final class GarageColors {
  static const background = AppColors.background;
  static const backgroundDark = AppColors.backgroundDark;
  static const formBackground = Color(0xFF0D111A);

  static const surface = AppColors.surface;
  static const surfaceHighest = AppColors.surfaceHighest;
  static const formField = Color(0xFF20242D);

  static const border = AppColors.border;
  static const formBorder = Color(0xFF3B4252);

  static const primary = AppColors.primary;
  static const formPrimary = Color(0xFF315BFF);
  static const primaryLight = AppColors.primaryLight;
  static const primaryPressed = AppColors.primaryPressed;
  static const primarySoft = AppColors.primarySoft;

  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const hint = Color(0xFF6F7482);
  static const white = AppColors.white;

  static const success = AppColors.success;
  static const error = AppColors.error;
  static const swipeEdit = AppColors.warningStrong;
  static const swipeDelete = AppColors.destructive;
  static const transparent = Colors.transparent;
}
