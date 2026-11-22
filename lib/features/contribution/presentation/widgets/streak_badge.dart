import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/streak_calculator.dart';

class StreakBadge extends StatelessWidget {
  final int currentStreak;
  final VoidCallback? onTap;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasStreak = currentStreak > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: hasStreak ? AppColors.accentGold.withOpacity(0.12) : AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: hasStreak ? AppColors.accentGold.withOpacity(0.4) : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: hasStreak ? AppColors.accentGold : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '$currentStreak',
              style: AppTypography.titleMedium.copyWith(
                color: hasStreak ? AppColors.accentGold : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'day streak',
              style: AppTypography.labelMedium.copyWith(
                color: hasStreak ? AppColors.accentGold.withOpacity(0.9) : AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  final StreakStats stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Current Streak',
                value: '${stats.currentStreak} Days',
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.accentGold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Longest Streak',
                value: '${stats.longestStreak} Days',
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.primaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Active Days',
                value: '${stats.totalActiveDays}',
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.accentCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Contributions',
                value: '${stats.totalContributions}',
                icon: Icons.auto_graph_rounded,
                iconColor: AppColors.accentIndigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodySmall),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
