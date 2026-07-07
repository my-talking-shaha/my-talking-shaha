import 'package:frontend/features/history/data/datasources/history_datasource.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/repositories/history_repository.dart';

final class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource);

  final HistoryDatasource _datasource;

  @override
  Future<List<HistoryEvent>> getEvents(String vehicleId) {
    return _datasource.getEvents(vehicleId);
  }

  @override
  Future<void> addEvent(HistoryEvent event) {
    return _datasource.addEvent(event);
  }

  @override
  Future<void> updateEvent(HistoryEvent event) {
    return _datasource.updateEvent(event);
  }

  @override
  Future<void> deleteEvent(String vehicleId, String eventId) {
    return _datasource.deleteEvent(vehicleId, eventId);
  }
}
