import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? originalPlatform;

  setUp(() {
    originalPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = originalPlatform;
  });

  test('defaults to dark and persists a supported selection', () async {
    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);

    expect(
      await firstContainer.read(appThemeControllerProvider.future),
      ThemeMode.dark,
    );

    await firstContainer
        .read(appThemeControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);
    expect(
      firstContainer.read(appThemeControllerProvider).value,
      ThemeMode.light,
    );
    expect(
      await SharedPreferencesAsync().getString(AppThemeController.storageKey),
      ThemeMode.light.name,
    );

    final restoredContainer = ProviderContainer();
    addTearDown(restoredContainer.dispose);
    expect(
      await restoredContainer.read(appThemeControllerProvider.future),
      ThemeMode.light,
    );
  });
}
