import 'dart:convert';
import 'dart:io';
import '../models/screenshot.dart';
import '../repositories/screenshot_repository.dart';

class ExportService {
  final ScreenshotRepository _repository;

  ExportService(this._repository);

  Future<void> exportToJson(
    List<String> screenshotIds,
    String outputPath,
  ) async {
    final List<Map<String, dynamic>> screenshotsData = [];

    for (final id in screenshotIds) {
      final screenshot = await _repository.getScreenshotById(id);
      if (screenshot == null) continue;

      final designSpec = await _repository.getDesignSpecification(id);

      final screenshotData = {
        'id': screenshot.id,
        'title': screenshot.title,
        'description': screenshot.description,
        'image_filename': screenshot.imagePath.split('/').last,
        'creation_date': screenshot.creationDate.toIso8601String(),
        'source_url': screenshot.sourceUrl,
        'upload_timestamp': screenshot.uploadTimestamp.toIso8601String(),
        'tags': screenshot.tags,
        'categories': screenshot.categories,
        'design_specifications': designSpec?.toJson(),
      };

      screenshotsData.add(screenshotData);
    }

    final exportData = {
      'export_version': '1.0',
      'export_timestamp': DateTime.now().toIso8601String(),
      'application_name': 'AI Design Inspiration Hub',
      'screenshots': screenshotsData,
    };

    final file = File(outputPath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(exportData),
    );
  }

  Future<void> exportAll(String outputPath) async {
    final screenshots = await _repository.getAllScreenshots();
    final ids = screenshots.map((s) => s.id).toList();
    await exportToJson(ids, outputPath);
  }
}