import 'dart:convert';
import 'dart:io';
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

    test('adds electric fuel event using recharge endpoint', () async {
      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
        ..httpClientAdapter = adapter;
      final datasource = HistoryApiDatasource(dio);

      final createdEventId = await datasource.addEvent(
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
            isRecharge: true,
          ),
        ),
      );

      expect(createdEventId, 'server-event-id');
      expect(adapter.lastOptions?.method, 'POST');
      expect(
        adapter.lastOptions?.path,
        '/vehicles/vehicle_1/timeline/recharge',
      );
      final data = adapter.lastOptions?.data as Map<String, dynamic>;
      expect(data, containsPair('kwh', 37.5));
      expect(data.containsKey('liters'), isFalse);
      expect(data, containsPair('fuelType', 'ELECTRIC'));
    });

    test('uploads maintenance event and local photos as multipart', () async {
      final photosDirectory = await Directory.systemTemp.createTemp(
        'history_api_photos_',
      );
      addTearDown(() => photosDirectory.delete(recursive: true));
      final jpeg = File('${photosDirectory.path}/repair.jpg');
      final png = File('${photosDirectory.path}/invoice.png');
      await jpeg.writeAsBytes(const [0xFF, 0xD8, 0xFF, 0xD9]);
      await png.writeAsBytes(const [0x89, 0x50, 0x4E, 0x47]);

      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
        ..httpClientAdapter = adapter;
      final datasource = HistoryApiDatasource(dio);

      await datasource.addEvent(
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
            photoUrls: [
              jpeg.path,
              png.path,
              'https://api.example.com/api/v1/photos/already-remote',
            ],
          ),
        ),
      );

      expect(adapter.lastOptions?.method, 'POST');
      expect(
        adapter.lastOptions?.path,
        '/vehicles/vehicle_1/timeline/maintenance',
      );
      final formData = adapter.lastOptions?.data as FormData;
      final eventParts = formData.files
          .where((entry) => entry.key == 'event')
          .toList();
      final photoParts = formData.files
          .where((entry) => entry.key == 'photos')
          .toList();
      expect(eventParts, hasLength(1));
      expect(
        eventParts.single.value.contentType?.toString(),
        startsWith('application/json'),
      );
      expect(photoParts, hasLength(2));
      expect(
        photoParts.map((entry) => entry.value.filename),
        containsAll(['repair.jpg', 'invoice.png']),
      );
      expect(
        photoParts.map((entry) => entry.value.contentType?.toString()),
        containsAll(['image/jpeg', 'image/png']),
      );

      final requestBody = latin1.decode(adapter.requestBodyBytes);
      expect(requestBody, contains('name="event"'));
      expect(requestBody, contains('"name":"Oil change"'));
      expect(requestBody, contains('"mileageKm":10000'));
      expect(requestBody, contains('"cost":3000'));
      expect(requestBody, isNot(contains('photoUrls')));
      expect(requestBody, isNot(contains('already-remote')));
    });

    test('adds maintenance without photos as event-only multipart', () async {
      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
        ..httpClientAdapter = adapter;
      final datasource = HistoryApiDatasource(dio);

      await datasource.addEvent(
        HistoryEvent(
          id: 'local-maintenance',
          carId: 'vehicle_1',
          type: HistoryEventType.maintenance,
          occurredAt: DateTime.utc(2026, 6, 12, 16, 30),
          title: 'Inspection',
          currentMileageKm: 10000,
          details: MaintenanceDetails(description: 'Routine inspection'),
        ),
      );

      final formData = adapter.lastOptions?.data as FormData;
      expect(
        formData.files.where((entry) => entry.key == 'event'),
        hasLength(1),
      );
      expect(formData.files.where((entry) => entry.key == 'photos'), isEmpty);
      expect(
        latin1.decode(adapter.requestBodyBytes),
        contains('"name":"Inspection"'),
      );
    });

    test('updates maintenance as JSON without changing photos', () async {
      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
        ..httpClientAdapter = adapter;
      final datasource = HistoryApiDatasource(dio);

      await datasource.updateEvent(
        HistoryEvent(
          id: 'maintenance_1',
          carId: 'vehicle_1',
          type: HistoryEventType.maintenance,
          occurredAt: DateTime.utc(2026, 6, 12, 16, 30),
          title: 'Updated inspection',
          currentMileageKm: 10000,
          details: MaintenanceDetails(
            description: 'Updated description',
            photoUrls: const [
              '/documents/history_photos/maintenance_1/repair.jpg',
              'https://api.example.com/api/v1/photos/photo_1',
            ],
          ),
        ),
      );

      expect(adapter.lastOptions?.method, 'PATCH');
      expect(
        adapter.lastOptions?.path,
        '/vehicles/vehicle_1/timeline/maintenance_1',
      );
      expect(adapter.lastOptions?.data, isA<Map<String, dynamic>>());
      final payload = adapter.lastOptions?.data as Map<String, dynamic>;
      expect(payload['name'], 'Updated inspection');
      expect(payload.containsKey('photoUrls'), isFalse);
    });
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

    test('builds backend recharge payload with electric fuel type and kwh', () {
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
            isRecharge: true,
          ),
        ),
      );

      expect(payload['kwh'], 37.5);
      expect(payload.containsKey('liters'), isFalse);
      expect(payload['fuelType'], 'ELECTRIC');
      expect(payload['fuelName'], 'AC charging');
    });

    test('maps backend recharge event to history fuel details', () {
      final event = HistoryApiEventMapper.fromJson(const {
        'id': 'recharge_1',
        'type': 'RECHARGE',
        'title': 'Recharge',
        'eventDateTime': '2026-06-12T14:30:00Z',
        'cost': 1200,
        'mileageKm': 10000,
        'liters': 37.5,
        'kwh': 37.5,
        'fuelType': 'ELECTRIC',
        'fuelName': 'AC charging',
        'stationName': 'Home charger',
      }, 'vehicle_1');

      expect(event.type, HistoryEventType.fuel);
      expect(event.title, 'Recharge AC charging');

      final details = event.details as FuelDetails;
      expect(details.liters, 37.5);
      expect(details.fuelType, 'AC charging • Home charger');
      expect(details.isRecharge, isTrue);
    });

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

    test('builds JSON maintenance fields without photo URLs', () {
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
            currentMileageKm: 12000,
          ),
        ),
      );

      expect(payload, {
        'eventDateTime': '2026-06-12T16:30:00.000Z',
        'mileageKm': 10000,
        'currentMileageKm': 12000,
        'name': 'Oil change',
        'description': 'Oil and filter replacement\nReplaced parts: Oil filter',
        'cost': 3000,
        'replacedParts': ['Oil filter'],
      });
    });

    test('builds backend part replacement payload from history event', () {
      final event = HistoryEvent(
        id: 'local-part',
        carId: 'vehicle_1',
        type: HistoryEventType.part,
        occurredAt: DateTime.utc(2026, 6, 12, 16, 30),
        title: 'Battery',
        currentMileageKm: 80000,
        details: const MaintenanceDetails(
          description: 'Installed before I started using the app',
          cost: 12000,
          replacedParts: ['Should not be sent'],
          photoUrls: ['https://example.com/part-photo.jpg'],
          currentMileageKm: 120000,
        ),
      );

      expect(HistoryApiEventMapper.createEndpoint(event), 'part');
      expect(HistoryApiEventMapper.createPayload(event), {
        'eventDateTime': '2026-06-12T16:30:00.000Z',
        'mileageKm': 80000,
        'currentMileageKm': 120000,
        'name': 'Battery',
        'description': 'Installed before I started using the app',
        'cost': 12000,
        'photoUrls': ['https://example.com/part-photo.jpg'],
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

    test('maps backend part replacement to separate history type', () {
      final event = HistoryApiEventMapper.fromJson(const {
        'id': 'part_1',
        'type': 'PART_REPLACEMENT',
        'name': 'Battery',
        'eventDateTime': '2026-06-12T16:30:00Z',
        'mileageKm': 80000,
        'description': 'Installed at purchase',
        'cost': 12000,
      }, 'vehicle_1');

      expect(event.type, HistoryEventType.part);
      expect(event.title, 'Battery');
      expect(event.currentMileageKm, 80000);
      final details = event.details as MaintenanceDetails;
      expect(details.description, 'Installed at purchase');
      expect(details.cost, 12000);
      expect(details.replacedParts, isNull);
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
  List<int> requestBodyBytes = const [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    final bytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }
    requestBodyBytes = bytes;
    if (options.method == 'DELETE') {
      return ResponseBody.fromString('', 204);
    }
    return ResponseBody.fromString(
      '{"id":"server-event-id"}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
