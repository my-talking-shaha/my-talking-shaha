import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

/// Feature-local palette for the chat presentation layer.
///
/// These aliases deliberately preserve the colors used by the original chat
/// implementation while keeping every chat color dependency in one place.
abstract final class ChatColors {
  static const background = AppColors.background;
  static const surfaceHigh = AppColors.surfaceHigh;
  static const border = AppColors.border;
  static const primary = AppColors.primary;
  static const primaryLight = AppColors.primaryLight;
  static const primaryPressed = AppColors.primaryPressed;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textMuted = AppColors.textMuted;
  static const error = AppColors.error;
  static const white = AppColors.white;
  static const black = AppColors.black;
  static const transparent = Colors.transparent;
}
