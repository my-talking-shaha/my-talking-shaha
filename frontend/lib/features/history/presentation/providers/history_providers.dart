import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/history/data/datasources/history_photo_storage.dart';
import 'package:frontend/features/history/data/datasources/mock_history_datasource.dart';
import 'package:frontend/features/history/data/repositories/history_repository_impl.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/repositories/history_repository.dart';

final mockHistoryDatasourceProvider = Provider<MockHistoryDatasource>((ref) {
  return MockHistoryDatasource();
});

final historyPhotoStorageProvider = Provider<HistoryPhotoStorage>((ref) {
  return const HistoryPhotoStorage();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(ref.watch(mockHistoryDatasourceProvider));
});

final historyEventsProvider = FutureProvider.autoDispose
    .family<List<HistoryEvent>, String>((ref, vehicleId) {
      return ref.watch(historyRepositoryProvider).getEvents(vehicleId);
    });

typedef AddHistoryEvent = Future<void> Function(HistoryEvent event);

final addHistoryEventProvider = Provider<AddHistoryEvent>((ref) {
  return ref.watch(historyRepositoryProvider).addEvent;
});
