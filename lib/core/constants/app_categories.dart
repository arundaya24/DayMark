import 'package:flutter/material.dart';

class JournalCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const JournalCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AppCategories {
  static const List<JournalCategory> all = [
    JournalCategory(
      id: 'daily',
      name: 'Daily Reflection',
      icon: Icons.book_outlined,
      color: Color(0xFF10B981), // Emerald
    ),
    JournalCategory(
      id: 'learning',
      name: 'Learning',
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFF6366F1), // Indigo
    ),
    JournalCategory(
      id: 'work',
      name: 'Work & Projects',
      icon: Icons.business_center_outlined,
      color: Color(0xFF0EA5E9), // Sky blue
    ),
    JournalCategory(
      id: 'milestone',
      name: 'Milestone',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFF59E0B), // Amber
    ),
    JournalCategory(
      id: 'health',
      name: 'Health & Wellness',
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFF43F5E), // Rose
    ),
    JournalCategory(
      id: 'ideas',
      name: 'Ideas & Thoughts',
      icon: Icons.auto_awesome_outlined,
      color: Color(0xFF8B5CF6), // Purple
    ),
  ];

  static JournalCategory getById(String id) {
    return all.firstWhere(
      (cat) => cat.id.toLowerCase() == id.toLowerCase(),
      orElse: () => all.first,
    );
  }
}
