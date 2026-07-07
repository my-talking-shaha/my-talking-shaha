import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/storage/shared_preferences_provider.dart';

enum PowerOutputUnit {
  hp('hp'),
  kw('kw');

  const PowerOutputUnit(this.value);

  final String value;

  static PowerOutputUnit fromValue(String? value) {
    return switch (value) {
      'kw' => PowerOutputUnit.kw,
      _ => PowerOutputUnit.hp,
    };
  }
}

final powerOutputUnitControllerProvider =
    AsyncNotifierProvider<PowerOutputUnitController, PowerOutputUnit>(
      PowerOutputUnitController.new,
      retry: (_, _) => null,
    );

final class PowerOutputUnitController extends AsyncNotifier<PowerOutputUnit> {
  static const preferenceKey = 'garage_power_output_unit';

  @override
  Future<PowerOutputUnit> build() async {
    final savedUnit = await ref
        .watch(sharedPreferencesProvider)
        .getString(preferenceKey);
    return PowerOutputUnit.fromValue(savedUnit);
  }

  Future<void> setUnit(PowerOutputUnit unit) async {
    state = AsyncData(unit);
    await ref
        .read(sharedPreferencesProvider)
        .setString(preferenceKey, unit.value);
  }
}
