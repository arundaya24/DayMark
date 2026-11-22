import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/journal_entry.dart';
import '../providers/journal_provider.dart';
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text('Delete Journal?', style: AppTypography.headlineMedium),
          content: Text(
            'Are you sure you want to delete "${_currentEntry.title}"? This action cannot be undone and will update your activity count.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTypography.labelMedium),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.getById(_currentEntry.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Journal Entry', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Edit',
            onPressed: _onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete',
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
                      color: category.color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: category.color.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 14, color: category.color),
                        const SizedBox(width: 6),
                        Text(
                          category.name,
                          style: AppTypography.monoLabel.copyWith(
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
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentEntry.mood!,
                        style: AppTypography.monoLabel.copyWith(color: AppColors.textPrimary),
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
                style: AppTypography.displayLarge.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 12),

              // Date & Time
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    AppDateUtils.formatDisplay(_currentEntry.createdAt, 'EEEE, dd MMMM yyyy'),
                    style: AppTypography.monoLabel,
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    AppDateUtils.formatDisplay(_currentEntry.createdAt, 'HH:mm'),
                    style: AppTypography.monoLabel,
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
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '#$t',
                        style: AppTypography.monoLabel.copyWith(color: AppColors.primaryLight),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 20),

              // Content
              SelectableText(
                _currentEntry.content.isEmpty ? '(No written reflection recorded.)' : _currentEntry.content,
                style: AppTypography.bodyLarge.copyWith(height: 1.8),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
