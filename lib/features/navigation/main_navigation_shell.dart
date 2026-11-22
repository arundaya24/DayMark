import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../dashboard/presentation/screens/dashboard_screen.dart';
import '../journal/presentation/screens/journal_editor_screen.dart';
import '../journal/presentation/screens/journal_list_screen.dart';
import '../settings/presentation/providers/settings_provider.dart';
import '../settings/presentation/screens/settings_screen.dart';
import '../summary/presentation/screens/summary_screen.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
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

  void _verifyPin(String correctPin) {
    if (_pinController.text.trim() == correctPin) {
      setState(() {
        _isUnlocked = true;
        _pinError = null;
      });
    } else {
      setState(() {
        _pinError = 'Incorrect PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // If PIN is enabled and not yet unlocked in this session, show lock screen
    if (settings.pinEnabled && settings.pinCode != null && !_isUnlocked) {
      return Scaffold(
        backgroundColor: AppColors.background,
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
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.lock_rounded, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('DAYMARK', style: AppTypography.displayMedium),
                  const SizedBox(height: 6),
                  Text('Enter your security PIN to access your journal', style: AppTypography.bodySmall),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: AppTypography.displayLarge.copyWith(letterSpacing: 8, fontSize: 28),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••',
                        hintStyle: AppTypography.displayMedium.copyWith(color: AppColors.textMuted),
                      ),
                      onSubmitted: (_) => _verifyPin(settings.pinCode!),
                    ),
                  ),
                  if (_pinError != null) ...[
                    const SizedBox(height: 12),
                    Text(_pinError!, style: AppTypography.monoLabel.copyWith(color: AppColors.error)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _verifyPin(settings.pinCode!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Unlock', style: AppTypography.titleMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(Icons.auto_stories_rounded),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
