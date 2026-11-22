import 'package:daymark/core/constants/app_categories.dart';
import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/journal/domain/entities/journal_entry.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool hidePreview;

  const JournalCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onDelete,
    this.hidePreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final category = AppCategories.getById(entry.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: entry.isPinned ? AppColors.primary.withValues(alpha: 0.5) : colors.border,
            width: entry.isPinned ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Pill, Mood, Date & Pinned icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 12, color: category.color),
                      const SizedBox(width: 4),
                      Text(
                        l10n.categoryName(entry.category),
                        style: typo.monoLabel.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (entry.mood != null && entry.mood!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.mood!,
                      style: typo.monoLabel.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                if (entry.isPinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.push_pin_rounded, size: 16, color: AppColors.primary),
                  ),
                Text(
                  AppDateUtils.formatRelative(entry.createdAt, l10n.locale.languageCode),
                  style: typo.monoLabel,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              entry.title,
              style: typo.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Content preview (hidden if user turned on hidePreview)
            if (!hidePreview && entry.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                entry.content.replaceAll('\n', ' '),
                style: typo.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Tags (if any)
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: entry.tags.take(3).map((tag) {
                  return Text(
                    '#$tag',
                    style: typo.monoLabel.copyWith(
                      color: colors.textMuted,
                      fontSize: 10,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
