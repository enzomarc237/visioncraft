import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db/app_database.dart';
import '../models/entities.dart';

class ScreenshotRepository {
  final AppDatabaseProvider _dbProvider = AppDatabaseProvider();

  Future<void> insertScreenshot(ScreenshotEntity screenshot) async {
    final Database db = await _dbProvider.database;
    await db.insert('Screenshots', {
      'id': screenshot.id,
      'title': screenshot.title,
      'description': screenshot.description,
      'image_path': screenshot.imagePath,
      'creation_date': screenshot.creationDate.toIso8601String(),
      'source_url': screenshot.sourceUrl,
      'upload_timestamp': screenshot.uploadTimestamp.toIso8601String(),
    });
  }

  Future<List<ScreenshotEntity>> listScreenshots({int? limit, int? offset}) async {
    final Database db = await _dbProvider.database;
    final List<Map<String, Object?>> rows = await db.query(
      'Screenshots',
      orderBy: 'creation_date DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((r) {
      return ScreenshotEntity(
        id: r['id']! as String,
        title: r['title'] as String?,
        description: r['description'] as String?,
        imagePath: r['image_path']! as String,
        creationDate: DateTime.parse(r['creation_date']! as String),
        sourceUrl: r['source_url'] as String?,
        uploadTimestamp: DateTime.parse(r['upload_timestamp']! as String),
      );
    }).toList();
  }

  Future<DesignSpecificationEntity?> getDesignSpecifications(String screenshotId) async {
    final Database db = await _dbProvider.database;
    final List<Map<String, Object?>> rows = await db.query(
      'Design_Specifications',
      where: 'screenshot_id = ?',
      whereArgs: [screenshotId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final Map<String, Object?> r = rows.first;
    return DesignSpecificationEntity(
      id: r['id']! as String,
      screenshotId: r['screenshot_id']! as String,
      layoutStructure: _parseMap(r['layout_structure'] as String?),
      uiComponents: _parseList(r['ui_components'] as String?),
      colorPalette: _parseList(r['color_palette'] as String?),
      typography: _parseList(r['typography'] as String?),
      generalDesignInfo: _parseMap(r['general_design_info'] as String?),
      analysisTimestamp: DateTime.parse(r['analysis_timestamp']! as String),
      analysisEngineVersion: r['analysis_engine_version'] as String?,
    );
  }

  Map<String, dynamic>? _parseMap(String? jsonStr) {
    if (jsonStr == null) return null;
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  List<Map<String, dynamic>>? _parseList(String? jsonStr) {
    if (jsonStr == null) return null;
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }
}

