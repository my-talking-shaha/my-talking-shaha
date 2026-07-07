import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class HistoryPhotoReader {
  Future<List<String>> photoPathsForEvent(String eventId);
}

final class HistoryPhotoStorage implements HistoryPhotoReader {
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

  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
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
}
