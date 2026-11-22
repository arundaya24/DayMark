import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/journal/domain/repositories/journal_repository.dart';
import 'package:flutter/material.dart';

class ContributionHeatmap extends StatelessWidget {
  final Map<String, int> contributionMap;
  final JournalRepository repository;
  final int weeksToShow;

  const ContributionHeatmap({
    super.key,
    required this.contributionMap,
    required this.repository,
    this.weeksToShow = 18,
  });

  Color _getCellColor(int count) {
    if (count <= 0) return AppColors.heatLevel0;
    if (count == 1) return AppColors.heatLevel1;
    if (count <= 3) return AppColors.heatLevel2;
    if (count <= 5) return AppColors.heatLevel3;
    return AppColors.heatLevel4;
  }

  @override
  Widget build(BuildContext context) {
    final today = AppDateUtils.toLocalDateOnly(DateTime.now());
    
    final currentWeekday = today.weekday;
    final totalDays = (weeksToShow - 1) * 7 + currentWeekday;
    final startDate = today.subtract(Duration(days: totalDays - 1));

    final List<List<DateTime>> weeks = [];
    DateTime cursor = startDate;

    for (int w = 0; w < weeksToShow; w++) {
      final List<DateTime> weekDays = [];
      for (int d = 0; d < 7; d++) {
        if (!cursor.isAfter(today)) {
          weekDays.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
      if (weekDays.isNotEmpty) {
        weeks.add(weekDays);
      }
    }

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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Activity Heatmap', style: AppTypography.titleLarge),
                ],
              ),
              Text(
                'GitHub Style',
                style: AppTypography.monoLabel.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Heatmap Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6, top: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mon', style: AppTypography.monoLabel.copyWith(fontSize: 9)),
                      const SizedBox(height: 14),
                      Text('Wed', style: AppTypography.monoLabel.copyWith(fontSize: 9)),
                      const SizedBox(height: 14),
                      Text('Fri', style: AppTypography.monoLabel.copyWith(fontSize: 9)),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),

                ...weeks.map((week) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Column(
                      children: week.map((day) {
                        final dateKey = AppDateUtils.formatDateKey(day);
                        final count = contributionMap[dateKey] ?? 0;
                        final color = _getCellColor(count);

                        return GestureDetector(
                          onTap: () => _showDayDetails(context, day, count),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2.5),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: AppDateUtils.isSameDay(day, today)
                                    ? AppColors.primaryLight.withValues(alpha: 0.8)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${contributionMap.length} active days logged',
                style: AppTypography.bodySmall,
              ),
              Row(
                children: [
                  Text('Less', style: AppTypography.monoLabel.copyWith(fontSize: 10)),
                  const SizedBox(width: 6),
                  _buildLegendBox(AppColors.heatLevel0),
                  const SizedBox(width: 3),
                  _buildLegendBox(AppColors.heatLevel1),
                  const SizedBox(width: 3),
                  _buildLegendBox(AppColors.heatLevel2),
                  const SizedBox(width: 3),
                  _buildLegendBox(AppColors.heatLevel3),
                  const SizedBox(width: 3),
                  _buildLegendBox(AppColors.heatLevel4),
                  const SizedBox(width: 6),
                  Text('More', style: AppTypography.monoLabel.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime day, int count) async {
    final entries = await repository.getJournalsForDate(day);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppDateUtils.formatDisplay(day, 'EEEE, dd MMMM yyyy'),
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count contribution${count == 1 ? '' : 's'} recorded',
                        style: AppTypography.bodyMedium.copyWith(
                          color: count > 0 ? AppColors.primary : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No journals written on this day.',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle),
                    itemBuilder: (ctx, index) {
                      final item = entries[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                        ),
                        title: Text(item.title, style: AppTypography.titleMedium),
                        subtitle: Text(
                          item.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall,
                        ),
                        trailing: Text(
                          AppDateUtils.formatDisplay(item.createdAt, 'HH:mm'),
                          style: AppTypography.monoLabel,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
