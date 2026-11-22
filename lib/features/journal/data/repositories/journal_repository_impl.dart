import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/activity_log.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_local_data_source.dart';
import '../models/journal_entry_model.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource dataSource;

  JournalRepositoryImpl({required this.dataSource});

  @override
  Future<List<JournalEntry>> getAllJournals({
    String? searchQuery,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await dataSource.getAllJournals(
      searchQuery: searchQuery,
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<JournalEntry?> getJournalById(String id) async {
    return await dataSource.getJournalById(id);
  }

  @override
  Future<void> createJournal(JournalEntry entry) async {
    await dataSource.createJournal(JournalEntryModel.fromEntity(entry));
  }

  @override
  Future<void> updateJournal(JournalEntry entry) async {
    await dataSource.updateJournal(JournalEntryModel.fromEntity(entry));
  }

  @override
  Future<void> deleteJournal(String id) async {
    await dataSource.deleteJournal(id);
  }

  @override
  Future<List<ActivityLog>> getAllActivities() async {
    return await dataSource.getAllActivities();
  }

  @override
  Future<List<DateTime>> getAllActivityTimestamps() async {
    return await dataSource.getAllActivityTimestamps();
  }

  @override
  Future<List<JournalEntry>> getJournalsByDateRange(DateTime start, DateTime end) async {
    return await dataSource.getJournalsByDateRange(start, end);
  }

  @override
  Future<List<JournalEntry>> getJournalsForDate(DateTime date) async {
    return await dataSource.getJournalsForDate(date);
  }

  @override
  Future<Map<String, dynamic>> exportAllData() async {
    return await dataSource.exportAllData();
  }

  @override
  Future<void> importAllData(Map<String, dynamic> data) async {
    await dataSource.importAllData(data);
  }
}
