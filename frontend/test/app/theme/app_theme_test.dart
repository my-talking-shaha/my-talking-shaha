import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';

void main() {
  test('dark theme keeps the shipped application palette', () {
    final theme = AppTheme.dark;

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(theme.colorScheme.onSurface, AppColors.textPrimary);
  });

  test('light theme maps shared components to the light palette', () {
    final theme = AppTheme.light;

    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, AppLightColors.background);
    expect(theme.colorScheme.primary, AppLightColors.primary);
    expect(theme.colorScheme.surface, AppLightColors.surface);
    expect(theme.colorScheme.onSurface, AppLightColors.textPrimary);
    expect(theme.appBarTheme.backgroundColor, AppLightColors.background);
    expect(theme.cardTheme.color, AppLightColors.surface);
    expect(theme.inputDecorationTheme.fillColor, AppLightColors.surfaceHigh);
    expect(theme.bottomSheetTheme.backgroundColor, AppLightColors.surface);
  });
}
