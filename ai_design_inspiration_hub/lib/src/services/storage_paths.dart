import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StoragePathsService {
  Future<Directory> getAppSupportDir() async {
    final Directory dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> getImagesDir() async {
    final Directory appDir = await getAppSupportDir();
    final Directory images = Directory(p.join(appDir.path, 'Images'));
    if (!await images.exists()) {
      await images.create(recursive: true);
    }
    return images;
  }
}

