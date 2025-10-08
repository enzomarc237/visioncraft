import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await database;
  }

  Future<Database> _initDatabase() async {
    final appDir = await getApplicationSupportDirectory();
    final dbPath = join(appDir.path, 'ai_design_hub.db');
    
    // Ensure directory exists
    await Directory(dirname(dbPath)).create(recursive: true);

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Screenshots table
    await db.execute('''
      CREATE TABLE screenshots (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        image_path TEXT NOT NULL,
        creation_date TEXT NOT NULL,
        source_url TEXT,
        upload_timestamp TEXT NOT NULL
      )
    ''');

    // Tags table
    await db.execute('''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_category_id TEXT,
        FOREIGN KEY (parent_category_id) REFERENCES categories (id)
      )
    ''');

    // Screenshot_Tags junction table
    await db.execute('''
      CREATE TABLE screenshot_tags (
        screenshot_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (screenshot_id, tag_id),
        FOREIGN KEY (screenshot_id) REFERENCES screenshots (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // Screenshot_Categories junction table
    await db.execute('''
      CREATE TABLE screenshot_categories (
        screenshot_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        PRIMARY KEY (screenshot_id, category_id),
        FOREIGN KEY (screenshot_id) REFERENCES screenshots (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Design_Specifications table
    await db.execute('''
      CREATE TABLE design_specifications (
        id TEXT PRIMARY KEY,
        screenshot_id TEXT UNIQUE NOT NULL,
        layout_structure TEXT,
        ui_components TEXT,
        color_palette TEXT,
        typography TEXT,
        general_design_info TEXT,
        analysis_timestamp TEXT NOT NULL,
        analysis_engine_version TEXT,
        FOREIGN KEY (screenshot_id) REFERENCES screenshots (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_screenshot_creation_date ON screenshots(creation_date)');
    await db.execute('CREATE INDEX idx_tags_name ON tags(name)');
    await db.execute('CREATE INDEX idx_screenshot_tags_screenshot ON screenshot_tags(screenshot_id)');
    await db.execute('CREATE INDEX idx_screenshot_tags_tag ON screenshot_tags(tag_id)');
    await db.execute('CREATE INDEX idx_screenshot_categories_screenshot ON screenshot_categories(screenshot_id)');
    await db.execute('CREATE INDEX idx_screenshot_categories_category ON screenshot_categories(category_id)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}