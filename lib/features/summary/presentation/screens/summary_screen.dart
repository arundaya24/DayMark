import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/services/pdf/pdf_export_service.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/settings/presentation/providers/settings_provider.dart';
import 'package:daymark/features/summary/domain/entities/journal_summary.dart';
import 'package:daymark/features/summary/presentation/providers/summary_provider.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  void _pickDateRange(BuildContext context, WidgetRef ref, SummaryState state) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: state.startDate, end: state.endDate),
    );

    if (picked != null) {
      ref.read(summaryProvider.notifier).setDateRange(picked.start, picked.end);
    }
  }

  void _setPresetRange(WidgetRef ref, int daysAgo) {
    final now = DateTime.now();
    ref.read(summaryProvider.notifier).setDateRange(
      now.subtract(Duration(days: daysAgo)),
      now,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final summaryState = ref.watch(summaryProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.journalSummary, style: typo.headlineLarge),
            Text(l10n.summarySubtitle, style: typo.bodySmall),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Picker Card
              Container(
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
                        Text(l10n.summaryPeriod, style: typo.monoLabel),
                        Text(
                          settings.aiProvider == 'gemini' && settings.geminiApiKey.isNotEmpty
                              ? 'Gemini Cloud'
                              : 'Local Engine',
                          style: typo.monoLabel.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Date display box (responsive with Expanded)
                    GestureDetector(
                      onTap: () => _pickDateRange(context, ref, summaryState),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.date_range_rounded, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${AppDateUtils.formatDisplay(summaryState.startDate, 'dd MMM yyyy', settings.languageCode)} - ${AppDateUtils.formatDisplay(summaryState.endDate, 'dd MMM yyyy', settings.languageCode)}',
                                      style: typo.titleMedium.copyWith(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit_calendar_rounded, color: colors.textMuted, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Preset Quick Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetChip(context, l10n.last7Days, () => _setPresetRange(ref, 7)),
                          _buildPresetChip(context, l10n.last30Days, () => _setPresetRange(ref, 30)),
                          _buildPresetChip(context, l10n.past3Months, () => _setPresetRange(ref, 90)),
                          _buildPresetChip(context, l10n.past6Months, () => _setPresetRange(ref, 180)),
                          _buildPresetChip(context, l10n.thisYear, () {
                            final now = DateTime.now();
                            ref.read(summaryProvider.notifier).setDateRange(
                              DateTime(now.year, 1, 1),
                              now,
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: summaryState.isLoading
                            ? null
                            : () => ref.read(summaryProvider.notifier).generateSummary(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: summaryState.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.auto_awesome_rounded, size: 20),
                        label: Text(
                          summaryState.isLoading ? l10n.generatingSummary : l10n.generateSummary,
                          style: typo.titleMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Summary Result or Placeholders
              if (summaryState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          summaryState.errorMessage!,
                          style: typo.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (summaryState.summary != null) ...[
                _buildSummaryResultView(context, summaryState.summary!, settings.languageCode),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.periodSummaryTitle, style: typo.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          l10n.periodSummaryDesc,
                          textAlign: TextAlign.center,
                          style: typo.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(BuildContext context, String label, VoidCallback onTap) {
    final colors = context.colors;
    final typo = context.typo;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            label,
            style: typo.monoLabel.copyWith(
              color: colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryResultView(BuildContext context, JournalSummary summary, String languageCode) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Export to PDF Action Bar (Responsive)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.summaryReport,
                style: typo.monoLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => PdfExportService.exportSummaryPdf(summary, languageCode: languageCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.surface,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: Text(
                l10n.exportPdf,
                style: typo.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Executive Overview Card (Overflow 35px fixed with responsive Wrap)
        Container(
          width: double.infinity,
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
                children: [
                  const Icon(Icons.summarize_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.executiveOverview, style: typo.titleLarge),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                summary.executiveSummary,
                style: typo.bodyLarge.copyWith(height: 1.6),
              ),
              const SizedBox(height: 14),

              // Responsive footer info with Wrap to strictly prevent RenderFlex overflow
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  Text(
                    l10n.entriesAnalyzed(summary.totalEntries),
                    style: typo.monoLabel.copyWith(color: colors.textMuted),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      summary.providerUsed,
                      style: typo.monoLabel.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section: Key Activities
        _buildSectionCard(
          context: context,
          title: l10n.keyActivities,
          icon: Icons.checklist_rounded,
          accentColor: AppColors.primary,
          items: summary.keyActivities,
        ),

        const SizedBox(height: 16),

        // Section: Learnings & Insights
        _buildSectionCard(
          context: context,
          title: l10n.keyLearnings,
          icon: Icons.lightbulb_outline_rounded,
          accentColor: AppColors.accentIndigo,
          items: summary.learnings,
        ),

        const SizedBox(height: 16),

        // Section: Achievements & Milestones
        _buildSectionCard(
          context: context,
          title: l10n.achievements,
          icon: Icons.emoji_events_outlined,
          accentColor: AppColors.accentGold,
          items: summary.achievements,
        ),

        const SizedBox(height: 16),

        // Section: Challenges & Obstacles
        _buildSectionCard(
          context: context,
          title: l10n.challenges,
          icon: Icons.shield_outlined,
          accentColor: AppColors.accentRose,
          items: summary.challenges,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final typo = context.typo;

    return Container(
      width: double.infinity,
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
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: typo.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: typo.bodyMedium.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
