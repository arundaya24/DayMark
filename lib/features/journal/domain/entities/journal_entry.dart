class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final String? mood;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isFavorite;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFavorite = false,
  });

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    String? mood,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isFavorite,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
