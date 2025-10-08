import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String _appFolderName = 'AI Design Inspiration Hub';
  static const String _imagesSubdir = 'Images';

  Future<Directory> ensureAppSupportDir() async {
    final base = await getApplicationSupportDirectory();
    final appDir = Directory(p.join(base.path, _appFolderName));
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<Directory> ensureImagesDir() async {
    final appDir = await ensureAppSupportDir();
    final imagesDir = Directory(p.join(appDir.path, _imagesSubdir));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  Future<File> saveImageBytes(List<int> bytes, String filename) async {
    final imagesDir = await ensureImagesDir();
    final file = File(p.join(imagesDir.path, filename));
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<File?> getImageFile(String filename) async {
    final imagesDir = await ensureImagesDir();
    final file = File(p.join(imagesDir.path, filename));
    if (await file.exists()) return file;
    return null;
  }
}
