import 'package:sqflite/sqflite.dart';

import '../../models/screenshot.dart';
import '../../services/database.dart';

class ScreenshotDao {
  Future<void> insert(ScreenshotModel screenshot, {Database? tx}) async {
    final db = tx ?? await AppDatabase.database;
    await db.insert('Screenshots', screenshot.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ScreenshotModel?> getById(String id, {Database? tx}) async {
    final db = tx ?? await AppDatabase.database;
    final rows = await db.query('Screenshots', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ScreenshotModel.fromMap(rows.first);
  }

  Future<List<ScreenshotModel>> listAll({int? limit, int? offset}) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'Screenshots',
      orderBy: 'datetime(creation_date) DESC NULLS LAST, datetime(upload_timestamp) DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((e) => ScreenshotModel.fromMap(e)).toList();
  }

  Future<void> update(ScreenshotModel screenshot, {Database? tx}) async {
    final db = tx ?? await AppDatabase.database;
    await db.update('Screenshots', screenshot.toMap(), where: 'id = ?', whereArgs: [screenshot.id]);
  }

  Future<void> delete(String id, {Database? tx}) async {
    final db = tx ?? await AppDatabase.database;
    await db.delete('Screenshots', where: 'id = ?', whereArgs: [id]);
  }
}
