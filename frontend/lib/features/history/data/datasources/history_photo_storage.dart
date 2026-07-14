import 'dart:io';

import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class HistoryPhotoReader {
  Future<List<String>> photoPathsForEvent(String eventId);
}

abstract interface class HistoryPhotoCache implements HistoryPhotoReader {
  Future<void> bindPhotosToEvent({
    required String temporaryEventId,
    required String eventId,
  });
}

final class HistoryPhotoStorage implements HistoryPhotoCache {
  const HistoryPhotoStorage();

  @override
  Future<List<String>> photoPathsForEvent(String eventId) async {
    final photosDirectory = await _photosDirectory();
    final eventDirectory = Directory(
      '${photosDirectory.path}/${_safePathSegment(eventId)}',
    );
    final paths = <String>[];

    if (await eventDirectory.exists()) {
      await for (final entity in eventDirectory.list()) {
        if (entity is File) {
          paths.add(entity.path);
        }
      }
    }

    await for (final entity in photosDirectory.list()) {
      if (entity is! File) continue;
      final fileName = entity.uri.pathSegments.last;
      if (fileName.startsWith('$eventId.')) {
        paths.add(entity.path);
      }
    }

    paths.sort();
    return List.unmodifiable(paths);
  }

  Future<String> persistPhoto({
    required String sourcePath,
    required String originalName,
    required String eventId,
  }) async {
    final photosDirectory = await _photosDirectory();
    final eventDirectory = Directory(
      '${photosDirectory.path}/${_safePathSegment(eventId)}',
    );
    await eventDirectory.create(recursive: true);

    final extension = _fileExtension(originalName);
    final baseName = _safePathSegment(_fileBaseName(originalName));
    final savedAt = DateTime.now().microsecondsSinceEpoch;
    final destination = File(
      '${eventDirectory.path}/${savedAt}_$baseName$extension',
    );
    await File(sourcePath).copy(destination.path);
    return destination.path;
  }

  @override
  Future<void> bindPhotosToEvent({
    required String temporaryEventId,
    required String eventId,
  }) async {
    final photosDirectory = await _photosDirectory();
    final sourceDirectory = Directory(
      '${photosDirectory.path}/${_safePathSegment(temporaryEventId)}',
    );
    if (!await sourceDirectory.exists()) return;

    final targetDirectory = Directory(
      '${photosDirectory.path}/${_safePathSegment(eventId)}',
    );
    await targetDirectory.create(recursive: true);

    await for (final entity in sourceDirectory.list()) {
      if (entity is! File) continue;
      final fileName = entity.uri.pathSegments.last;
      await entity.rename('${targetDirectory.path}/$fileName');
    }
    await sourceDirectory.delete(recursive: true);
  }

  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteCachedPhotosForEvent(HistoryEvent event) async {
    await _deletePhotosForEventId(event.id);
    await _deletePhotosForEventId(_photoCacheKey(event));

    final details = event.details;
    if (details is! MaintenanceDetails) return;

    for (final url in details.photoUrls ?? const <String>[]) {
      final path = url.trim();
      if (path.isEmpty || _isRemoteUrl(path)) continue;
      await deletePhoto(path);
    }
  }

  Future<Directory> _photosDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory(
      '${documentsDirectory.path}/history_photos',
    );
    await photosDirectory.create(recursive: true);
    return photosDirectory;
  }

  String _fileBaseName(String fileName) {
    final normalized = fileName.split(Platform.pathSeparator).last;
    final dotIndex = normalized.lastIndexOf('.');
    if (dotIndex <= 0) return normalized.isEmpty ? 'photo' : normalized;
    return normalized.substring(0, dotIndex);
  }

  String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) return '.jpg';
    return fileName.substring(dotIndex).toLowerCase();
  }

  String _safePathSegment(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    final trimmed = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
    return trimmed.isEmpty ? 'event' : trimmed;
  }

  Future<void> _deletePhotosForEventId(String eventId) async {
    final photosDirectory = await _photosDirectory();
    final safeEventId = _safePathSegment(eventId);
    final eventDirectory = Directory('${photosDirectory.path}/$safeEventId');

    if (await eventDirectory.exists()) {
      await eventDirectory.delete(recursive: true);
    }

    await for (final entity in photosDirectory.list()) {
      if (entity is! File) continue;
      final fileName = entity.uri.pathSegments.last;
      if (fileName.startsWith('$eventId.')) {
        await entity.delete();
      }
    }
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

  bool _isRemoteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
