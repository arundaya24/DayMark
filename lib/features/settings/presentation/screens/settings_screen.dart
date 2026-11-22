import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/services/backup/backup_service.dart';
import 'package:daymark/features/journal/presentation/providers/journal_provider.dart';
import 'package:daymark/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_config_dialog.dart';
import 'pin_lock_dialog.dart';
import 'profile_edit_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final repository = ref.watch(journalRepositoryProvider);
    final backupService = BackupService(repository);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: typo.headlineLarge),
            Text('Preferences & System Config', style: typo.bodySmall),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                    child: Text(
                      settings.userName.isNotEmpty ? settings.userName.substring(0, 1).toUpperCase() : 'D',
                      style: typo.displayMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settings.userName, style: typo.titleLarge),
                        const SizedBox(height: 2),
                        Text(settings.userBio, style: typo.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () async {
                      final res = await showDialog<Map<String, String>>(
                        context: context,
                        builder: (_) => ProfileEditDialog(
                          currentName: settings.userName,
                          currentBio: settings.userBio,
                        ),
                      );
                      if (res != null) {
                        await settingsNotifier.updateProfile(
                          name: res['name']!,
                          bio: res['bio']!,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Appearance & Theme Section
            _buildSectionHeader('APPEARANCE', typo),
            _buildSettingsTile(
              context: context,
              icon: Icons.dark_mode_outlined,
              title: 'Theme Preference',
              subtitle: 'Current: ${settings.themeMode.toUpperCase()} mode',
              onTap: () => _showThemePicker(context, ref, settings.themeMode),
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.calendar_today_outlined,
              title: 'Date Format',
              subtitle: settings.dateFormat,
              onTap: () => _showDateFormatPicker(context, ref, settings.dateFormat),
            ),

            const SizedBox(height: 20),

            // Privacy & Security Section
            _buildSectionHeader('PRIVACY & SECURITY', typo),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Icon(Icons.visibility_off_outlined, color: colors.textSecondary),
                title: Text('Hide Journal Previews', style: typo.titleMedium),
                subtitle: Text('Mask journal content previews in timeline', style: typo.bodySmall),
                value: settings.hidePreview,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => settingsNotifier.setHidePreview(val),
              ),
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.lock_outline_rounded,
              title: 'App PIN Security Lock',
              subtitle: settings.pinEnabled ? 'PIN Lock Enabled' : 'Disabled (Open Access)',
              trailing: Switch(
                value: settings.pinEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (val) async {
                  if (val) {
                    final pin = await showDialog<String>(
                      context: context,
                      builder: (_) => const PinLockDialog(isEnabling: true),
                    );
                    if (pin != null) {
                      await settingsNotifier.setPinLock(enabled: true, pin: pin);
                    }
                  } else {
                    final verifiedPin = await showDialog<String>(
                      context: context,
                      builder: (_) => const PinLockDialog(isEnabling: false),
                    );
                    if (verifiedPin == settings.pinCode) {
                      await settingsNotifier.setPinLock(enabled: false, pin: null);
                    } else if (verifiedPin != null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incorrect PIN'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // AI Service Configuration
            _buildSectionHeader('AI & SUMMARY PROVIDER', typo),
            _buildSettingsTile(
              context: context,
              icon: Icons.auto_awesome_rounded,
              title: 'Summary Engine',
              subtitle: settings.aiProvider == 'gemini'
                  ? 'Cloud: Google Gemini (${settings.geminiModel})'
                  : 'Offline: Local Smart Heuristic Engine',
              onTap: () async {
                final res = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (_) => AiConfigDialog(
                    currentProvider: settings.aiProvider,
                    currentApiKey: settings.geminiApiKey,
                    currentModel: settings.geminiModel,
                  ),
                );
                if (res != null) {
                  await settingsNotifier.setAiConfig(
                    provider: res['provider']!,
                    apiKey: res['apiKey']!,
                    model: res['model']!,
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            // Data & Storage (Backup & Restore)
            _buildSectionHeader('DATA & STORAGE', typo),
            _buildSettingsTile(
              context: context,
              icon: Icons.file_upload_outlined,
              title: 'Backup Data (Export JSON)',
              subtitle: 'Export journals and activity history to file',
              onTap: () async {
                try {
                  final path = await backupService.exportBackup();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Backup created: $path'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup failed: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.file_download_outlined,
              title: 'Restore Data (Import JSON)',
              subtitle: 'Restore entries from previous DAYMARK backup',
              onTap: () async {
                try {
                  final count = await backupService.importBackup();
                  ref.invalidate(journalListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully restored $count journals!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restore failed: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 30),

            // About DAYMARK
            Center(
              child: Column(
                children: [
                  Text('DAYMARK', style: typo.monoLabel.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('"Every day leaves a mark."', style: typo.bodySmall),
                  const SizedBox(height: 2),
                  Text('Version 1.0.0', style: typo.monoLabel.copyWith(fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppTypography typo) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: typo.monoLabel),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final colors = context.colors;
    final typo = context.typo;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: colors.textSecondary, size: 22),
        title: Text(title, style: typo.titleMedium),
        subtitle: Text(subtitle, style: typo.bodySmall),
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: colors.textMuted) : null),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, String current) {
    final colors = context.colors;
    final typo = context.typo;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Theme Mode', style: typo.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Dark Mode (Primary default)', style: typo.bodyLarge),
                leading: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
                trailing: current == 'dark' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode('dark');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Light Mode', style: typo.bodyLarge),
                leading: Icon(Icons.light_mode_rounded, color: colors.textSecondary),
                trailing: current == 'light' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode('light');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('System Default', style: typo.bodyLarge),
                leading: Icon(Icons.brightness_auto_rounded, color: colors.textSecondary),
                trailing: current == 'system' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode('system');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDateFormatPicker(BuildContext context, WidgetRef ref, String current) {
    final colors = context.colors;
    final typo = context.typo;

    final formats = [
      'dd MMM yyyy', // 22 Nov 2026
      'yyyy-MM-dd', // 2026-11-22
      'EEEE, dd MMMM yyyy', // Sunday, 22 November 2026
      'MM/dd/yyyy', // 11/22/2026
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Date Format', style: typo.titleLarge),
              const SizedBox(height: 16),
              ...formats.map((fmt) {
                return ListTile(
                  title: Text(fmt, style: typo.bodyLarge),
                  trailing: current == fmt ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(settingsProvider.notifier).setDateFormat(fmt);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
