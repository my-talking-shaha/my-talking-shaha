import 'package:frontend/features/history/domain/entities/history_event.dart';

abstract interface class HistoryDatasource {
  Future<List<HistoryEvent>> getEvents(String vehicleId);

  Future<void> addEvent(HistoryEvent event);

  Future<void> updateEvent(HistoryEvent event);

  Future<void> deleteEvent(String vehicleId, String eventId);
}
