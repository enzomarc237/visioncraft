import 'package:sqflite/sqflite.dart';

import '../../models/tag.dart';
import '../../services/database.dart';

class TagDao {
  Future<void> insert(TagModel tag, {Database? tx}) async {
    final db = tx ?? await AppDatabase.database;
    await db.insert('Tags', tag.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<TagModel?> getById(String id) async {
    final db = await AppDatabase.database;
    final rows = await db.query('Tags', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TagModel.fromMap(rows.first);
  }

  Future<TagModel?> getByName(String name) async {
    final db = await AppDatabase.database;
    final rows = await db.query('Tags', where: 'name = ?', whereArgs: [name], limit: 1);
    if (rows.isEmpty) return null;
    return TagModel.fromMap(rows.first);
  }

  Future<List<TagModel>> listAll() async {
    final db = await AppDatabase.database;
    final rows = await db.query('Tags', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map((e) => TagModel.fromMap(e)).toList();
  }
}
