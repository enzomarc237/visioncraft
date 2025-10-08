import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../models/screenshot.dart';
import '../../data/repositories/screenshot_repository.dart';
import '../../services/storage_service.dart';

class UploadServiceStub {
  final StorageService _storage = StorageService();
  final ScreenshotRepository _screensRepo = ScreenshotRepository();
  final _uuid = const Uuid();

  Future<ScreenshotModel> importImageBytes(Uint8List bytes, {String? originalExtension, String? title}) async {
    final id = _uuid.v4();
    final filename = '$id${originalExtension != null ? '.$originalExtension' : '.png'}';
    await _storage.saveImageBytes(bytes, filename);
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final screenshot = ScreenshotModel(
      id: id,
      imagePath: filename,
      uploadTimestampIso: nowIso,
      title: title,
      creationDateIso: nowIso,
    );
    await _screensRepo.create(screenshot);
    return screenshot;
  }
}
