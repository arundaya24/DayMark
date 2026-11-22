import 'dart:convert';
import '../../domain/entities/journal_entry.dart';

class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.id,
    required super.title,
    required super.content,
    required super.category,
    required super.tags,
    super.mood,
    required super.createdAt,
    required super.updatedAt,
    super.isPinned = false,
    super.isFavorite = false,
  });

  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      category: entry.category,
      tags: entry.tags,
      mood: entry.mood,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      isPinned: entry.isPinned,
      isFavorite: entry.isFavorite,
    );
  }

  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['tags'] as String);
        if (decoded is List) {
          parsedTags = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedTags = (map['tags'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }

    return JournalEntryModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      tags: parsedTags,
      mood: map['mood'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tags': jsonEncode(tags),
      'mood': mood,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_pinned': isPinned ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) => JournalEntryModel.fromMap(json);
}
