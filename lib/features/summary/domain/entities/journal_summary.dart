class JournalSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalEntries;
  final String executiveSummary;
  final List<String> keyActivities;
  final List<String> learnings;
  final List<String> achievements;
  final List<String> challenges;
  final DateTime generatedAt;
  final String providerUsed;

  const JournalSummary({
    required this.startDate,
    required this.endDate,
    required this.totalEntries,
    required this.executiveSummary,
    required this.keyActivities,
    required this.learnings,
    required this.achievements,
    required this.challenges,
    required this.generatedAt,
    required this.providerUsed,
  });
}
