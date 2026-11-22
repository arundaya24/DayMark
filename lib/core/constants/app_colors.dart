import 'package:flutter/material.dart';

/// DAYMARK Color Palette
/// Designed for a premium, sleek, dark-first journaling experience.
class AppColors {
  // Primary Dark Backgrounds (OLED & Dark Graphite)
  static const Color background = Color(0xFF0C0E12);
  static const Color surface = Color(0xFF14181F);
  static const Color surfaceElevated = Color(0xFF1B212B);
  static const Color surfaceHighlight = Color(0xFF242C38);
  static const Color border = Color(0xFF262E3B);
  static const Color borderSubtle = Color(0xFF1C222C);

  // Light Mode Colors (for theme switching)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Accents (Signature Emerald & Mint - Git Contribution inspired)
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryLight = Color(0xFF34D399); // Emerald 400
  static const Color primaryDark = Color(0xFF059669); // Emerald 600
  static const Color accentGold = Color(0xFFF59E0B); // Amber / Streak gold
  static const Color accentIndigo = Color(0xFF6366F1); // Indigo
  static const Color accentRose = Color(0xFFF43F5E); // Rose
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan

  // Contribution Heatmap Green Levels (Dark theme)
  static const Color heatLevel0 = Color(0xFF1E242E); // No activity
  static const Color heatLevel1 = Color(0xFF064E3B); // 1 activity (Deep)
  static const Color heatLevel2 = Color(0xFF047857); // 2-3 activities (Medium-dark)
  static const Color heatLevel3 = Color(0xFF10B981); // 4-5 activities (Vibrant emerald)
  static const Color heatLevel4 = Color(0xFF34D399); // 6+ activities (Bright glowing mint)

  // Typography Colors (Dark theme default)
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
