import 'package:daymark/core/constants/app_categories.dart';
import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/journal/domain/entities/journal_entry.dart';
import 'package:daymark/features/journal/presentation/providers/journal_provider.dart';
import 'package:daymark/features/settings/presentation/providers/settings_provider.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_editor_screen.dart';

class JournalDetailScreen extends ConsumerStatefulWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  late JournalEntry _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
  }

  void _onEdit() async {
    final updated = await Navigator.push<JournalEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEditorScreen(initialEntry: _currentEntry),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _currentEntry = updated);
    }
  }

  void _confirmDelete() {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(l10n.deleteJournalTitle, style: typo.headlineMedium),
          content: Text(
            l10n.deleteConfirmation(_currentEntry.title),
            style: typo.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel, style: typo.labelMedium),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(journalListProvider.notifier).deleteJournal(_currentEntry.id);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final category = AppCategories.getById(_currentEntry.category);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.journalEntry, style: typo.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: l10n.edit,
            onPressed: _onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: l10n.delete,
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Mood Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: category.color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 14, color: category.color),
                        const SizedBox(width: 6),
                        Text(
                          l10n.categoryName(_currentEntry.category),
                          style: typo.monoLabel.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_currentEntry.mood != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentEntry.mood!,
                        style: typo.monoLabel.copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (_currentEntry.isPinned)
                    const Icon(Icons.push_pin_rounded, color: AppColors.primary, size: 18),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                _currentEntry.title,
                style: typo.displayLarge.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 12),

              // Date & Time
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    AppDateUtils.formatDisplay(_currentEntry.createdAt, 'EEEE, dd MMMM yyyy', settings.languageCode),
                    style: typo.monoLabel,
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time_rounded, size: 14, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    AppDateUtils.formatDisplay(_currentEntry.createdAt, 'HH:mm', settings.languageCode),
                    style: typo.monoLabel,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tags
              if (_currentEntry.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _currentEntry.tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        '#$t',
                        style: typo.monoLabel.copyWith(color: AppColors.primary),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              Divider(color: colors.borderSubtle),
              const SizedBox(height: 20),

              // Content
              SelectableText(
                _currentEntry.content.isEmpty ? '(No written reflection recorded.)' : _currentEntry.content,
                style: typo.bodyLarge.copyWith(height: 1.8),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
