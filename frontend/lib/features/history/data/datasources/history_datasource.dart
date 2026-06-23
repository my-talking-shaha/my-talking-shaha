import 'package:frontend/features/history/domain/entities/history_event.dart';

abstract interface class HistoryDatasource {
  Future<List<HistoryEvent>> getEvents(String vehicleId);

  Future<void> addEvent(HistoryEvent event);
}
