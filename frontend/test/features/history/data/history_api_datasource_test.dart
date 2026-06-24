import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/datasources/history_api_datasource.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

void main() {
  group('HistoryApiEventMapper', () {
    test('maps backend refuel event to history event', () {
      final event = HistoryApiEventMapper.fromJson(const {
        'id': '044c10dc-13d1-4587-9169-e9e79789ea45',
        'type': 'REFUEL',
        'title': 'Refill AI-95',
        'eventDateTime': '2026-06-12T14:30:00Z',
        'cost': 2000,
        'mileageKm': 10000,
        'liters': 30,
        'fuelType': 'GASOLINE',
        'fuelName': 'AI-95',
        'stationName': 'Test Station',
      }, 'vehicle_1');

      expect(event.id, '044c10dc-13d1-4587-9169-e9e79789ea45');
      expect(event.carId, 'vehicle_1');
      expect(event.type, HistoryEventType.fuel);
      expect(event.title, 'Refill AI-95');
      expect(event.currentMileageKm, 10000);
      expect(event.occurredAt.toUtc(), DateTime.utc(2026, 6, 12, 14, 30));

      final details = event.details as FuelDetails;
      expect(details.cost, 2000);
      expect(details.liters, 30);
      expect(details.fuelType, 'AI-95 • Test Station');
    });

    test('builds backend maintenance payload from history event', () {
      final payload = HistoryApiEventMapper.createPayload(
        HistoryEvent(
          id: 'local-maintenance',
          carId: 'vehicle_1',
          type: HistoryEventType.maintenance,
          occurredAt: DateTime.utc(2026, 6, 12, 16, 30),
          title: 'Oil change',
          currentMileageKm: 10000,
          details: MaintenanceDetails(
            description: 'Oil and filter replacement',
            cost: 3000,
            replacedParts: const ['Oil filter'],
            photoUrls: const ['https://example.com/event-photo.jpg'],
          ),
        ),
      );

      expect(payload, {
        'eventDateTime': '2026-06-12T16:30:00.000Z',
        'mileageKm': 10000,
        'name': 'Oil change',
        'description': 'Oil and filter replacement\nReplaced parts: Oil filter',
        'cost': 3000,
        'photoUrls': ['https://example.com/event-photo.jpg'],
      });
    });

    test('builds backend trip payload from history event', () {
      final payload = HistoryApiEventMapper.createPayload(
        HistoryEvent(
          id: 'local-trip',
          carId: 'vehicle_1',
          type: HistoryEventType.trip,
          occurredAt: DateTime.utc(2026, 6, 13, 9, 15),
          title: 'Trip',
          currentMileageKm: 10400,
          details: const TripDetails(
            startKm: 10000,
            endKm: 10400,
            route: 'Home -> University',
            duration: Duration(minutes: 60),
          ),
        ),
      );

      expect(payload, {
        'eventDateTime': '2026-06-13T09:15:00.000Z',
        'startMileageKm': 10000,
        'endMileageKm': 10400,
        'route': 'Home -> University',
        'durationMinutes': 60,
      });
    });
  });
}
