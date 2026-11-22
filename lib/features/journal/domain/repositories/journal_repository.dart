import '../entities/journal_entry.dart';
import '../entities/activity_log.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getAllJournals({
    String? searchQuery,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<JournalEntry?> getJournalById(String id);

  Future<void> createJournal(JournalEntry entry);

  Future<void> updateJournal(JournalEntry entry);

  Future<void> deleteJournal(String id);

  Future<List<ActivityLog>> getAllActivities();

  Future<List<DateTime>> getAllActivityTimestamps();

  Future<List<JournalEntry>> getJournalsByDateRange(DateTime start, DateTime end);

  Future<List<JournalEntry>> getJournalsForDate(DateTime date);

  Future<Map<String, dynamic>> exportAllData();

  Future<void> importAllData(Map<String, dynamic> data);
}
