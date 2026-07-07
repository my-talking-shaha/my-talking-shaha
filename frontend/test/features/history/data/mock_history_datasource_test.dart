import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/datasources/mock_history_datasource.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

void main() {
  test('adds an event and returns it in newest-first order', () async {
    final datasource = MockHistoryDatasource(delay: Duration.zero);
    final event = HistoryEvent(
      id: 'local-fuel',
      carId: 'vehicle_1',
      type: HistoryEventType.fuel,
      occurredAt: DateTime(2026, 6, 20),
      title: 'Refueling · 95 octane',
      currentMileageKm: 124600,
      details: FuelDetails(cost: 3000, liters: 42, fuelType: '95 octane'),
    );

    await datasource.addEvent(event);

    final events = await datasource.getEvents('vehicle_1');
    expect(events.first, same(event));
    expect(events, hasLength(6));
  });

  test('rejects mileage rollback', () async {
    final datasource = MockHistoryDatasource(delay: Duration.zero);
    final event = HistoryEvent(
      id: 'invalid-maintenance',
      carId: 'vehicle_1',
      type: HistoryEventType.maintenance,
      occurredAt: DateTime(2026, 6, 20),
      title: 'Maintenance',
      currentMileageKm: 120000,
      details: MaintenanceDetails(description: 'Oil change'),
    );

    await expectLater(datasource.addEvent(event), throwsArgumentError);
  });

  test('updates and deletes an existing event', () async {
    final datasource = MockHistoryDatasource(delay: Duration.zero);
    final updatedEvent = HistoryEvent(
      id: 'maintenance_1',
      carId: 'vehicle_1',
      type: HistoryEventType.maintenance,
      occurredAt: DateTime(2026, 6, 8, 11),
      title: 'Updated oil service',
      currentMileageKm: 124050,
      details: MaintenanceDetails(
        description: 'Updated oil and filter replacement',
        cost: 9100,
      ),
    );

    await datasource.updateEvent(updatedEvent);

    var events = await datasource.getEvents('vehicle_1');
    expect(
      events.singleWhere((event) => event.id == 'maintenance_1').title,
      'Updated oil service',
    );

    await datasource.deleteEvent('vehicle_1', 'maintenance_1');

    events = await datasource.getEvents('vehicle_1');
    expect(events.where((event) => event.id == 'maintenance_1'), isEmpty);
  });
}
