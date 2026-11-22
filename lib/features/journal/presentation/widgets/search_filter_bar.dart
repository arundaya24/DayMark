import 'package:daymark/core/constants/app_categories.dart';
import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final hasDateFilter = startDate != null || endDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Date Filter Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  style: typo.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.searchPlaceholder,
                    prefixIcon: Icon(Icons.search, color: colors.textMuted, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: typo.bodyMedium.copyWith(color: colors.textMuted),
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Date Filter Button
            GestureDetector(
              onTap: () => _pickDateRange(context),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: hasDateFilter ? AppColors.primary.withValues(alpha: 0.15) : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasDateFilter ? AppColors.primary : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      color: hasDateFilter ? AppColors.primary : colors.textSecondary,
                      size: 20,
                    ),
                    if (hasDateFilter) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onDateRangeSelected(null, null),
                        child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal Category Filter List
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryPill(context, 'All', selectedCategory == 'All', label: l10n.allCategories),
              ...AppCategories.all.map((c) {
                return _buildCategoryPill(context, c.id, selectedCategory == c.id, label: l10n.categoryName(c.id));
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPill(BuildContext context, String id, bool isSelected, {String? label}) {
    final colors = context.colors;
    final typo = context.typo;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onCategoryChanged(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : colors.border,
            ),
          ),
          child: Text(
            label ?? id,
            style: typo.labelMedium.copyWith(
              color: isSelected ? Colors.black : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }
}
