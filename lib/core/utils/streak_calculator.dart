import 'date_utils.dart';

class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;
  final int totalContributions;
  final int thisWeekContributions;
  final int thisMonthContributions;
  final int thisYearContributions;
  final Map<String, int> contributionMap; // 'YYYY-MM-DD' -> count

  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActiveDays,
    required this.totalContributions,
    required this.thisWeekContributions,
    required this.thisMonthContributions,
    required this.thisYearContributions,
    required this.contributionMap,
  });

  factory StreakStats.empty() {
    return const StreakStats(
      currentStreak: 0,
      longestStreak: 0,
      totalActiveDays: 0,
      totalContributions: 0,
      thisWeekContributions: 0,
      thisMonthContributions: 0,
      thisYearContributions: 0,
      contributionMap: {},
    );
  }
}

class StreakCalculator {
  /// Calculate streak and activity statistics given a list of activity dates.
  /// Uses strictly normalized device local dates ('YYYY-MM-DD').
  static StreakStats calculate(List<DateTime> activityDates, {DateTime? referenceDate}) {
    if (activityDates.isEmpty) {
      return StreakStats.empty();
    }

    final now = referenceDate ?? DateTime.now();
    final today = AppDateUtils.toLocalDateOnly(now);
    final todayKey = AppDateUtils.formatDateKey(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey = AppDateUtils.formatDateKey(yesterday);

    // Group activities by local date key 'YYYY-MM-DD'
    final Map<String, int> contributionMap = {};
    for (final dt in activityDates) {
      final key = AppDateUtils.formatDateKey(dt);
      contributionMap[key] = (contributionMap[key] ?? 0) + 1;
    }

    final totalContributions = activityDates.length;
    final totalActiveDays = contributionMap.length;

    // Sort distinct active dates in ascending order
    final sortedDateKeys = contributionMap.keys.toList()..sort();
    final List<DateTime> sortedDates = sortedDateKeys
        .map((k) => AppDateUtils.parseDateKey(k))
        .toList();

    // Calculate Longest Streak
    int longestStreak = 0;
    int runningStreak = 0;
    DateTime? prevDate;

    for (final d in sortedDates) {
      if (prevDate == null) {
        runningStreak = 1;
      } else {
        final diff = d.difference(prevDate).inDays;
        if (diff == 1) {
          runningStreak++;
        } else if (diff > 1) {
          runningStreak = 1;
        }
      }
      if (runningStreak > longestStreak) {
        longestStreak = runningStreak;
      }
      prevDate = d;
    }

    // Calculate Current Streak
    // If user has activity today, streak includes today and counts backward.
    // If user has NO activity today, but DID have activity yesterday, streak is preserved (still active!).
    // If neither today nor yesterday has activity, current streak is 0.
    int currentStreak = 0;
    DateTime checkDate;

    if (contributionMap.containsKey(todayKey)) {
      checkDate = today;
    } else if (contributionMap.containsKey(yesterdayKey)) {
      checkDate = yesterday;
    } else {
      checkDate = DateTime(1970); // Break streak
    }

    if (checkDate.year != 1970) {
      while (true) {
        final key = AppDateUtils.formatDateKey(checkDate);
        if (contributionMap.containsKey(key)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    // Weekly, Monthly, Yearly Contributions
    // Week start: Monday of current week
    final weekday = today.weekday; // 1 = Monday, 7 = Sunday
    final startOfWeek = today.subtract(Duration(days: weekday - 1));
    final startOfMonth = DateTime(today.year, today.month, 1);
    final startOfYear = DateTime(today.year, 1, 1);

    int thisWeek = 0;
    int thisMonth = 0;
    int thisYear = 0;

    for (final dt in activityDates) {
      final local = AppDateUtils.toLocalDateOnly(dt);
      if (!local.isBefore(startOfWeek)) {
        thisWeek++;
      }
      if (!local.isBefore(startOfMonth)) {
        thisMonth++;
      }
      if (!local.isBefore(startOfYear)) {
        thisYear++;
      }
    }

    return StreakStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalActiveDays: totalActiveDays,
      totalContributions: totalContributions,
      thisWeekContributions: thisWeek,
      thisMonthContributions: thisMonth,
      thisYearContributions: thisYear,
      contributionMap: contributionMap,
    );
  }
}
