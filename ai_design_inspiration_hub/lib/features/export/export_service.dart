import 'dart:convert';
import 'dart:io';

import '../../data/repositories/design_spec_repository.dart';
import '../../data/repositories/screenshot_repository.dart';

class ExportService {
  final ScreenshotRepository _screensRepo = ScreenshotRepository();
  final DesignSpecRepository _specRepo = DesignSpecRepository();

  Future<File> exportToJson({required List<String> screenshotIds, required File targetFile}) async {
    final List<Map<String, Object?>> out = [];
    for (final id in screenshotIds) {
      final screenshot = await _screensRepo.getById(id);
      if (screenshot == null) continue;
      final spec = await _specRepo.getByScreenshotId(id);
      out.add({
        'id': screenshot.id,
        'title': screenshot.title,
        'description': screenshot.description,
        'image_filename': screenshot.imagePath,
        'creation_date': screenshot.creationDateIso,
        'source_url': screenshot.sourceUrl,
        'upload_timestamp': screenshot.uploadTimestampIso,
        // Tags/Categories omitted in stub; add when link tables wired via repos
        'design_specifications': spec == null
            ? null
            : {
                'layout_structure': spec.layoutStructure,
                'ui_components': spec.uiComponents,
                'color_palette': spec.colorPalette,
                'typography': spec.typography,
                'general_design_info': spec.generalDesignInfo,
                'analysis_timestamp': spec.analysisTimestampIso,
              },
      });
    }

    final payload = <String, Object?>{
      'export_version': '1.0',
      'export_timestamp': DateTime.now().toUtc().toIso8601String(),
      'application_name': 'AI Design Inspiration Hub',
      'screenshots': out,
    };
    await targetFile.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return targetFile;
  }
}
