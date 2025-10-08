import 'package:sqflite/sqflite.dart';

import '../../models/design_specification.dart';
import '../../services/database.dart';

class DesignSpecDao {
  Future<void> upsert(DesignSpecificationModel spec, {Database? tx}) async {
    final db = tx ?? await AppDatabase.database;
    await db.insert('Design_Specifications', spec.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DesignSpecificationModel?> getByScreenshotId(String screenshotId) async {
    final db = await AppDatabase.database;
    final rows = await db.query('Design_Specifications', where: 'screenshot_id = ?', whereArgs: [screenshotId], limit: 1);
    if (rows.isEmpty) return null;
    return DesignSpecificationModel.fromMap(rows.first);
  }
}
