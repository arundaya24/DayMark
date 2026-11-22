import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai/ai_summary_service.dart';
import '../../../../core/services/ai/gemini_summary_service.dart';
import '../../../../core/services/ai/local_heuristic_summary_service.dart';
import '../../journal/presentation/providers/journal_provider.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import '../domain/entities/journal_summary.dart';

class SummaryState {
  final DateTime startDate;
  final DateTime endDate;
  final bool isLoading;
  final JournalSummary? summary;
  final String? errorMessage;

  const SummaryState({
    required this.startDate,
    required this.endDate,
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  SummaryState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
    JournalSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SummaryState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SummaryNotifier extends StateNotifier<SummaryState> {
  final Ref _ref;

  SummaryNotifier(this._ref)
      : super(SummaryState(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ));

  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end, clearError: true);
  }

  Future<void> generateSummary() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = _ref.read(journalRepositoryProvider);
      final settings = _ref.read(settingsProvider);

      final entries = await repo.getJournalsByDateRange(state.startDate, state.endDate);

      AiSummaryService service;
      if (settings.aiProvider == 'gemini' && settings.geminiApiKey.trim().isNotEmpty) {
        service = GeminiSummaryService(
          apiKey: settings.geminiApiKey,
          model: settings.geminiModel,
        );
      } else {
        service = LocalHeuristicSummaryService();
      }

      final result = await service.generateSummary(
        entries: entries,
        startDate: state.startDate,
        endDate: state.endDate,
      );

      state = state.copyWith(isLoading: false, summary: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate summary: ${e.toString()}',
      );
    }
  }
}

final summaryProvider = StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  return SummaryNotifier(ref);
});
