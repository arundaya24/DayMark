import 'package:daymark/features/journal/domain/entities/journal_entry.dart';
import 'package:daymark/features/summary/domain/entities/journal_summary.dart';

abstract class AiSummaryService {
  Future<JournalSummary> generateSummary({
    required List<JournalEntry> entries,
    required DateTime startDate,
    required DateTime endDate,
    String languageCode = 'id',
  });
}
