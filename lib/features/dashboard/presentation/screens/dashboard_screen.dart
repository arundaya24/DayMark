import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/core/utils/streak_calculator.dart';
import 'package:daymark/features/contribution/presentation/providers/contribution_provider.dart';
import 'package:daymark/features/contribution/presentation/widgets/contribution_heatmap.dart';
import 'package:daymark/features/contribution/presentation/widgets/streak_badge.dart';
import 'package:daymark/features/journal/presentation/providers/journal_provider.dart';
import 'package:daymark/features/journal/presentation/screens/journal_detail_screen.dart';
import 'package:daymark/features/journal/presentation/screens/journal_editor_screen.dart';
import 'package:daymark/features/journal/presentation/widgets/journal_card.dart';
import 'package:daymark/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final settings = ref.watch(settingsProvider);
    final streakStatsAsync = ref.watch(streakStatsProvider);
    final recentJournalsAsync = ref.watch(recentJournalsProvider);
    final repository = ref.watch(journalRepositoryProvider);

    final now = DateTime.now();
    final greeting = AppDateUtils.getTimeGreeting(now);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: colors.surfaceElevated,
          onRefresh: () async {
            ref.invalidate(streakStatsProvider);
            ref.invalidate(recentJournalsProvider);
            ref.invalidate(journalListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Date Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, ${settings.userName}',
                          style: typo.displayMedium.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.formatDisplay(now, 'EEEE, dd MMMM yyyy'),
                          style: typo.monoLabel.copyWith(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    streakStatsAsync.when(
                      data: (stats) => StreakBadge(currentStreak: stats.currentStreak),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick Action Action Card (Clean, theme-adaptive, no excessive gradients)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Every day leaves a mark.',
                              style: typo.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capture a reflection, insight, or achievement for today.',
                              style: typo.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const JournalEditorScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'Mark Today',
                          style: typo.titleMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Streak & Stats Grid
                streakStatsAsync.when(
                  data: (stats) => StatsGrid(stats: stats),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (err, _) => Text('Error loading stats: $err', style: typo.bodySmall),
                ),

                const SizedBox(height: 20),

                // Contribution Heatmap Section
                streakStatsAsync.when(
                  data: (stats) => ContributionHeatmap(
                    contributionMap: stats.contributionMap,
                    repository: repository,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),

                // Monthly Statistics Card
                streakStatsAsync.when(
                  data: (stats) => _buildMonthlyStatsCard(context, stats),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Recent Activities Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RECENT MARKS', style: typo.monoLabel),
                    Text(
                      'Last 5 Entries',
                      style: typo.monoLabel.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recent Journals List
                recentJournalsAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 36, color: colors.textMuted),
                            const SizedBox(height: 10),
                            Text('No marks recorded yet', style: typo.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Mark Today" above to start your streak!',
                              style: typo.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: entries.map((entry) {
                        return JournalCard(
                          entry: entry,
                          hidePreview: settings.hidePreview,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JournalDetailScreen(entry: entry),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Text('Error: $e', style: typo.bodySmall),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyStatsCard(BuildContext context, StreakStats stats) {
    final colors = context.colors;
    final typo = context.typo;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Activity Breakdown', style: typo.titleLarge),
                ],
              ),
              Text(
                'This Month: ${stats.thisMonthContributions}',
                style: typo.monoLabel.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric(context, 'This Week', '${stats.thisWeekContributions}', Icons.view_week_outlined),
              Container(width: 1, height: 36, color: colors.borderSubtle),
              _buildStatMetric(context, 'This Month', '${stats.thisMonthContributions}', Icons.calendar_month_outlined),
              Container(width: 1, height: 36, color: colors.borderSubtle),
              _buildStatMetric(context, 'This Year', '${stats.thisYearContributions}', Icons.date_range_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(BuildContext context, String label, String value, IconData icon) {
    final colors = context.colors;
    final typo = context.typo;

    return Column(
      children: [
        Icon(icon, size: 18, color: colors.textMuted),
        const SizedBox(height: 6),
        Text(value, style: typo.headlineMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: typo.bodySmall),
      ],
    );
  }
}
