import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../contribution/presentation/providers/contribution_provider.dart';
import '../../contribution/presentation/widgets/contribution_heatmap.dart';
import '../../contribution/presentation/widgets/streak_badge.dart';
import '../../journal/presentation/providers/journal_provider.dart';
import '../../journal/presentation/screens/journal_detail_screen.dart';
import '../../journal/presentation/screens/journal_editor_screen.dart';
import '../../journal/presentation/widgets/journal_card.dart';
import '../../settings/presentation/providers/settings_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final streakStatsAsync = ref.watch(streakStatsProvider);
    final recentJournalsAsync = ref.watch(recentJournalsProvider);
    final repository = ref.watch(journalRepositoryProvider);

    final now = DateTime.now();
    final greeting = AppDateUtils.getTimeGreeting(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceElevated,
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
                          style: AppTypography.displayMedium.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.formatDisplay(now, 'EEEE, dd MMMM yyyy'),
                          style: AppTypography.monoLabel.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    streakStatsAsync.when(
                      data: (stats) => StreakBadge(currentStreak: stats.currentStreak),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick Action Hero Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF13322B), Color(0xFF14181F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryDark.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Every day leaves a mark.',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capture a reflection, insight, or achievement for today.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
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
                          style: AppTypography.titleMedium.copyWith(
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
                  error: (err, _) => Text('Error loading stats: $err', style: AppTypography.bodySmall),
                ),

                const SizedBox(height: 20),

                // Contribution Heatmap Section
                streakStatsAsync.when(
                  data: (stats) => ContributionHeatmap(
                    contributionMap: stats.contributionMap,
                    repository: repository,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),

                // Monthly Statistics Card
                streakStatsAsync.when(
                  data: (stats) => _buildMonthlyStatsCard(stats),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Recent Activities Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RECENT MARKS', style: AppTypography.monoLabel),
                    Text(
                      'Last 5 Entries',
                      style: AppTypography.monoLabel.copyWith(color: AppColors.textMuted),
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 36, color: AppColors.textMuted),
                            const SizedBox(height: 10),
                            Text('No marks recorded yet', style: AppTypography.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Mark Today" above to start your streak!',
                              style: AppTypography.bodySmall,
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
                  error: (e, _) => Text('Error: $e', style: AppTypography.bodySmall),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyStatsCard(StreakStats stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  Text('Activity Breakdown', style: AppTypography.titleLarge),
                ],
              ),
              Text(
                'This Month: ${stats.thisMonthContributions}',
                style: AppTypography.monoLabel.copyWith(color: AppColors.primaryLight),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric('This Week', '${stats.thisWeekContributions}', Icons.view_week_outlined),
              Container(width: 1, height: 36, color: AppColors.borderSubtle),
              _buildStatMetric('This Month', '${stats.thisMonthContributions}', Icons.calendar_month_outlined),
              Container(width: 1, height: 36, color: AppColors.borderSubtle),
              _buildStatMetric('This Year', '${stats.thisYearContributions}', Icons.date_range_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(height: 6),
        Text(value, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}
