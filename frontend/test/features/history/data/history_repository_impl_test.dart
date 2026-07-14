import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/datasources/history_datasource.dart';
import 'package:frontend/features/history/data/datasources/history_photo_storage.dart';
import 'package:frontend/features/history/data/repositories/history_repository_impl.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

void main() {
  group('HistoryRepositoryImpl maintenance photos', () {
    test(
      'binds temporary photo cache to the created backend event id',
      () async {
        final event = _maintenanceEvent();
        final datasource = _HistoryDatasource(
          const [],
          createdEventId: 'server-maintenance-42',
        );
        final photos = _HistoryPhotoReader(const {});
        final repository = HistoryRepositoryImpl(datasource, photos: photos);

        await repository.addEvent(event);

        expect(photos.bindings, hasLength(1));
        expect(photos.bindings.single.eventId, 'server-maintenance-42');
        expect(photos.bindings.single.temporaryEventId, contains('vehicle_1'));
        expect(
          photos.bindings.single.temporaryEventId,
          isNot('server-maintenance-42'),
        );
      },
    );

    test('prefers cached photo paths over backend photo URLs', () async {
      final datasource = _HistoryDatasource([_maintenanceEvent()]);
      final photos = _HistoryPhotoReader({
        'maintenance_1': const [
          '/documents/history_photos/maintenance_1/repair.jpg',
        ],
      });
      final repository = HistoryRepositoryImpl(datasource, photos: photos);

      final events = await repository.getEvents('vehicle_1');

      final details = events.single.details as MaintenanceDetails;
      expect(details.photoUrls, const [
        '/documents/history_photos/maintenance_1/repair.jpg',
      ]);
      expect(photos.requestedEventIds, const ['maintenance_1']);
    });

    test('falls back to backend photo URLs when cache is empty', () async {
      final datasource = _HistoryDatasource([_maintenanceEvent()]);
      final photos = _HistoryPhotoReader(const {});
      final repository = HistoryRepositoryImpl(datasource, photos: photos);

      final events = await repository.getEvents('vehicle_1');

      final details = events.single.details as MaintenanceDetails;
      expect(details.photoUrls, const [
        'https://api.example.com/api/v1/photos/photo_1',
      ]);
      expect(photos.requestedEventIds.first, 'maintenance_1');
    });

    test(
      'uses backend photos without touching file cache when unavailable',
      () async {
        final datasource = _HistoryDatasource([_maintenanceEvent()]);
        final repository = HistoryRepositoryImpl(datasource);

        final events = await repository.getEvents('vehicle_1');

        final details = events.single.details as MaintenanceDetails;
        expect(details.photoUrls, const [
          'https://api.example.com/api/v1/photos/photo_1',
        ]);
      },
    );

    test('falls back to backend photo URLs when cache lookup fails', () async {
      final datasource = _HistoryDatasource([_maintenanceEvent()]);
      final repository = HistoryRepositoryImpl(
        datasource,
        photos: _ThrowingHistoryPhotoReader(),
      );

      final events = await repository.getEvents('vehicle_1');

      final details = events.single.details as MaintenanceDetails;
      expect(details.photoUrls, const [
        'https://api.example.com/api/v1/photos/photo_1',
      ]);
    });
  });
}

HistoryEvent _maintenanceEvent() {
  return HistoryEvent(
    id: 'maintenance_1',
    carId: 'vehicle_1',
    type: HistoryEventType.maintenance,
    occurredAt: DateTime.utc(2026, 6, 12, 16, 30),
    title: 'Oil change',
    currentMileageKm: 10000,
    details: MaintenanceDetails(
      description: 'Oil and filter replacement',
      cost: 3000,
      photoUrls: const ['https://api.example.com/api/v1/photos/photo_1'],
    ),
  );
}

final class _HistoryDatasource implements HistoryDatasource {
  _HistoryDatasource(this.events, {this.createdEventId = 'server-event-id'});

  final List<HistoryEvent> events;
  final String createdEventId;

  @override
  Future<List<HistoryEvent>> getEvents(String vehicleId) async => events;

  @override
  Future<String> addEvent(HistoryEvent event) async => createdEventId;

  @override
  Future<void> updateEvent(HistoryEvent event) async {}

  @override
  Future<void> deleteEvent(String vehicleId, String eventId) async {}
}

final class _HistoryPhotoReader implements HistoryPhotoCache {
  _HistoryPhotoReader(this.pathsByEventId);

  final Map<String, List<String>> pathsByEventId;
  final List<String> requestedEventIds = [];
  final List<({String temporaryEventId, String eventId})> bindings = [];

  @override
  Future<void> bindPhotosToEvent({
    required String temporaryEventId,
    required String eventId,
  }) async {
    bindings.add((temporaryEventId: temporaryEventId, eventId: eventId));
  }

  @override
  Future<List<String>> photoPathsForEvent(String eventId) async {
    requestedEventIds.add(eventId);
    return pathsByEventId[eventId] ?? const [];
  }
}

final class _ThrowingHistoryPhotoReader implements HistoryPhotoCache {
  @override
  Future<void> bindPhotosToEvent({
    required String temporaryEventId,
    required String eventId,
  }) async {}

  @override
  Future<List<String>> photoPathsForEvent(String eventId) {
    throw UnsupportedError('Device file cache is unavailable');
  }
}
