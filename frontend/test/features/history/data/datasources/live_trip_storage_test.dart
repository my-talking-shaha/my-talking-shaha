import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/datasources/live_trip_storage.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
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

  test('persists, restores, and clears the active trip', () async {
    final storage = SharedPreferencesLiveTripStorage(SharedPreferencesAsync());
    final session = LiveTripSession(
      vehicleId: 'vehicle_1',
      vehicleName: 'Lada 2107',
      startMileageKm: 120000,
      startedAt: DateTime.utc(2026, 7, 14, 10, 30),
    );

    await storage.write(session);
    expect(await storage.read(), session);

    await storage.clear();
    expect(await storage.read(), isNull);
  });

  test('discards malformed persisted state', () async {
    final preferences = SharedPreferencesAsync();
    final storage = SharedPreferencesLiveTripStorage(preferences);
    await preferences.setString(
      SharedPreferencesLiveTripStorage.storageKey,
      '{broken',
    );

    expect(await storage.read(), isNull);
    expect(
      await preferences.getString(SharedPreferencesLiveTripStorage.storageKey),
      isNull,
    );
  });

  test('restores a trip persisted before vehicle names were added', () async {
    final preferences = SharedPreferencesAsync();
    final storage = SharedPreferencesLiveTripStorage(preferences);
    await preferences.setString(
      SharedPreferencesLiveTripStorage.storageKey,
      jsonEncode({
        'vehicleId': 'vehicle_1',
        'startMileageKm': 120000,
        'startedAt': '2026-07-14T10:30:00.000Z',
      }),
    );

    final session = await storage.read();

    expect(session?.vehicleName, isEmpty);
    expect(session?.startMileageKm, 120000);
  });
}
