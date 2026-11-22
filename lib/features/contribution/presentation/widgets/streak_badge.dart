import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/utils/streak_calculator.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final bool hasStreak = currentStreak > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: hasStreak ? AppColors.accentGold.withValues(alpha: 0.12) : colors.surfaceHighlight,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: hasStreak ? AppColors.accentGold.withValues(alpha: 0.4) : colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: hasStreak ? AppColors.accentGold : colors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '$currentStreak',
              style: typo.titleMedium.copyWith(
                color: hasStreak ? AppColors.accentGold : colors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.dayStreak,
              style: typo.labelMedium.copyWith(
                color: hasStreak ? AppColors.accentGold.withValues(alpha: 0.9) : colors.textMuted,
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
    final l10n = context.l10n;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context: context,
                title: l10n.currentStreak,
                value: '${stats.currentStreak} ${l10n.days}',
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.accentGold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                title: l10n.longestStreak,
                value: '${stats.longestStreak} ${l10n.days}',
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
                context: context,
                title: l10n.totalActiveDays,
                value: '${stats.totalActiveDays}',
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.accentCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                title: l10n.totalMarks,
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
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final colors = context.colors;
    final typo = context.typo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: typo.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: typo.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
