import 'dart:convert';

import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LiveTripStorage {
  Future<LiveTripSession?> read();

  Future<void> write(LiveTripSession session);

  Future<void> clear();
}

final class SharedPreferencesLiveTripStorage implements LiveTripStorage {
  const SharedPreferencesLiveTripStorage(this._preferences);

  static const storageKey = 'history_active_live_trip';

  final SharedPreferencesAsync _preferences;

  @override
  Future<LiveTripSession?> read() async {
    final encoded = await _preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final json = jsonDecode(encoded);
      if (json is! Map<String, dynamic>) return _discardInvalidValue();

      final vehicleId = json['vehicleId'];
      final vehicleName = json['vehicleName'];
      final startMileageKm = json['startMileageKm'];
      final startedAt = DateTime.tryParse(json['startedAt'] as String? ?? '');
      if (vehicleId is! String ||
          vehicleId.isEmpty ||
          startMileageKm is! int ||
          startMileageKm < 0 ||
          startedAt == null) {
        return _discardInvalidValue();
      }

      return LiveTripSession(
        vehicleId: vehicleId,
        // Trips persisted before vehicle names were added remain restorable.
        vehicleName: vehicleName is String ? vehicleName.trim() : '',
        startMileageKm: startMileageKm,
        startedAt: startedAt,
      );
    } on FormatException {
      return _discardInvalidValue();
    }
  }

  @override
  Future<void> write(LiveTripSession session) {
    return _preferences.setString(
      storageKey,
      jsonEncode({
        'vehicleId': session.vehicleId,
        'vehicleName': session.vehicleName,
        'startMileageKm': session.startMileageKm,
        'startedAt': session.startedAt.toUtc().toIso8601String(),
      }),
    );
  }

  @override
  Future<void> clear() => _preferences.remove(storageKey);

  Future<LiveTripSession?> _discardInvalidValue() async {
    await clear();
    return null;
  }
}
