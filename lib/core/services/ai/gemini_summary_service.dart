import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/journal/domain/entities/journal_entry.dart';
import '../../features/summary/domain/entities/journal_summary.dart';
import '../utils/date_utils.dart';
import 'ai_summary_service.dart';
import 'local_heuristic_summary_service.dart';

/// Google Gemini AI Summary Service
/// Uses Gemini REST API to summarize contextual journal entries.
/// Falls back to LocalHeuristicSummaryService if API key is missing or network fails.
class GeminiSummaryService implements AiSummaryService {
  final String apiKey;
  final String model;
  final LocalHeuristicSummaryService _fallbackService = LocalHeuristicSummaryService();

  GeminiSummaryService({
    required this.apiKey,
    this.model = 'gemini-1.5-flash',
  });

  @override
  Future<JournalSummary> generateSummary({
    required List<JournalEntry> entries,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (apiKey.trim().isEmpty) {
      // Fallback seamlessly to local heuristic engine
      return await _fallbackService.generateSummary(
        entries: entries,
        startDate: startDate,
        endDate: endDate,
      );
    }

    if (entries.isEmpty) {
      return await _fallbackService.generateSummary(
        entries: entries,
        startDate: startDate,
        endDate: endDate,
      );
    }

    try {
      final entriesText = entries.map((e) {
        return 'Date: ${AppDateUtils.formatDisplay(e.createdAt)}\nTitle: ${e.title}\nCategory: ${e.category}\nContent: ${e.content}\n---';
      }).join('\n');

      final prompt = '''
You are an expert personal reflection and executive summary assistant for the DAYMARK journal app.
Analyze the following user journal entries written between ${AppDateUtils.formatDisplay(startDate)} and ${AppDateUtils.formatDisplay(endDate)}.

CRITICAL RULES:
1. Base your summary SOLELY and STRICTLY on the provided entries below. Do NOT hallucinate or make up any event or information that the user never wrote.
2. Group and synthesize:
   - Executive Overview (2-3 concise, inspiring, professional sentences).
   - Key Activities & Highlights (list of important events/tasks).
   - Learnings & Insights (key knowledge gained or realizations).
   - Achievements & Progress (wins, completions, milestones).
   - Challenges & Obstacles (difficulties faced and noted).
3. Return ONLY a valid JSON object matching this exact structure:
{
  "executiveSummary": "...",
  "keyActivities": ["activity 1", "activity 2"],
  "learnings": ["learning 1", "learning 2"],
  "achievements": ["achievement 1", "achievement 2"],
  "challenges": ["challenge 1", "challenge 2"]
}

USER JOURNAL ENTRIES:
$entriesText
''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
            'responseMimeType': 'application/json',
          }
        }),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final rawJsonText = parts[0]['text'] as String;
            final parsed = jsonDecode(_sanitizeJson(rawJsonText));

            return JournalSummary(
              startDate: startDate,
              endDate: endDate,
              totalEntries: entries.length,
              executiveSummary: parsed['executiveSummary'] as String? ?? 'Summary generated successfully.',
              keyActivities: (parsed['keyActivities'] as List?)?.map((e) => e.toString()).toList() ?? [],
              learnings: (parsed['learnings'] as List?)?.map((e) => e.toString()).toList() ?? [],
              achievements: (parsed['achievements'] as List?)?.map((e) => e.toString()).toList() ?? [],
              challenges: (parsed['challenges'] as List?)?.map((e) => e.toString()).toList() ?? [],
              generatedAt: DateTime.now(),
              providerUsed: 'Google Gemini ($model)',
            );
          }
        }
      }

      // If response code is not 200, fallback gracefully
      return await _fallbackService.generateSummary(
        entries: entries,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (_) {
      // On network failure or timeout, fallback gracefully
      return await _fallbackService.generateSummary(
        entries: entries,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  String _sanitizeJson(String input) {
    var cleaned = input.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
}
