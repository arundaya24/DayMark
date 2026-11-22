import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/services/pdf/pdf_export_service.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/settings/presentation/providers/settings_provider.dart';
import 'package:daymark/features/summary/domain/entities/journal_summary.dart';
import 'package:daymark/features/summary/presentation/providers/summary_provider.dart';
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
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceElevated,
            ),
          ),
          child: child!,
        );
      },
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
    final summaryState = ref.watch(summaryProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journal Summary', style: AppTypography.headlineLarge),
            Text('Synthesize insights & export report', style: AppTypography.bodySmall),
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
                padding: const EdgeInsets.all(16),
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
                        Text('SUMMARY PERIOD', style: AppTypography.monoLabel),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            settings.aiProvider == 'gemini' && settings.geminiApiKey.isNotEmpty
                                ? 'Gemini AI Active'
                                : 'Local Heuristic AI',
                            style: AppTypography.monoLabel.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Date display box
                    GestureDetector(
                      onTap: () => _pickDateRange(context, ref, summaryState),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  '${AppDateUtils.formatDisplay(summaryState.startDate)} - ${AppDateUtils.formatDisplay(summaryState.endDate)}',
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Icon(Icons.edit_calendar_rounded, color: AppColors.textMuted, size: 18),
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
                          _buildPresetChip('Last 7 Days', () => _setPresetRange(ref, 7)),
                          _buildPresetChip('Last 30 Days', () => _setPresetRange(ref, 30)),
                          _buildPresetChip('Past 3 Months', () => _setPresetRange(ref, 90)),
                          _buildPresetChip('Past 6 Months', () => _setPresetRange(ref, 180)),
                          _buildPresetChip('This Year', () {
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
                          summaryState.isLoading ? 'Synthesizing with AI...' : 'Generate Summary',
                          style: AppTypography.titleMedium.copyWith(
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
                          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (summaryState.summary != null) ...[
                _buildSummaryResultView(context, summaryState.summary!),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            size: 40,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('AI Period Summary', style: AppTypography.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Select your date range and generate a structured overview of your learnings, achievements, and challenges.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium,
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

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: AppTypography.monoLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryResultView(BuildContext context, JournalSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Export to PDF Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SUMMARY REPORT', style: AppTypography.monoLabel),
            ElevatedButton.icon(
              onPressed: () => PdfExportService.exportSummaryPdf(summary),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.primaryLight,
                side: const BorderSide(color: AppColors.primary, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: Text(
                'Export PDF',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Executive Overview Card
        Container(
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
                children: [
                  const Icon(Icons.summarize_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Executive Overview', style: AppTypography.titleLarge),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                summary.executiveSummary,
                style: AppTypography.bodyLarge.copyWith(height: 1.6),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${summary.totalEntries} entries analyzed',
                    style: AppTypography.monoLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  Text(
                    summary.providerUsed,
                    style: AppTypography.monoLabel.copyWith(color: AppColors.primaryLight, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section: Key Activities
        _buildSectionCard(
          title: 'Key Activities & Timeline',
          icon: Icons.checklist_rounded,
          accentColor: AppColors.primary,
          items: summary.keyActivities,
        ),

        const SizedBox(height: 16),

        // Section: Learnings & Insights
        _buildSectionCard(
          title: 'Key Learnings & Insights',
          icon: Icons.lightbulb_outline_rounded,
          accentColor: AppColors.accentIndigo,
          items: summary.learnings,
        ),

        const SizedBox(height: 16),

        // Section: Achievements & Milestones
        _buildSectionCard(
          title: 'Achievements & Milestones',
          icon: Icons.emoji_events_outlined,
          accentColor: AppColors.accentGold,
          items: summary.achievements,
        ),

        const SizedBox(height: 16),

        // Section: Challenges & Obstacles
        _buildSectionCard(
          title: 'Challenges & Obstacles',
          icon: Icons.shield_outlined,
          accentColor: AppColors.accentRose,
          items: summary.challenges,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

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
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.titleLarge),
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
                      style: AppTypography.bodyMedium.copyWith(height: 1.5),
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
