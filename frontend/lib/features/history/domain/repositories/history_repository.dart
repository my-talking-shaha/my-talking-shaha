import 'package:frontend/features/history/domain/history_event.dart';

abstract interface class HistoryRepository {
  Future<List<HistoryEvent>> getEvents(String vehicleId);

  Future<void> addEvent(HistoryEvent event);
}
