import 'package:frontend/features/history/data/datasources/history_datasource.dart';
import 'package:frontend/features/history/data/datasources/history_photo_storage.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/repositories/history_repository.dart';

final class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource, {HistoryPhotoReader? photos})
    : _photos = photos;

  final HistoryDatasource _datasource;
  final HistoryPhotoReader? _photos;

  @override
  Future<List<HistoryEvent>> getEvents(String vehicleId) async {
    final events = await _datasource.getEvents(vehicleId);
    if (_photos == null) return events;

    final hydratedEvents = <HistoryEvent>[];
    for (final event in events) {
      hydratedEvents.add(await _withCachedPhotos(event));
    }

    return List.unmodifiable(hydratedEvents);
  }

  @override
  Future<void> addEvent(HistoryEvent event) {
    return _datasource.addEvent(event);
  }

  Future<HistoryEvent> _withCachedPhotos(HistoryEvent event) async {
    final details = event.details;
    if (details is! MaintenanceDetails) return event;

    final cachedPhotoPaths = await _cachedPhotoPaths(event);
    if (cachedPhotoPaths.isEmpty) return event;

    return HistoryEvent(
      id: event.id,
      carId: event.carId,
      type: event.type,
      occurredAt: event.occurredAt,
      title: event.title,
      details: MaintenanceDetails(
        description: details.description,
        cost: details.cost,
        replacedParts: details.replacedParts,
        photoUrls: cachedPhotoPaths,
      ),
      currentMileageKm: event.currentMileageKm,
    );
  }

  Future<List<String>> _cachedPhotoPaths(HistoryEvent event) async {
    final photos = _photos!;
    final byId = await photos.photoPathsForEvent(event.id);
    if (byId.isNotEmpty) return byId;

    return photos.photoPathsForEvent(_photoCacheKey(event));
  }

  String _photoCacheKey(HistoryEvent event) {
    return [
      event.carId,
      event.type.name,
      event.occurredAt.toUtc().toIso8601String(),
      event.title.trim().toLowerCase(),
      event.currentMileageKm,
    ].join('|');
  }
}
