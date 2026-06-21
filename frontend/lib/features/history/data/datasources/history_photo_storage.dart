import 'dart:io';

import 'package:path_provider/path_provider.dart';

final class HistoryPhotoStorage {
  const HistoryPhotoStorage();

  Future<String> persistPhoto({
    required String sourcePath,
    required String originalName,
    required String eventId,
  }) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory(
      '${documentsDirectory.path}/history_photos',
    );
    await photosDirectory.create(recursive: true);

    final extension = _fileExtension(originalName);
    final destination = File('${photosDirectory.path}/$eventId$extension');
    await File(sourcePath).copy(destination.path);
    return destination.path;
  }

  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) return '.jpg';
    return fileName.substring(dotIndex).toLowerCase();
  }
}
