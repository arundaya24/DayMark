import 'package:daymark/core/utils/streak_calculator.dart';
import 'package:daymark/features/journal/presentation/providers/journal_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
