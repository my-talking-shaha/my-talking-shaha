import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/history/data/datasources/history_api_datasource.dart';
import 'package:frontend/features/history/data/datasources/history_datasource.dart';
import 'package:frontend/features/history/data/datasources/history_photo_storage.dart';
import 'package:frontend/features/history/data/repositories/history_repository_impl.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/repositories/history_repository.dart';

final historyApiDatasourceProvider = Provider<HistoryApiDatasource>((ref) {
  return HistoryApiDatasource(ref.watch(dioProvider));
});

final historyDatasourceProvider = Provider<HistoryDatasource>((ref) {
  return ref.watch(historyApiDatasourceProvider);
});

final historyPhotoStorageProvider = Provider<HistoryPhotoStorage>((ref) {
  return const HistoryPhotoStorage();
});

final historyPhotoReaderProvider = Provider<HistoryPhotoCache?>((ref) {
  if (kIsWeb) return null;
  return ref.watch(historyPhotoStorageProvider);
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(
    ref.watch(historyDatasourceProvider),
    photos: ref.watch(historyPhotoReaderProvider),
  );
});

final historyEventsProvider = FutureProvider.autoDispose
    .family<List<HistoryEvent>, String>((ref, vehicleId) {
      return ref.watch(historyRepositoryProvider).getEvents(vehicleId);
    });

typedef AddHistoryEvent = Future<void> Function(HistoryEvent event);

final addHistoryEventProvider = Provider<AddHistoryEvent>((ref) {
  return ref.watch(historyRepositoryProvider).addEvent;
});

typedef UpdateHistoryEvent = Future<void> Function(HistoryEvent event);

final updateHistoryEventProvider = Provider<UpdateHistoryEvent>((ref) {
  return ref.watch(historyRepositoryProvider).updateEvent;
});

typedef DeleteHistoryEvent =
    Future<void> Function(String vehicleId, String eventId);

final deleteHistoryEventProvider = Provider<DeleteHistoryEvent>((ref) {
  return ref.watch(historyRepositoryProvider).deleteEvent;
});

typedef DeleteHistoryPhotoCache = Future<void> Function(HistoryEvent event);

final deleteHistoryPhotoCacheProvider = Provider<DeleteHistoryPhotoCache>((
  ref,
) {
  if (kIsWeb) return (_) async {};
  return ref.watch(historyPhotoStorageProvider).deleteCachedPhotosForEvent;
});
