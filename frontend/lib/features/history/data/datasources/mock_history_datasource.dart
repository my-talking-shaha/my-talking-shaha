import 'package:frontend/features/history/domain/event_detais.dart';
import 'package:frontend/features/history/domain/history_event.dart';
import 'package:frontend/features/history/domain/history_event_type.dart';

final class MockHistoryDatasource {
  const MockHistoryDatasource({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  Future<List<HistoryEvent>> getEvents(String vehicleId) async {
    await Future<void>.delayed(delay);

    return List.unmodifiable([
      HistoryEvent(
        id: 'fuel_1',
        carId: vehicleId,
        type: HistoryEventType.fuel,
        occurredAt: DateTime(2026, 6, 15, 14, 30),
        title: 'Refueling AI-95',
        currentMileageKm: 124580,
        details: FuelDetails(
          cost: 2450,
          liters: 45,
          fuelType: 'AI-95 • Gazpromneft Station No. 14',
        ),
      ),
      HistoryEvent(
        id: 'maintenance_1',
        carId: vehicleId,
        type: HistoryEventType.maintenance,
        occurredAt: DateTime(2026, 6, 8, 11),
        title: 'Oil and filter change',
        currentMileageKm: 124000,
        details: MaintenanceDetails(
          description: 'Shell Helix Ultra 5W-40, MANN oil filter',
          cost: 8900,
        ),
      ),
      HistoryEvent(
        id: 'trip_1',
        carId: vehicleId,
        type: HistoryEventType.trip,
        occurredAt: DateTime(2026, 6, 1, 9, 15),
        title: 'Long-distance trip',
        currentMileageKm: 123600,
        details: const TripDetails(
          startKm: 123180,
          endKm: 123600,
          route: 'Moscow — Tula — Moscow',
          duration: Duration(hours: 7, minutes: 12),
        ),
      ),
      HistoryEvent(
        id: 'maintenance_2',
        carId: vehicleId,
        type: HistoryEventType.maintenance,
        occurredAt: DateTime(2026, 5, 22, 16, 45),
        title: 'Brake pad replacement',
        currentMileageKm: 122900,
        details: MaintenanceDetails(
          description: 'Front Brembo pads, caliper cleaning',
          cost: 4200,
        ),
      ),
      HistoryEvent(
        id: 'fuel_2',
        carId: vehicleId,
        type: HistoryEventType.fuel,
        occurredAt: DateTime(2026, 5, 12, 20),
        title: 'Refueling before trip',
        currentMileageKm: 122340,
        details: FuelDetails(
          cost: 2100,
          liters: 39,
          fuelType: 'AI-95 • Lukoil Station',
        ),
      ),
    ]);
  }
}
