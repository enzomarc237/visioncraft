import 'package:sqflite/sqflite.dart';

import '../../models/category.dart';
import '../../services/database.dart';

class CategoryDao {
  Future<void> insert(CategoryModel category, {Database? tx}) async {
    final db = tx ?? await AppDatabase.database;
    await db.insert('Categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<CategoryModel?> getById(String id) async {
    final db = await AppDatabase.database;
    final rows = await db.query('Categories', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return CategoryModel.fromMap(rows.first);
  }

  Future<List<CategoryModel>> listAll() async {
    final db = await AppDatabase.database;
    final rows = await db.query('Categories', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map((e) => CategoryModel.fromMap(e)).toList();
  }
}
