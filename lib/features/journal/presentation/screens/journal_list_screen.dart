import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/features/journal/presentation/providers/journal_provider.dart';
import 'package:daymark/features/journal/presentation/widgets/journal_card.dart';
import 'package:daymark/features/journal/presentation/widgets/search_filter_bar.dart';
import 'package:daymark/features/settings/presentation/providers/settings_provider.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_detail_screen.dart';
import 'journal_editor_screen.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final filterState = ref.watch(journalFilterProvider);
    final filterNotifier = ref.read(journalFilterProvider.notifier);
    final journalListAsync = ref.watch(journalListProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.timeline, style: typo.headlineLarge),
            Text(l10n.tagline, style: typo.bodySmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.edit_outlined),
        label: Text(l10n.newEntry, style: typo.titleMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
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
                    child: Text('Error: $err', style: typo.bodyMedium),
                  ),
                  data: (entries) {
                    if (entries.isEmpty) {
                      final isFiltered = filterState.searchQuery.isNotEmpty ||
                          filterState.selectedCategory != 'All' ||
                          filterState.startDate != null;

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.border),
                              ),
                              child: Icon(
                                Icons.auto_stories_outlined,
                                size: 48,
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isFiltered ? l10n.noJournalsMatch : l10n.noJournalsYet,
                              style: typo.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isFiltered
                                  ? (l10n.isIndonesian ? 'Coba sesuaikan filter atau kata kunci pencarian Anda.' : 'Try adjusting your filters or search terms.')
                                  : l10n.startWritingPrompt,
                              style: typo.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: colors.surfaceElevated,
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
