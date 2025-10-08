import 'package:sqflite/sqflite.dart';

import '../../models/screenshot.dart';
import '../../services/database.dart';
import '../dao/screenshot_dao.dart';

class ScreenshotRepository {
  final ScreenshotDao _dao = ScreenshotDao();

  Future<void> create(ScreenshotModel screenshot) => _dao.insert(screenshot);

  Future<ScreenshotModel?> getById(String id) => _dao.getById(id);

  Future<List<ScreenshotModel>> listAll({int? limit, int? offset}) => _dao.listAll(limit: limit, offset: offset);

  Future<void> update(ScreenshotModel screenshot) => _dao.update(screenshot);

  Future<void> delete(String id) => _dao.delete(id);

  Future<void> withTransaction(Future<void> Function(Database tx) action) async {
    final db = await AppDatabase.database;
    await db.transaction(action);
  }
}
