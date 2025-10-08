import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FileStorageService {
  final _uuid = const Uuid();

  Future<String> get _imagesDirectory async {
    final appDir = await getApplicationSupportDirectory();
    final imagesDir = Directory(join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir.path;
  }

  Future<String> get _thumbnailsDirectory async {
    final appDir = await getApplicationSupportDirectory();
    final thumbsDir = Directory(join(appDir.path, 'thumbnails'));
    if (!await thumbsDir.exists()) {
      await thumbsDir.create(recursive: true);
    }
    return thumbsDir.path;
  }

  Future<String> saveImage(File imageFile) async {
    final imagesDir = await _imagesDirectory;
    final extension = imageFile.path.split('.').last;
    final filename = '${_uuid.v4()}.$extension';
    final newPath = join(imagesDir, filename);
    
    await imageFile.copy(newPath);
    return newPath;
  }

  Future<String> getThumbnailPath(String imagePath) async {
    final thumbsDir = await _thumbnailsDirectory;
    final imageName = basename(imagePath);
    final nameWithoutExt = imageName.split('.').first;
    return join(thumbsDir, '${nameWithoutExt}_thumb.png');
  }

  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }

    // Also delete thumbnail if exists
    final thumbnailPath = await getThumbnailPath(imagePath);
    final thumbFile = File(thumbnailPath);
    if (await thumbFile.exists()) {
      await thumbFile.delete();
    }
  }

  Future<bool> imageExists(String imagePath) async {
    final file = File(imagePath);
    return await file.exists();
  }
}