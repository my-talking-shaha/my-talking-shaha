import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/storage/shared_preferences_provider.dart';

final appThemeControllerProvider =
    AsyncNotifierProvider<AppThemeController, ThemeMode>(
  AppThemeController.new,
  retry: (_, _) => null,
);

final class AppThemeController extends AsyncNotifier<ThemeMode> {
  static const _themeModeKey = 'app_theme_mode';

  @override
  Future<ThemeMode> build() async {
    final savedTheme =
        await ref.watch(sharedPreferencesProvider).getString(_themeModeKey);
    return _themeModeFromName(savedTheme);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final normalizedMode =
        themeMode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
    state = AsyncData(normalizedMode);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_themeModeKey, normalizedMode.name);
  }

  ThemeMode _themeModeFromName(String? name) {
    return name == ThemeMode.light.name ? ThemeMode.light : ThemeMode.dark;
  }
}
