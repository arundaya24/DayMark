import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:daymark/features/journal/presentation/screens/journal_list_screen.dart';
import 'package:daymark/features/settings/presentation/providers/settings_provider.dart';
import 'package:daymark/features/settings/presentation/screens/settings_screen.dart';
import 'package:daymark/features/summary/presentation/screens/summary_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isUnlocked = false;
  final TextEditingController _pinController = TextEditingController();
  String? _pinError;

  final List<Widget> _screens = const [
    DashboardScreen(),
    JournalListScreen(),
    SummaryScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin(String correctPin, AppLocalizations l10n) {
    if (_pinController.text.trim() == correctPin) {
      setState(() {
        _isUnlocked = true;
        _pinError = null;
      });
    } else {
      setState(() {
        _pinError = l10n.incorrectPin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);

    // If PIN is enabled and not yet unlocked in this session, show lock screen
    if (settings.pinEnabled && settings.pinCode != null && !_isUnlocked) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.appTitle, style: typo.displayMedium),
                  const SizedBox(height: 6),
                  Text(l10n.enterPinPrompt, style: typo.bodySmall),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: typo.displayLarge.copyWith(
                        letterSpacing: 8,
                        fontSize: 28,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••',
                        hintStyle: typo.displayMedium.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      onSubmitted: (_) => _verifyPin(settings.pinCode!, l10n),
                    ),
                  ),
                  if (_pinError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _pinError!,
                      style: typo.monoLabel.copyWith(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _verifyPin(settings.pinCode!, l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.unlock,
                      style: typo.titleMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard_rounded),
              label: l10n.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_stories_outlined),
              activeIcon: const Icon(Icons.auto_stories_rounded),
              label: l10n.journal,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_outlined),
              activeIcon: const Icon(Icons.auto_awesome_rounded),
              label: l10n.summary,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
