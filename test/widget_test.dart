import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/core/utils/streak_calculator.dart';
import 'package:daymark/features/journal/domain/entities/journal_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DAYMARK StreakCalculator Tests', () {
    test('Empty activity dates returns empty stats with 0 streak', () {
      final stats = StreakCalculator.calculate([]);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.totalActiveDays, 0);
      expect(stats.totalContributions, 0);
    });

    test('Multiple activities on same day count as 1 active day', () {
      final now = DateTime(2026, 11, 22, 10, 0);
      final activities = [
        DateTime(2026, 11, 22, 9, 0),
        DateTime(2026, 11, 22, 14, 30),
        DateTime(2026, 11, 22, 21, 15),
      ];

      final stats = StreakCalculator.calculate(activities, referenceDate: now);
      expect(stats.totalContributions, 3);
      expect(stats.totalActiveDays, 1);
      expect(stats.currentStreak, 1);
    });

    test('Consecutive days calculate streak accurately', () {
      final now = DateTime(2026, 11, 22, 12, 0);
      final activities = [
        DateTime(2026, 11, 20, 10, 0),
        DateTime(2026, 11, 21, 15, 0),
        DateTime(2026, 11, 22, 8, 30),
      ];

      final stats = StreakCalculator.calculate(activities, referenceDate: now);
      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
      expect(stats.totalActiveDays, 3);
    });

    test('If active yesterday but not yet today, streak is preserved', () {
      final now = DateTime(2026, 11, 22, 12, 0);
      final activities = [
        DateTime(2026, 11, 20, 10, 0),
        DateTime(2026, 11, 21, 15, 0),
      ];

      final stats = StreakCalculator.calculate(activities, referenceDate: now);
      expect(stats.currentStreak, 2);
    });

    test('Broken streak resets current streak to 0', () {
      final now = DateTime(2026, 11, 22, 12, 0);
      final activities = [
        DateTime(2026, 11, 15, 10, 0),
        DateTime(2026, 11, 16, 15, 0),
      ];

      final stats = StreakCalculator.calculate(activities, referenceDate: now);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 2);
    });
  });

  group('DAYMARK DateUtils Tests', () {
    test('Date key strictly formats YYYY-MM-DD regardless of time', () {
      final dt = DateTime(2026, 11, 22, 23, 59, 59);
      expect(AppDateUtils.formatDateKey(dt), '2026-11-22');
    });

    test('Time greeting identifies morning, afternoon, evening, night', () {
      expect(AppDateUtils.getTimeGreeting(DateTime(2026, 11, 22, 8, 0)), 'Good morning');
      expect(AppDateUtils.getTimeGreeting(DateTime(2026, 11, 22, 13, 0)), 'Good afternoon');
      expect(AppDateUtils.getTimeGreeting(DateTime(2026, 11, 22, 18, 0)), 'Good evening');
      expect(AppDateUtils.getTimeGreeting(DateTime(2026, 11, 22, 23, 0)), 'Good night');
    });
  });

  group('DAYMARK JournalEntry Model Tests', () {
    test('JournalEntry copyWith creates modified immutable clone', () {
      final entry = JournalEntry(
        id: 'test-1',
        title: 'Initial Title',
        content: 'Initial Content',
        category: 'daily',
        tags: ['tag1'],
        createdAt: DateTime(2026, 11, 22),
        updatedAt: DateTime(2026, 11, 22),
      );

      final updated = entry.copyWith(title: 'Updated Title', isPinned: true);
      expect(updated.id, 'test-1');
      expect(updated.title, 'Updated Title');
      expect(updated.content, 'Initial Content');
      expect(updated.isPinned, true);
    });
  });
}
