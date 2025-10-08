import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const int _dbVersion = 1;
  static const String _dbFileName = 'inspiration_hub.db';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  static Future<Database> _openDatabase() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final dbPath = p.join(appSupportDir.path, _dbFileName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Add migration logic when bumping _dbVersion
      },
    );
  }

  static Future<void> _createSchema(Database db) async {
    // Screenshots table
    await db.execute('''
      CREATE TABLE Screenshots (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        image_path TEXT NOT NULL,
        creation_date TEXT,
        source_url TEXT,
        upload_timestamp TEXT
      )
    ''');

    // Tags table
    await db.execute('''
      CREATE TABLE Tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE Categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_category_id TEXT,
        UNIQUE(name, parent_category_id),
        FOREIGN KEY(parent_category_id) REFERENCES Categories(id) ON DELETE SET NULL
      )
    ''');

    // Junction: Screenshot_Tags
    await db.execute('''
      CREATE TABLE Screenshot_Tags (
        screenshot_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (screenshot_id, tag_id),
        FOREIGN KEY(screenshot_id) REFERENCES Screenshots(id) ON DELETE CASCADE,
        FOREIGN KEY(tag_id) REFERENCES Tags(id) ON DELETE CASCADE
      )
    ''');

    // Junction: Screenshot_Categories
    await db.execute('''
      CREATE TABLE Screenshot_Categories (
        screenshot_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        PRIMARY KEY (screenshot_id, category_id),
        FOREIGN KEY(screenshot_id) REFERENCES Screenshots(id) ON DELETE CASCADE,
        FOREIGN KEY(category_id) REFERENCES Categories(id) ON DELETE CASCADE
      )
    ''');

    // Design_Specifications table
    await db.execute('''
      CREATE TABLE Design_Specifications (
        id TEXT PRIMARY KEY,
        screenshot_id TEXT NOT NULL UNIQUE,
        layout_structure TEXT,
        ui_components TEXT,
        color_palette TEXT,
        typography TEXT,
        general_design_info TEXT,
        analysis_timestamp TEXT,
        analysis_engine_version TEXT,
        FOREIGN KEY(screenshot_id) REFERENCES Screenshots(id) ON DELETE CASCADE
      )
    ''');

    // Helpful indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_screenshots_creation_date ON Screenshots(creation_date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tags_name ON Tags(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_screenshot_tags_sid ON Screenshot_Tags(screenshot_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_screenshot_tags_tid ON Screenshot_Tags(tag_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_screenshot_categories_sid ON Screenshot_Categories(screenshot_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_screenshot_categories_cid ON Screenshot_Categories(category_id)');
  }
}
