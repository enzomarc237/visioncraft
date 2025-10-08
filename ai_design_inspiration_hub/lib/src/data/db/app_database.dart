import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabaseProvider {
  static final AppDatabaseProvider _instance = AppDatabaseProvider._();
  Database? _db;

  AppDatabaseProvider._();

  factory AppDatabaseProvider() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory dir = await getApplicationSupportDirectory();
    final String dbPath = p.join(dir.path, 'ai_design_inspiration_hub.db');
    _db = await databaseFactory.openDatabase(dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await _createSchema(db);
          },
        ));
    return _db!;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE Screenshots (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        image_path TEXT NOT NULL,
        creation_date TEXT NOT NULL,
        source_url TEXT,
        upload_timestamp TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      );
    ''');

    await db.execute('''
      CREATE TABLE Categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_category_id TEXT,
        UNIQUE(name, parent_category_id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Screenshot_Tags (
        screenshot_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (screenshot_id, tag_id),
        FOREIGN KEY (screenshot_id) REFERENCES Screenshots(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES Tags(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Screenshot_Categories (
        screenshot_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        PRIMARY KEY (screenshot_id, category_id),
        FOREIGN KEY (screenshot_id) REFERENCES Screenshots(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Design_Specifications (
        id TEXT PRIMARY KEY,
        screenshot_id TEXT NOT NULL UNIQUE,
        layout_structure TEXT,
        ui_components TEXT,
        color_palette TEXT,
        typography TEXT,
        general_design_info TEXT,
        analysis_timestamp TEXT NOT NULL,
        analysis_engine_version TEXT,
        FOREIGN KEY (screenshot_id) REFERENCES Screenshots(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('CREATE INDEX idx_screenshots_creation_date ON Screenshots(creation_date);');
    await db.execute('CREATE INDEX idx_tags_name ON Tags(name);');
    await db.execute('CREATE INDEX idx_sctag_sid ON Screenshot_Tags(screenshot_id);');
    await db.execute('CREATE INDEX idx_sctag_tid ON Screenshot_Tags(tag_id);');
    await db.execute('CREATE INDEX idx_sccat_sid ON Screenshot_Categories(screenshot_id);');
    await db.execute('CREATE INDEX idx_sccat_cid ON Screenshot_Categories(category_id);');
  }
}

