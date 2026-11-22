import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../../journal/presentation/providers/journal_provider.dart';

final streakStatsProvider = FutureProvider<StreakStats>((ref) async {
  final repo = ref.watch(journalRepositoryProvider);
  // Re-calculate when journals change
  ref.watch(journalListProvider);

  final timestamps = await repo.getAllActivityTimestamps();
  return StreakCalculator.calculate(timestamps);
});

final contributionMapProvider = FutureProvider<Map<String, int>>((ref) async {
  final stats = await ref.watch(streakStatsProvider.future);
  return stats.contributionMap;
});
