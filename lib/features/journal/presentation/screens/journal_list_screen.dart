import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import '../providers/journal_provider.dart';
import '../widgets/journal_card.dart';
import '../widgets/search_filter_bar.dart';
import 'journal_detail_screen.dart';
import 'journal_editor_screen.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(journalFilterProvider);
    final filterNotifier = ref.read(journalFilterProvider.notifier);
    final journalListAsync = ref.watch(journalListProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline', style: AppTypography.headlineLarge),
            Text('Every day leaves a mark.', style: AppTypography.bodySmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.edit_outlined),
        label: Text('New Entry', style: AppTypography.titleMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JournalEditorScreen()),
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              SearchFilterBar(
                searchQuery: filterState.searchQuery,
                onSearchChanged: filterNotifier.setSearchQuery,
                selectedCategory: filterState.selectedCategory,
                onCategoryChanged: filterNotifier.setCategory,
                startDate: filterState.startDate,
                endDate: filterState.endDate,
                onDateRangeSelected: filterNotifier.setDateRange,
              ),
              const SizedBox(height: 16),

              // Journal Entries List
              Expanded(
                child: journalListAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (err, _) => Center(
                    child: Text('Error loading journals: $err', style: AppTypography.bodyMedium),
                  ),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.auto_stories_outlined,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('No journals found', style: AppTypography.titleLarge),
                            const SizedBox(height: 6),
                            Text(
                              filterState.searchQuery.isNotEmpty || filterState.selectedCategory != 'All' || filterState.startDate != null
                                  ? 'Try adjusting your filters or search terms.'
                                  : 'Begin documenting your thoughts and journey today.',
                              style: AppTypography.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceElevated,
                      onRefresh: () async {
                        await ref.read(journalListProvider.notifier).loadJournals();
                      },
                      child: ListView.builder(
                        itemCount: entries.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
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
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
