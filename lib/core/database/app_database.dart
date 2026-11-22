import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static const String _databaseName = 'daymark.db';
  static const int _databaseVersion = 1;

  static const String tableJournals = 'journals';
  static const String tableActivities = 'activities';

  static Database? _database;

  static Future<Database> get instance async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // If running on desktop (Windows, Linux, macOS command line), initialize ffi factory
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (Platform.isWindows || Platform.isLinux) {
      final appSupportDir = await getApplicationSupportDirectory();
      path = join(appSupportDir.path, _databaseName);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Journals Table
    await db.execute('''
      CREATE TABLE $tableJournals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        tags TEXT NOT NULL,
        mood TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Activities Table (Activity logs for GitHub-style heatmap & streak calculation)
    await db.execute('''
      CREATE TABLE $tableActivities (
        id TEXT PRIMARY KEY,
        journal_id TEXT NOT NULL,
        action_type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        date_str TEXT NOT NULL,
        FOREIGN KEY (journal_id) REFERENCES $tableJournals (id) ON DELETE CASCADE
      )
    ''');

    // Create Indexes for fast querying
    await db.execute('CREATE INDEX idx_journals_created_at ON $tableJournals (created_at DESC)');
    await db.execute('CREATE INDEX idx_journals_category ON $tableJournals (category)');
    await db.execute('CREATE INDEX idx_activities_date_str ON $tableActivities (date_str)');
    await db.execute('CREATE INDEX idx_activities_timestamp ON $tableActivities (timestamp ASC)');
    await db.execute('CREATE INDEX idx_activities_journal_id ON $tableActivities (journal_id)');
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
