import 'package:daymark/core/constants/app_categories.dart';
import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/journal/domain/entities/journal_entry.dart';
import 'package:daymark/features/journal/presentation/providers/journal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  final JournalEntry? initialEntry;

  const JournalEditorScreen({super.key, this.initialEntry});

  @override
  ConsumerState<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagInputController;

  late String _selectedCategory;
  String? _selectedMood;
  late List<String> _tags;
  late bool _isPinned;
  late bool _isFavorite;
  bool _isSaving = false;

  final List<String> _moodOptions = [
    '⚡ Productive',
    '✨ Inspired',
    '🎯 Focused',
    '🌱 Growing',
    '🌿 Calm',
    '🧗 Challenging',
    '🙏 Grateful',
  ];

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _contentController = TextEditingController(text: entry?.content ?? '');
    _tagInputController = TextEditingController();
    _selectedCategory = entry?.category ?? AppCategories.all.first.id;
    _selectedMood = entry?.mood;
    _tags = entry != null ? List<String>.from(entry.tags) : [];
    _isPinned = entry?.isPinned ?? false;
    _isFavorite = entry?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag(String rawTag) {
    final clean = rawTag.trim().replaceAll('#', '');
    if (clean.isNotEmpty && !_tags.contains(clean)) {
      setState(() {
        _tags.add(clean);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your journal.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final isNew = widget.initialEntry == null;
      final entry = JournalEntry(
        id: widget.initialEntry?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        tags: _tags,
        mood: _selectedMood,
        createdAt: widget.initialEntry?.createdAt ?? now,
        updatedAt: now,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
      );

      if (isNew) {
        await ref.read(journalListProvider.notifier).createJournal(entry);
      } else {
        await ref.read(journalListProvider.notifier).updateJournal(entry);
      }

      if (mounted) {
        Navigator.pop(context, entry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save journal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialEntry != null;
    final displayDate = widget.initialEntry?.createdAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Mark'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? AppColors.primary : AppColors.textMuted,
            ),
            tooltip: 'Pin Entry',
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveEntry,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_isSaving ? 'Saving' : 'Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp Info Bar
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    AppDateUtils.formatDateTimeDisplay(displayDate),
                    style: AppTypography.monoLabel,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              TextField(
                controller: _titleController,
                autofocus: !isEditing,
                style: AppTypography.displayMedium.copyWith(fontSize: 22),
                decoration: const InputDecoration(
                  hintText: 'What happened today?',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                maxLines: null,
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 16),

              // Category Selector
              Text('CATEGORY', style: AppTypography.monoLabel),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppCategories.all.map((c) {
                    final isSel = _selectedCategory == c.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        avatar: Icon(c.icon, size: 14, color: isSel ? Colors.black : c.color),
                        selected: isSel,
                        selectedColor: c.color,
                        backgroundColor: AppColors.surfaceElevated,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSel ? Colors.black : AppColors.textSecondary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSel ? c.color : AppColors.border,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = c.id);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Mood Selector
              Text('MINDSET / MOOD', style: AppTypography.monoLabel),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _moodOptions.map((mood) {
                    final isSel = _selectedMood == mood;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(mood),
                        selected: isSel,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundColor: AppColors.surfaceElevated,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSel ? AppColors.primary : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSel ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedMood = selected ? mood : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Tags
              Text('TAGS', style: AppTypography.monoLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: AppColors.surfaceHighlight,
                      labelStyle: AppTypography.monoLabel.copyWith(color: AppColors.textPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    );
                  }),
                  SizedBox(
                    width: 140,
                    height: 36,
                    child: TextField(
                      controller: _tagInputController,
                      style: AppTypography.bodySmall,
                      onSubmitted: _addTag,
                      decoration: InputDecoration(
                        hintText: '+ Add tag...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 16),

              // Content Body
              Text('REFLECTION & DETAILS', style: AppTypography.monoLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 12,
                style: AppTypography.bodyLarge.copyWith(height: 1.7),
                decoration: const InputDecoration(
                  hintText: 'Describe your journey, key learnings, milestones, challenges, or thoughts...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
