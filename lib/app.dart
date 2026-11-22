import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'features/navigation/main_navigation_shell.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

class DayMarkApp extends ConsumerWidget {
  const DayMarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeMode themeMode;
    switch (settings.themeMode.toLowerCase()) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'system':
        themeMode = ThemeMode.system;
        break;
      case 'dark':
      default:
        themeMode = ThemeMode.dark;
        break;
    }

    return MaterialApp(
      title: 'DAYMARK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigationShell(),
    );
  }
}
