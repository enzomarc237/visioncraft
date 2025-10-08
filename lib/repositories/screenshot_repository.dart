import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/screenshot.dart';
import '../models/design_specification.dart';
import '../services/database_service.dart';

class ScreenshotRepository {
  final DatabaseService _databaseService;

  ScreenshotRepository(this._databaseService);

  Future<void> insertScreenshot(Screenshot screenshot) async {
    final db = await _databaseService.database;
    await db.insert(
      'screenshots',
      {
        'id': screenshot.id,
        'title': screenshot.title,
        'description': screenshot.description,
        'image_path': screenshot.imagePath,
        'creation_date': screenshot.creationDate.toIso8601String(),
        'source_url': screenshot.sourceUrl,
        'upload_timestamp': screenshot.uploadTimestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert tags
    for (final tag in screenshot.tags) {
      await _ensureTagExists(tag);
      await _linkScreenshotTag(screenshot.id, tag);
    }

    // Insert categories
    for (final category in screenshot.categories) {
      await _ensureCategoryExists(category);
      await _linkScreenshotCategory(screenshot.id, category);
    }
  }

  Future<void> _ensureTagExists(String tagName) async {
    final db = await _databaseService.database;
    final existing = await db.query(
      'tags',
      where: 'name = ?',
      whereArgs: [tagName],
    );

    if (existing.isEmpty) {
      await db.insert(
        'tags',
        {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'name': tagName},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _ensureCategoryExists(String categoryName) async {
    final db = await _databaseService.database;
    final existing = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [categoryName],
    );

    if (existing.isEmpty) {
      await db.insert(
        'categories',
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': categoryName,
          'parent_category_id': null,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _linkScreenshotTag(String screenshotId, String tagName) async {
    final db = await _databaseService.database;
    final tagResult = await db.query('tags', where: 'name = ?', whereArgs: [tagName]);
    if (tagResult.isNotEmpty) {
      await db.insert(
        'screenshot_tags',
        {'screenshot_id': screenshotId, 'tag_id': tagResult.first['id']},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _linkScreenshotCategory(String screenshotId, String categoryName) async {
    final db = await _databaseService.database;
    final categoryResult = await db.query('categories', where: 'name = ?', whereArgs: [categoryName]);
    if (categoryResult.isNotEmpty) {
      await db.insert(
        'screenshot_categories',
        {'screenshot_id': screenshotId, 'category_id': categoryResult.first['id']},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<Screenshot>> getAllScreenshots({
    List<String>? tags,
    List<String>? categories,
    String? titleQuery,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseService.database;
    
    String query = 'SELECT DISTINCT s.* FROM screenshots s';
    List<String> joins = [];
    List<String> conditions = [];
    List<dynamic> args = [];

    if (tags != null && tags.isNotEmpty) {
      joins.add('INNER JOIN screenshot_tags st ON s.id = st.screenshot_id');
      joins.add('INNER JOIN tags t ON st.tag_id = t.id');
      conditions.add('t.name IN (${tags.map((_) => '?').join(',')})');
      args.addAll(tags);
    }

    if (categories != null && categories.isNotEmpty) {
      joins.add('INNER JOIN screenshot_categories sc ON s.id = sc.screenshot_id');
      joins.add('INNER JOIN categories c ON sc.category_id = c.id');
      conditions.add('c.name IN (${categories.map((_) => '?').join(',')})');
      args.addAll(categories);
    }

    if (titleQuery != null && titleQuery.isNotEmpty) {
      conditions.add('(s.title LIKE ? OR s.description LIKE ?)');
      args.add('%$titleQuery%');
      args.add('%$titleQuery%');
    }

    if (dateFrom != null) {
      conditions.add('s.creation_date >= ?');
      args.add(dateFrom.toIso8601String());
    }

    if (dateTo != null) {
      conditions.add('s.creation_date <= ?');
      args.add(dateTo.toIso8601String());
    }

    if (joins.isNotEmpty) {
      query += ' ${joins.join(' ')}';
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY s.upload_timestamp DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
    }

    if (offset != null) {
      query += ' OFFSET $offset';
    }

    final results = await db.rawQuery(query, args);
    
    List<Screenshot> screenshots = [];
    for (final row in results) {
      final screenshot = await _buildScreenshotFromRow(row);
      screenshots.add(screenshot);
    }

    return screenshots;
  }

  Future<Screenshot?> getScreenshotById(String id) async {
    final db = await _databaseService.database;
    final results = await db.query(
      'screenshots',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return await _buildScreenshotFromRow(results.first);
  }

  Future<Screenshot> _buildScreenshotFromRow(Map<String, dynamic> row) async {
    final tags = await _getScreenshotTags(row['id'] as String);
    final categories = await _getScreenshotCategories(row['id'] as String);

    return Screenshot(
      id: row['id'] as String,
      title: row['title'] as String?,
      description: row['description'] as String?,
      imagePath: row['image_path'] as String,
      creationDate: DateTime.parse(row['creation_date'] as String),
      sourceUrl: row['source_url'] as String?,
      uploadTimestamp: DateTime.parse(row['upload_timestamp'] as String),
      tags: tags,
      categories: categories,
    );
  }

  Future<List<String>> _getScreenshotTags(String screenshotId) async {
    final db = await _databaseService.database;
    final results = await db.rawQuery('''
      SELECT t.name FROM tags t
      INNER JOIN screenshot_tags st ON t.id = st.tag_id
      WHERE st.screenshot_id = ?
    ''', [screenshotId]);

    return results.map((row) => row['name'] as String).toList();
  }

  Future<List<String>> _getScreenshotCategories(String screenshotId) async {
    final db = await _databaseService.database;
    final results = await db.rawQuery('''
      SELECT c.name FROM categories c
      INNER JOIN screenshot_categories sc ON c.id = sc.category_id
      WHERE sc.screenshot_id = ?
    ''', [screenshotId]);

    return results.map((row) => row['name'] as String).toList();
  }

  Future<void> updateScreenshot(Screenshot screenshot) async {
    final db = await _databaseService.database;
    
    await db.update(
      'screenshots',
      {
        'title': screenshot.title,
        'description': screenshot.description,
        'source_url': screenshot.sourceUrl,
      },
      where: 'id = ?',
      whereArgs: [screenshot.id],
    );

    // Update tags
    await db.delete('screenshot_tags', where: 'screenshot_id = ?', whereArgs: [screenshot.id]);
    for (final tag in screenshot.tags) {
      await _ensureTagExists(tag);
      await _linkScreenshotTag(screenshot.id, tag);
    }

    // Update categories
    await db.delete('screenshot_categories', where: 'screenshot_id = ?', whereArgs: [screenshot.id]);
    for (final category in screenshot.categories) {
      await _ensureCategoryExists(category);
      await _linkScreenshotCategory(screenshot.id, category);
    }
  }

  Future<void> deleteScreenshot(String id) async {
    final db = await _databaseService.database;
    await db.delete('screenshots', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertDesignSpecification(DesignSpecification spec) async {
    final db = await _databaseService.database;
    await db.insert(
      'design_specifications',
      {
        'id': spec.id,
        'screenshot_id': spec.screenshotId,
        'layout_structure': spec.layoutStructure != null 
            ? jsonEncode(spec.layoutStructure!.toJson()) 
            : null,
        'ui_components': jsonEncode(spec.uiComponents.map((c) => c.toJson()).toList()),
        'color_palette': jsonEncode(spec.colorPalette.map((c) => c.toJson()).toList()),
        'typography': jsonEncode(spec.typography.map((t) => t.toJson()).toList()),
        'general_design_info': spec.generalDesignInfo != null 
            ? jsonEncode(spec.generalDesignInfo) 
            : null,
        'analysis_timestamp': spec.analysisTimestamp.toIso8601String(),
        'analysis_engine_version': spec.analysisEngineVersion,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DesignSpecification?> getDesignSpecification(String screenshotId) async {
    final db = await _databaseService.database;
    final results = await db.query(
      'design_specifications',
      where: 'screenshot_id = ?',
      whereArgs: [screenshotId],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    return DesignSpecification(
      id: row['id'] as String,
      screenshotId: row['screenshot_id'] as String,
      layoutStructure: row['layout_structure'] != null
          ? LayoutStructure.fromJson(jsonDecode(row['layout_structure'] as String))
          : null,
      uiComponents: row['ui_components'] != null
          ? (jsonDecode(row['ui_components'] as String) as List)
              .map((c) => UiComponent.fromJson(c))
              .toList()
          : [],
      colorPalette: row['color_palette'] != null
          ? (jsonDecode(row['color_palette'] as String) as List)
              .map((c) => ColorInfo.fromJson(c))
              .toList()
          : [],
      typography: row['typography'] != null
          ? (jsonDecode(row['typography'] as String) as List)
              .map((t) => TypographyStyle.fromJson(t))
              .toList()
          : [],
      generalDesignInfo: row['general_design_info'] != null
          ? jsonDecode(row['general_design_info'] as String)
          : null,
      analysisTimestamp: DateTime.parse(row['analysis_timestamp'] as String),
      analysisEngineVersion: row['analysis_engine_version'] as String?,
    );
  }

  Future<int> getScreenshotsCount({
    List<String>? tags,
    List<String>? categories,
    String? titleQuery,
  }) async {
    final db = await _databaseService.database;
    
    String query = 'SELECT COUNT(DISTINCT s.id) as count FROM screenshots s';
    List<String> joins = [];
    List<String> conditions = [];
    List<dynamic> args = [];

    if (tags != null && tags.isNotEmpty) {
      joins.add('INNER JOIN screenshot_tags st ON s.id = st.screenshot_id');
      joins.add('INNER JOIN tags t ON st.tag_id = t.id');
      conditions.add('t.name IN (${tags.map((_) => '?').join(',')})');
      args.addAll(tags);
    }

    if (categories != null && categories.isNotEmpty) {
      joins.add('INNER JOIN screenshot_categories sc ON s.id = sc.screenshot_id');
      joins.add('INNER JOIN categories c ON sc.category_id = c.id');
      conditions.add('c.name IN (${categories.map((_) => '?').join(',')})');
      args.addAll(categories);
    }

    if (titleQuery != null && titleQuery.isNotEmpty) {
      conditions.add('(s.title LIKE ? OR s.description LIKE ?)');
      args.add('%$titleQuery%');
      args.add('%$titleQuery%');
    }

    if (joins.isNotEmpty) {
      query += ' ${joins.join(' ')}';
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    final results = await db.rawQuery(query, args);
    return Sqflite.firstIntValue(results) ?? 0;
  }
}