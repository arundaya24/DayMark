import 'package:daymark/core/constants/app_theme.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/core/utils/streak_calculator.dart';
import 'package:daymark/features/contribution/presentation/widgets/streak_badge.dart';
import 'package:daymark/features/journal/domain/entities/journal_entry.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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

  group('DAYMARK Dashboard Header Layout Overflow Tests', () {
    testWidgets('Header row with long user name does not overflow on narrow screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Good afternoon, Kalingga Kusuma Wardhana',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sunday, 22 November 2026',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const StreakBadge(currentStreak: 14),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(StreakBadge), findsOneWidget);
    });
  });

  group('DAYMARK Summary Screen Executive Overview Overflow Tests', () {
    testWidgets('Executive Overview footer with long engine string wraps without overflow on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Executive Overview'),
                    const SizedBox(height: 10),
                    const Text('During this 30-day journey, you documented 12 reflections with primary focus on learning.'),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: const [
                        Text('12 entries analyzed'),
                        Text('DAYMARK Local Heuristic Engine (Offline)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('DAYMARK Local Heuristic Engine (Offline)'), findsOneWidget);
    });
  });

  group('DAYMARK Localization Multi-Language Tests', () {
    test('Indonesian (id) provides correct default strings', () {
      final l10nId = AppLocalizations(const Locale('id'));
      expect(l10nId.dashboard, 'Dasbor');
      expect(l10nId.journal, 'Jurnal');
      expect(l10nId.summary, 'Ringkasan');
      expect(l10nId.settings, 'Pengaturan');
      expect(l10nId.markToday, 'Catat Hari Ini');
      expect(l10nId.currentStreak, 'Streak Saat Ini');
      expect(l10nId.totalActiveDays, 'Total Hari Aktif');
      expect(l10nId.generateSummary, 'Buat Ringkasan');
      expect(l10nId.exportPdf, 'Ekspor PDF');
      expect(l10nId.tagline, 'Setiap hari meninggalkan jejak.');
      expect(l10nId.categoryName('daily'), 'Refleksi Harian');
      expect(l10nId.categoryName('learning'), 'Pembelajaran');
    });

    test('English (en) provides correct strings', () {
      final l10nEn = AppLocalizations(const Locale('en'));
      expect(l10nEn.dashboard, 'Dashboard');
      expect(l10nEn.journal, 'Journal');
      expect(l10nEn.summary, 'Summary');
      expect(l10nEn.settings, 'Settings');
      expect(l10nEn.markToday, 'Mark Today');
      expect(l10nEn.currentStreak, 'Current Streak');
      expect(l10nEn.totalActiveDays, 'Total Active Days');
      expect(l10nEn.generateSummary, 'Generate Summary');
      expect(l10nEn.exportPdf, 'Export PDF');
      expect(l10nEn.tagline, 'Every day leaves a mark.');
      expect(l10nEn.categoryName('daily'), 'Daily Reflection');
      expect(l10nEn.categoryName('learning'), 'Learning');
    });

    test('Greeting changes with locale and time', () {
      final morning = DateTime(2026, 11, 22, 9, 0);
      final l10nId = AppLocalizations(const Locale('id'));
      final l10nEn = AppLocalizations(const Locale('en'));

      expect(l10nId.greeting(morning), 'Selamat pagi');
      expect(l10nEn.greeting(morning), 'Good morning');
    });
  });
}
