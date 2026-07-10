import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/datasources/history_api_datasource.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

void main() {
  group('HistoryApiDatasource', () {
    test(
      'deletes event using timeline event endpoint and accepts 204',
      () async {
        final adapter = _CapturingAdapter();
        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
          ..httpClientAdapter = adapter;
        final datasource = HistoryApiDatasource(dio);

        await datasource.deleteEvent(
          '096c10bb-13d1-4599-9109-e9e79789ea88',
          '044c10dc-13d1-4587-9169-e9e79789ea45',
        );

        expect(adapter.lastOptions?.method, 'DELETE');
        expect(
          adapter.lastOptions?.path,
          '/vehicles/096c10bb-13d1-4599-9109-e9e79789ea88/timeline/'
          '044c10dc-13d1-4587-9169-e9e79789ea45',
        );
      },
    );
  });

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

    test('builds backend refuel payload with decimal liters', () {
      final payload = HistoryApiEventMapper.createPayload(
        HistoryEvent(
          id: 'local-fuel',
          carId: 'vehicle_1',
          type: HistoryEventType.fuel,
          occurredAt: DateTime.utc(2026, 6, 12, 14, 30),
          title: 'Refuel',
          currentMileageKm: 10000,
          details: FuelDetails(cost: 3000, liters: 42.5, fuelType: '95 octane'),
        ),
      );

      expect(payload['liters'], 42.5);
    });

    test(
      'keeps recharge payload on refuel contract with electric fuel type',
      () {
        final payload = HistoryApiEventMapper.createPayload(
          HistoryEvent(
            id: 'local-recharge',
            carId: 'vehicle_1',
            type: HistoryEventType.fuel,
            occurredAt: DateTime.utc(2026, 6, 12, 14, 30),
            title: 'Recharge',
            currentMileageKm: 10000,
            details: FuelDetails(
              cost: 1200,
              liters: 37.5,
              fuelType: 'AC charging',
            ),
          ),
        );

        expect(payload['liters'], 37.5);
        expect(payload['fuelType'], 'ELECTRIC');
        expect(payload['fuelName'], 'AC charging');
      },
    );

    test('uses event-specific title instead of backend type label', () {
      final refuel = HistoryApiEventMapper.fromJson(const {
        'id': '044c10dc-13d1-4587-9169-e9e79789ea45',
        'type': 'REFUEL',
        'title': 'Заправка',
        'eventDateTime': '2026-06-12T14:30:00Z',
        'cost': 2000,
        'mileageKm': 10000,
        'liters': 30,
        'fuelType': 'GASOLINE',
        'fuelName': 'AI-95',
      }, 'vehicle_1');
      final trip = HistoryApiEventMapper.fromJson(const {
        'id': '144c10dc-13d1-4587-9169-e9e79789ea45',
        'type': 'TRIP',
        'title': 'Trip',
        'eventDateTime': '2026-06-12T09:30:00Z',
        'startMileageKm': 10000,
        'endMileageKm': 10120,
        'distanceKm': 120,
        'route': 'Home -> Service',
        'durationMinutes': 90,
      }, 'vehicle_1');

      expect(refuel.title, 'Refueling AI-95');
      expect(trip.title, 'Home -> Service');
    });

    test('keeps custom refuel and trip titles in payloads', () {
      final refuelPayload = HistoryApiEventMapper.createPayload(
        HistoryEvent(
          id: 'fuel_1',
          carId: 'vehicle_1',
          type: HistoryEventType.fuel,
          occurredAt: DateTime.utc(2026, 6, 12, 14, 30),
          title: 'Evening fuel stop',
          currentMileageKm: 10000,
          details: FuelDetails(cost: 2000, liters: 30, fuelType: 'AI-95'),
        ),
      );
      final tripPayload = HistoryApiEventMapper.createPayload(
        HistoryEvent(
          id: 'trip_1',
          carId: 'vehicle_1',
          type: HistoryEventType.trip,
          occurredAt: DateTime.utc(2026, 6, 13, 9, 15),
          title: 'Morning commute',
          currentMileageKm: 10400,
          details: const TripDetails(
            startKm: 10000,
            endKm: 10400,
            route: 'Home -> University',
            duration: Duration(minutes: 60),
          ),
        ),
      );

      expect(refuelPayload['title'], 'Evening fuel stop');
      expect(tripPayload['title'], 'Morning commute');
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

    test('omits local photo paths from backend maintenance payload', () {
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
            photoUrls: const [
              '/documents/history_photos/local-maintenance.jpg',
            ],
          ),
        ),
      );

      expect(payload.containsKey('photoUrls'), isFalse);
    });

    test('maps backend maintenance replaced parts marker to details', () {
      final event = HistoryApiEventMapper.fromJson(const {
        'id': 'maintenance_1',
        'type': 'MAINTENANCE',
        'title': 'Engine replacement',
        'eventDateTime': '2026-06-12T16:30:00Z',
        'mileageKm': 10000,
        'description': 'Changed engine\nReplaced parts: engine',
        'cost': 10000,
      }, 'vehicle_1');

      final details = event.details as MaintenanceDetails;
      expect(details.description, 'Changed engine');
      expect(details.replacedParts, const ['engine']);
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
        'title': 'Trip',
        'eventDateTime': '2026-06-13T09:15:00.000Z',
        'startMileageKm': 10000,
        'endMileageKm': 10400,
        'route': 'Home -> University',
        'durationMinutes': 60,
      });
    });

    test(
      'keeps backend gasoline type and station when editing mapped refuel',
      () {
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

        final payload = HistoryApiEventMapper.createPayload(event);

        expect(payload['fuelType'], 'GASOLINE');
        expect(payload['fuelName'], 'AI-95');
        expect(payload['stationName'], 'Test Station');
      },
    );
  });
}

final class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}
