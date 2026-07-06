import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/presentation/controllers/power_output_unit_controller.dart';
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

  test('persists the selected power output unit', () async {
    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);

    await firstContainer
        .read(powerOutputUnitControllerProvider.notifier)
        .setUnit(PowerOutputUnit.kw);

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);

    final savedUnit = await secondContainer.read(
      powerOutputUnitControllerProvider.future,
    );

    expect(savedUnit, PowerOutputUnit.kw);
  });
}
