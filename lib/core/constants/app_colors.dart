import 'package:flutter/material.dart';

/// DAYMARK Color System & Theme Colors
/// Supports seamless dynamic switching between Dark Mode and Light Mode.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHighlight;
  final Color border;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;

  // Heatmap gradation levels
  final Color heatLevel0;
  final Color heatLevel1;
  final Color heatLevel2;
  final Color heatLevel3;
  final Color heatLevel4;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHighlight,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.heatLevel0,
    required this.heatLevel1,
    required this.heatLevel2,
    required this.heatLevel3,
    required this.heatLevel4,
  });

  // Dark Mode Palette (OLED Black, Graphite, Vibrant Emerald Accents)
  static const dark = AppThemeColors(
    background: Color(0xFF0C0E12),
    surface: Color(0xFF14181F),
    surfaceElevated: Color(0xFF1B212B),
    surfaceHighlight: Color(0xFF242C38),
    border: Color(0xFF262E3B),
    borderSubtle: Color(0xFF1C222C),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    textDisabled: Color(0xFF475569),
    heatLevel0: Color(0xFF1B2028),
    heatLevel1: Color(0xFF064E3B),
    heatLevel2: Color(0xFF047857),
    heatLevel3: Color(0xFF10B981),
    heatLevel4: Color(0xFF34D399),
  );

  // Light Mode Palette (Crisp Pure White, Slate, Rich Emerald Contrast)
  static const light = AppThemeColors(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF1F5F9),
    surfaceHighlight: Color(0xFFE2E8F0),
    border: Color(0xFFE2E8F0),
    borderSubtle: Color(0xFFEDF2F7),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    textDisabled: Color(0xFFCBD5E1),
    heatLevel0: Color(0xFFE2E8F0),
    heatLevel1: Color(0xFFA7F3D0),
    heatLevel2: Color(0xFF34D399),
    heatLevel3: Color(0xFF10B981),
    heatLevel4: Color(0xFF047857),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceHighlight,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? heatLevel0,
    Color? heatLevel1,
    Color? heatLevel2,
    Color? heatLevel3,
    Color? heatLevel4,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      heatLevel0: heatLevel0 ?? this.heatLevel0,
      heatLevel1: heatLevel1 ?? this.heatLevel1,
      heatLevel2: heatLevel2 ?? this.heatLevel2,
      heatLevel3: heatLevel3 ?? this.heatLevel3,
      heatLevel4: heatLevel4 ?? this.heatLevel4,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceHighlight: Color.lerp(surfaceHighlight, other.surfaceHighlight, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      heatLevel0: Color.lerp(heatLevel0, other.heatLevel0, t)!,
      heatLevel1: Color.lerp(heatLevel1, other.heatLevel1, t)!,
      heatLevel2: Color.lerp(heatLevel2, other.heatLevel2, t)!,
      heatLevel3: Color.lerp(heatLevel3, other.heatLevel3, t)!,
      heatLevel4: Color.lerp(heatLevel4, other.heatLevel4, t)!,
    );
  }
}

class AppColors {
  static const dark = AppThemeColors.dark;
  static const light = AppThemeColors.light;

  // Brand Emerald & Accents
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Static dark constants for backward-compatible fallback
  static const Color background = Color(0xFF0C0E12);
  static const Color surface = Color(0xFF14181F);
  static const Color surfaceElevated = Color(0xFF1B212B);
  static const Color surfaceHighlight = Color(0xFF242C38);
  static const Color border = Color(0xFF262E3B);
  static const Color borderSubtle = Color(0xFF1C222C);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  static const Color heatLevel0 = Color(0xFF1B2028);
  static const Color heatLevel1 = Color(0xFF064E3B);
  static const Color heatLevel2 = Color(0xFF047857);
  static const Color heatLevel3 = Color(0xFF10B981);
  static const Color heatLevel4 = Color(0xFF34D399);

  /// Theme-aware helper to get current theme colors from BuildContext
  static AppThemeColors of(BuildContext context) {
    return Theme.of(context).extension<AppThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppThemeColors.dark
            : AppThemeColors.light);
  }
}

extension BuildContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => theme.brightness == Brightness.dark;
  AppThemeColors get colors => AppColors.of(this);
}
