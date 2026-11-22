import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/backup/backup_service.dart';
import '../../journal/presentation/providers/journal_provider.dart';
import '../providers/settings_provider.dart';
import 'ai_config_dialog.dart';
import 'pin_lock_dialog.dart';
import 'profile_edit_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final repository = ref.watch(journalRepositoryProvider);
    final backupService = BackupService(repository);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTypography.headlineLarge),
            Text('Preferences & System Config', style: AppTypography.bodySmall),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.18),
                    child: Text(
                      settings.userName.isNotEmpty ? settings.userName.substring(0, 1).toUpperCase() : 'D',
                      style: AppTypography.displayMedium.copyWith(
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
                        Text(settings.userName, style: AppTypography.titleLarge),
                        const SizedBox(height: 2),
                        Text(settings.userBio, style: AppTypography.bodySmall),
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
            _buildSectionHeader('APPEARANCE'),
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Theme Preference',
              subtitle: 'Current: ${settings.themeMode.toUpperCase()} mode',
              onTap: () => _showThemePicker(context, ref, settings.themeMode),
            ),
            _buildSettingsTile(
              icon: Icons.calendar_today_outlined,
              title: 'Date Format',
              subtitle: settings.dateFormat,
              onTap: () => _showDateFormatPicker(context, ref, settings.dateFormat),
            ),

            const SizedBox(height: 20),

            // Privacy & Security Section
            _buildSectionHeader('PRIVACY & SECURITY'),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              secondary: const Icon(Icons.visibility_off_outlined, color: AppColors.textSecondary),
              title: Text('Hide Journal Previews', style: AppTypography.titleMedium),
              subtitle: Text('Mask journal content previews in timeline', style: AppTypography.bodySmall),
              value: settings.hidePreview,
              activeColor: AppColors.primary,
              onChanged: (val) => settingsNotifier.setHidePreview(val),
            ),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'App PIN Security Lock',
              subtitle: settings.pinEnabled ? 'PIN Lock Enabled' : 'Disabled (Open Access)',
              trailing: Switch(
                value: settings.pinEnabled,
                activeColor: AppColors.primary,
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
            _buildSectionHeader('AI & SUMMARY PROVIDER'),
            _buildSettingsTile(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Summary Engine',
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
            _buildSectionHeader('DATA & STORAGE'),
            _buildSettingsTile(
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
            const SizedBox(height: 8),
            _buildSettingsTile(
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
                  Text('DAYMARK', style: AppTypography.monoLabel.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('"Every day leaves a mark."', style: AppTypography.bodySmall),
                  const SizedBox(height: 2),
                  Text('Version 1.0.0 • Mobile Production Build', style: AppTypography.monoLabel.copyWith(fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTypography.monoLabel),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(title, style: AppTypography.titleMedium),
        subtitle: Text(subtitle, style: AppTypography.bodySmall),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textMuted) : null),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Theme Mode', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Dark Mode (Primary default)'),
                leading: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
                trailing: current == 'dark' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode('dark');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Light Mode'),
                leading: const Icon(Icons.light_mode_rounded),
                trailing: current == 'light' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode('light');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('System Default'),
                leading: const Icon(Icons.brightness_auto_rounded),
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
    final formats = [
      'dd MMM yyyy', // 22 Nov 2026
      'yyyy-MM-dd', // 2026-11-22
      'EEEE, dd MMMM yyyy', // Sunday, 22 November 2026
      'MM/dd/yyyy', // 11/22/2026
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Date Format', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              ...formats.map((fmt) {
                return ListTile(
                  title: Text(fmt),
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
