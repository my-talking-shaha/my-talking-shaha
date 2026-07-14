import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/datasources/live_trip_activity_datasource.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/live_trip_activity');
  late MethodCall receivedCall;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          receivedCall = call;
          return null;
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('forwards the vehicle name to iOS Live Activity', () async {
    final startedAt = DateTime.utc(2026, 7, 14, 10, 30);
    const datasource = MethodChannelLiveTripActivityDatasource(
      channel: channel,
    );

    await datasource.ensureStarted(
      LiveTripSession(
        vehicleId: 'vehicle_1',
        vehicleName: 'Lada 2107',
        startMileageKm: 120000,
        startedAt: startedAt,
      ),
    );

    expect(receivedCall.method, 'ensureStarted');
    expect(receivedCall.arguments, {
      'vehicleId': 'vehicle_1',
      'vehicleName': 'Lada 2107',
      'startMileageKm': 120000,
      'startedAtMilliseconds': startedAt.millisecondsSinceEpoch,
    });
  });
}
