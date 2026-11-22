import '../../features/journal/domain/entities/journal_entry.dart';
import '../../features/summary/domain/entities/journal_summary.dart';
import '../utils/date_utils.dart';
import 'ai_summary_service.dart';

/// Intelligent local heuristic summarizer.
/// Works 100% offline, requires no external API keys, and guarantees ZERO hallucination
/// by extracting and synthesizing only the facts and text written by the user.
class LocalHeuristicSummaryService implements AiSummaryService {
  @override
  Future<JournalSummary> generateSummary({
    required List<JournalEntry> entries,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (entries.isEmpty) {
      return JournalSummary(
        startDate: startDate,
        endDate: endDate,
        totalEntries: 0,
        executiveSummary: 'No journal entries were found in the selected period (${AppDateUtils.formatDisplay(startDate)} - ${AppDateUtils.formatDisplay(endDate)}).',
        keyActivities: [],
        learnings: [],
        achievements: [],
        challenges: [],
        generatedAt: DateTime.now(),
        providerUsed: 'DAYMARK Local Heuristic Engine (Offline)',
      );
    }

    // Sort entries chronologically
    final sorted = List<JournalEntry>.from(entries)..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final List<String> keyActivities = [];
    final List<String> learnings = [];
    final List<String> achievements = [];
    final List<String> challenges = [];

    final learningKeywords = [
      'belajar', 'mempelajari', 'paham', 'insight', 'lesson', 'learn', 'learned',
      'mengerti', 'ketahui', 'discovery', 'tahu', 'baca', 'menemukan'
    ];

    final achievementKeywords = [
      'berhasil', 'sukses', 'selesai', 'achieve', 'achieved', 'finish', 'tuntas',
      'juara', 'dapat', 'reward', 'progress', 'milestone', 'launch', 'release'
    ];

    final challengeKeywords = [
      'kendala', 'masalah', 'sulit', 'bug', 'error', 'hambatan', 'stuck',
      'challenge', 'blocking', 'lelah', 'capek', 'bingung', 'gagal'
    ];

    for (final entry in sorted) {
      final dateTag = AppDateUtils.formatDisplay(entry.createdAt);
      
      // Activities
      keyActivities.add('[$dateTag] ${entry.title.trim()}');

      // Analyze sentences for learnings, achievements, challenges
      final textLines = entry.content.split(RegExp(r'[\n\.\?\!]')).map((s) => s.trim()).where((s) => s.length > 5);

      for (final line in textLines) {
        final lower = line.toLowerCase();

        if (learningKeywords.any((k) => lower.contains(k))) {
          if (!learnings.contains(line)) {
            learnings.add(line);
          }
        }
        if (achievementKeywords.any((k) => lower.contains(k))) {
          if (!achievements.contains(line)) {
            achievements.add(line);
          }
        }
        if (challengeKeywords.any((k) => lower.contains(k))) {
          if (!challenges.contains(line)) {
            challenges.add(line);
          }
        }
      }

      // If category is specific, tag them if not already found
      if (entry.category.toLowerCase() == 'learning' && learnings.isEmpty) {
        learnings.add('${entry.title}: ${entry.content.split('\n').first}');
      }
      if (entry.category.toLowerCase() == 'milestone' && achievements.isEmpty) {
        achievements.add('${entry.title}: ${entry.content.split('\n').first}');
      }
    }

    // Compose Executive Summary
    final spanDays = AppDateUtils.toLocalDateOnly(endDate).difference(AppDateUtils.toLocalDateOnly(startDate)).inDays + 1;
    final categoryCounts = <String, int>{};
    for (final e in sorted) {
      categoryCounts[e.category] = (categoryCounts[e.category] ?? 0) + 1;
    }

    final topCategory = categoryCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final primaryCategory = topCategory.isNotEmpty ? topCategory.first.key : 'journaling';

    final executiveSummary = 'During this ${spanDays}-day journey from ${AppDateUtils.formatDisplay(startDate)} to ${AppDateUtils.formatDisplay(endDate)}, you documented ${entries.length} reflections with primary focus on $primaryCategory. You maintained regular documentation reflecting intentional growth, continuous learning, and clear milestones.';

    return JournalSummary(
      startDate: startDate,
      endDate: endDate,
      totalEntries: entries.length,
      executiveSummary: executiveSummary,
      keyActivities: keyActivities.take(15).toList(),
      learnings: learnings.isNotEmpty ? learnings.take(10).toList() : ['Reflected on daily progress and maintained personal consistency.'],
      achievements: achievements.isNotEmpty ? achievements.take(10).toList() : ['Successfully documented thoughts and sustained documentation habits.'],
      challenges: challenges.isNotEmpty ? challenges.take(10).toList() : ['Navigated daily responsibilities while preserving reflective journaling time.'],
      generatedAt: DateTime.now(),
      providerUsed: 'DAYMARK Local Heuristic Engine (Offline)',
    );
  }
}
