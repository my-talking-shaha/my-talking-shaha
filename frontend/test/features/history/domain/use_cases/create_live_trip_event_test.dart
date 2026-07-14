import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:frontend/features/history/domain/use_cases/create_live_trip_event.dart';

void main() {
  const createEvent = CreateLiveTripEvent();
  final startedAt = DateTime.utc(2026, 7, 14, 10);
  final session = LiveTripSession(
    vehicleId: 'vehicle_1',
    vehicleName: 'Lada 2107',
    startMileageKm: 120000,
    startedAt: startedAt,
  );

  test('creates a trip and rounds a partial minute up', () {
    final event = createEvent(
      session: session,
      endMileageKm: 120012,
      endedAt: startedAt.add(const Duration(seconds: 61)),
      id: 'trip_1',
      title: 'Trip',
      route: ' Home — Office ',
    );

    expect(event.carId, 'vehicle_1');
    expect(event.occurredAt, startedAt);
    expect(event.currentMileageKm, 120012);
    final details = event.details as TripDetails;
    expect(details.startKm, 120000);
    expect(details.endKm, 120012);
    expect(details.duration, const Duration(minutes: 2));
    expect(details.route, 'Home — Office');
  });

  test('uses one minute minimum for an immediately finished trip', () {
    final event = createEvent(
      session: session,
      endMileageKm: 120000,
      endedAt: startedAt,
      id: 'trip_1',
      title: 'Trip',
    );

    expect((event.details as TripDetails).duration, const Duration(minutes: 1));
  });

  test('rejects an end mileage below the start mileage', () {
    expect(
      () => createEvent(
        session: session,
        endMileageKm: 119999,
        endedAt: startedAt.add(const Duration(minutes: 10)),
        id: 'trip_1',
        title: 'Trip',
      ),
      throwsA(isA<LiveTripMileageException>()),
    );
  });
}
