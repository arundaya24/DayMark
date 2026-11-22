import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/journal_local_data_source.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

final journalDataSourceProvider = Provider<JournalLocalDataSource>((ref) {
  return JournalLocalDataSource();
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final ds = ref.watch(journalDataSourceProvider);
  return JournalRepositoryImpl(dataSource: ds);
});

class JournalFilterState {
  final String searchQuery;
  final String selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;

  const JournalFilterState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.startDate,
    this.endDate,
  });

  JournalFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return JournalFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}

class JournalFilterNotifier extends StateNotifier<JournalFilterState> {
  JournalFilterNotifier() : super(const JournalFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      state = state.copyWith(clearDates: true);
    } else {
      state = state.copyWith(startDate: start, endDate: end);
    }
  }

  void resetFilters() {
    state = const JournalFilterState();
  }
}

final journalFilterProvider = StateNotifierProvider<JournalFilterNotifier, JournalFilterState>((ref) {
  return JournalFilterNotifier();
});

class JournalListNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final JournalRepository _repository;
  final Ref _ref;

  JournalListNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadJournals();
  }

  Future<void> loadJournals() async {
    state = const AsyncValue.loading();
    try {
      final filter = _ref.read(journalFilterProvider);
      final journals = await _repository.getAllJournals(
        searchQuery: filter.searchQuery,
        category: filter.selectedCategory,
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
      state = AsyncValue.data(journals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createJournal(JournalEntry entry) async {
    await _repository.createJournal(entry);
    await loadJournals();
  }

  Future<void> updateJournal(JournalEntry entry) async {
    await _repository.updateJournal(entry);
    await loadJournals();
  }

  Future<void> deleteJournal(String id) async {
    await _repository.deleteJournal(id);
    await loadJournals();
  }
}

final journalListProvider = StateNotifierProvider<JournalListNotifier, AsyncValue<List<JournalEntry>>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  final notifier = JournalListNotifier(repo, ref);
  
  // Reload whenever filter state changes
  ref.listen<JournalFilterState>(journalFilterProvider, (_, _) {
    notifier.loadJournals();
  });

  return notifier;
});

final recentJournalsProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final repo = ref.watch(journalRepositoryProvider);
  // Re-run when journalListProvider changes
  ref.watch(journalListProvider);
  final all = await repo.getAllJournals();
  return all.take(5).toList();
});
