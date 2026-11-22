import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';
import '../models/journal_entry_model.dart';
import '../models/activity_log_model.dart';

class JournalLocalDataSource {
  final Uuid _uuid = const Uuid();

  Future<Database> get _db async => await AppDatabase.instance;

  Future<List<JournalEntryModel>> getAllJournals({
    String? searchQuery,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _db;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR content LIKE ? OR tags LIKE ?)');
      final queryParam = '%${searchQuery.trim()}%';
      whereArgs.addAll([queryParam, queryParam, queryParam]);
    }

    if (category != null && category.trim().isNotEmpty && category.toLowerCase() != 'all') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (startDate != null) {
      final startMillis = AppDateUtils.toLocalDateOnly(startDate).millisecondsSinceEpoch;
      whereClauses.add('created_at >= ?');
      whereArgs.add(startMillis);
    }

    if (endDate != null) {
      final endLocal = AppDateUtils.toLocalDateOnly(endDate).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      final endMillis = endLocal.millisecondsSinceEpoch;
      whereClauses.add('created_at <= ?');
      whereArgs.add(endMillis);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final maps = await db.query(
      AppDatabase.tableJournals,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'is_pinned DESC, created_at DESC',
    );

    return maps.map((e) => JournalEntryModel.fromMap(e)).toList();
  }

  Future<JournalEntryModel?> getJournalById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.tableJournals,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return JournalEntryModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> createJournal(JournalEntryModel entry) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        AppDatabase.tableJournals,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Create an activity log record for heatmap & streak tracking
      final activity = ActivityLogModel(
        id: _uuid.v4(),
        journalId: entry.id,
        actionType: 'create',
        timestamp: entry.createdAt,
        dateStr: AppDateUtils.formatDateKey(entry.createdAt),
      );
      await txn.insert(AppDatabase.tableActivities, activity.toMap());
    });
  }

  Future<void> updateJournal(JournalEntryModel entry) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        AppDatabase.tableJournals,
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      // Log an edit activity on the current local day
      final now = DateTime.now();
      final activity = ActivityLogModel(
        id: _uuid.v4(),
        journalId: entry.id,
        actionType: 'update',
        timestamp: now,
        dateStr: AppDateUtils.formatDateKey(now),
      );
      await txn.insert(AppDatabase.tableActivities, activity.toMap());
    });
  }

  Future<void> deleteJournal(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        AppDatabase.tableActivities,
        where: 'journal_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        AppDatabase.tableJournals,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<List<ActivityLogModel>> getAllActivities() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.tableActivities,
      orderBy: 'timestamp ASC',
    );
    return maps.map((e) => ActivityLogModel.fromMap(e)).toList();
  }

  Future<List<DateTime>> getAllActivityTimestamps() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.tableActivities,
      columns: ['timestamp'],
      orderBy: 'timestamp ASC',
    );
    return maps.map((e) => DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int)).toList();
  }

  Future<List<JournalEntryModel>> getJournalsByDateRange(DateTime start, DateTime end) async {
    final db = await _db;
    final startMillis = AppDateUtils.toLocalDateOnly(start).millisecondsSinceEpoch;
    final endLocal = AppDateUtils.toLocalDateOnly(end).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    final endMillis = endLocal.millisecondsSinceEpoch;

    final maps = await db.query(
      AppDatabase.tableJournals,
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startMillis, endMillis],
      orderBy: 'created_at ASC',
    );
    return maps.map((e) => JournalEntryModel.fromMap(e)).toList();
  }

  Future<List<JournalEntryModel>> getJournalsForDate(DateTime date) async {
    final db = await _db;
    final startMillis = AppDateUtils.toLocalDateOnly(date).millisecondsSinceEpoch;
    final endMillis = AppDateUtils.toLocalDateOnly(date).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;

    final maps = await db.query(
      AppDatabase.tableJournals,
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startMillis, endMillis],
      orderBy: 'created_at DESC',
    );
    return maps.map((e) => JournalEntryModel.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> exportAllData() async {
    final db = await _db;
    final journals = await db.query(AppDatabase.tableJournals);
    final activities = await db.query(AppDatabase.tableActivities);

    return {
      'app': 'DAYMARK',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'journals': journals,
      'activities': activities,
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    final db = await _db;
    final rawJournals = data['journals'] as List<dynamic>? ?? [];
    final rawActivities = data['activities'] as List<dynamic>? ?? [];

    await db.transaction((txn) async {
      await txn.delete(AppDatabase.tableJournals);
      await txn.delete(AppDatabase.tableActivities);

      for (final j in rawJournals) {
        if (j is Map<String, dynamic>) {
          await txn.insert(
            AppDatabase.tableJournals,
            j,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (final a in rawActivities) {
        if (a is Map<String, dynamic>) {
          await txn.insert(
            AppDatabase.tableActivities,
            a,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }
}
