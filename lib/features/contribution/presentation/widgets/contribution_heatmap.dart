import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/journal/domain/repositories/journal_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContributionHeatmap extends StatefulWidget {
  final Map<String, int> contributionMap;
  final JournalRepository repository;
  final int weeksToShow;

  const ContributionHeatmap({
    super.key,
    required this.contributionMap,
    required this.repository,
    this.weeksToShow = 18,
  });

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap> {
  DateTime? _selectedDate;

  Color _getCellColor(int count, AppThemeColors colors) {
    if (count <= 0) return colors.heatLevel0;
    if (count == 1) return colors.heatLevel1;
    if (count <= 3) return colors.heatLevel2;
    if (count <= 5) return colors.heatLevel3;
    return colors.heatLevel4;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final today = AppDateUtils.toLocalDateOnly(DateTime.now());

    final currentWeekday = today.weekday; // 1 = Monday, 7 = Sunday
    final totalDays = (widget.weeksToShow - 1) * 7 + currentWeekday;
    final startDate = today.subtract(Duration(days: totalDays - 1));

    // Build week columns
    final List<List<DateTime>> weeks = [];
    DateTime cursor = startDate;

    for (int w = 0; w < widget.weeksToShow; w++) {
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

    // Determine month labels for columns
    final Map<int, String> monthLabels = {};
    int? lastMonth;
    for (int i = 0; i < weeks.length; i++) {
      final firstDayOfWeek = weeks[i].first;
      if (lastMonth == null || firstDayOfWeek.month != lastMonth) {
        monthLabels[i] = DateFormat('MMM').format(firstDayOfWeek);
        lastMonth = firstDayOfWeek.month;
      }
    }

    // Active selection info
    final selectedDay = _selectedDate ?? today;
    final selectedKey = AppDateUtils.formatDateKey(selectedDay);
    final selectedCount = widget.contributionMap[selectedKey] ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Selected Day Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Calendar',
                style: typo.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedCount > 0
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : colors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${DateFormat('d MMM').format(selectedDay)}: $selectedCount mark${selectedCount == 1 ? '' : 's'}',
                  style: typo.monoLabel.copyWith(
                    color: selectedCount > 0 ? AppColors.primary : colors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Grid (Right-aligned by default to show current date)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekday Labels on the Left
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 22),
                  child: Column(
                    children: [
                      _buildWeekdayLabel('Mon', typo),
                      const SizedBox(height: 19),
                      _buildWeekdayLabel('Wed', typo),
                      const SizedBox(height: 19),
                      _buildWeekdayLabel('Fri', typo),
                    ],
                  ),
                ),

                // Week Columns
                ...weeks.asMap().entries.map((entry) {
                  final weekIndex = entry.key;
                  final week = entry.value;
                  final monthLabel = monthLabels[weekIndex];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Header Label
                        SizedBox(
                          height: 18,
                          child: monthLabel != null
                              ? Text(
                                  monthLabel,
                                  style: typo.monoLabel.copyWith(
                                    fontSize: 10,
                                    color: colors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 4),

                        // 7 Days in Week
                        ...week.map((day) {
                          final dateKey = AppDateUtils.formatDateKey(day);
                          final count = widget.contributionMap[dateKey] ?? 0;
                          final cellColor = _getCellColor(count, colors);
                          final isToday = AppDateUtils.isSameDay(day, today);
                          final isSelected = _selectedDate != null &&
                              AppDateUtils.isSameDay(day, _selectedDate!);

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedDate = day);
                              if (count > 0) {
                                _showDayDetails(context, day, count);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isToday
                                          ? AppColors.primaryLight.withValues(alpha: 0.8)
                                          : Colors.transparent),
                                  width: isSelected ? 1.5 : (isToday ? 1 : 0),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Footer: Active days count and Clean Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.contributionMap.length} active days recorded',
                style: typo.bodySmall,
              ),
              Row(
                children: [
                  Text('Less', style: typo.monoLabel.copyWith(fontSize: 10)),
                  const SizedBox(width: 6),
                  _buildLegendBox(colors.heatLevel0, colors.border),
                  const SizedBox(width: 3),
                  _buildLegendBox(colors.heatLevel1),
                  const SizedBox(width: 3),
                  _buildLegendBox(colors.heatLevel2),
                  const SizedBox(width: 3),
                  _buildLegendBox(colors.heatLevel3),
                  const SizedBox(width: 3),
                  _buildLegendBox(colors.heatLevel4),
                  const SizedBox(width: 6),
                  Text('More', style: typo.monoLabel.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabel(String text, AppTypography typo) {
    return SizedBox(
      height: 14,
      child: Text(
        text,
        style: typo.monoLabel.copyWith(fontSize: 9),
      ),
    );
  }

  Widget _buildLegendBox(Color color, [Color? borderColor]) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
        border: borderColor != null ? Border.all(color: borderColor, width: 0.5) : null,
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime day, int count) async {
    final colors = context.colors;
    final typo = context.typo;
    final entries = await widget.repository.getJournalsForDate(day);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
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
                        style: typo.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count mark${count == 1 ? '' : 's'} recorded',
                        style: typo.bodyMedium.copyWith(
                          color: count > 0 ? AppColors.primary : colors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textMuted),
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
                      'No written reflections on this day.',
                      style: typo.bodyMedium,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => Divider(color: colors.borderSubtle),
                    itemBuilder: (ctx, index) {
                      final item = entries[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
                        ),
                        title: Text(item.title, style: typo.titleMedium),
                        subtitle: Text(
                          item.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typo.bodySmall,
                        ),
                        trailing: Text(
                          AppDateUtils.formatDisplay(item.createdAt, 'HH:mm'),
                          style: typo.monoLabel,
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
