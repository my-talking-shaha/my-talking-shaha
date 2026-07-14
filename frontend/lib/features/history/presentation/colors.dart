import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

/// Feature-local palette for the history presentation layer.
///
/// Values intentionally delegate to the existing application tokens so the
/// refactor cannot drift from the shipped history design.
abstract final class HistoryColors {
  static const background = AppColors.backgroundDark;
  static const surface = AppColors.surfaceHigh;
  static const surfaceElevated = AppColors.surfaceHighest;
  static const border = AppColors.border;

  static const primary = AppColors.primaryLight;
  static const primarySoft = AppColors.primarySoft;
  static const primaryPressed = AppColors.primaryPressed;
  static const onPrimary = Color(0xFF002388);

  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textMuted = AppColors.textMuted;
  static const white = AppColors.white;

  static const warning = AppColors.warningStrong;
  static const error = AppColors.error;
  static const destructive = AppColors.destructive;
  static const transparent = Colors.transparent;
}
