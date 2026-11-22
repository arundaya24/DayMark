import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// DAYMARK Typography System
/// Responsive to active Light/Dark ThemeData.
class AppTypography {
  final Color primaryColor;
  final Color secondaryColor;
  final Color mutedColor;

  const AppTypography({
    required this.primaryColor,
    required this.secondaryColor,
    required this.mutedColor,
  });

  factory AppTypography.of(BuildContext context) {
    final colors = AppColors.of(context);
    return AppTypography(
      primaryColor: colors.textPrimary,
      secondaryColor: colors.textSecondary,
      mutedColor: colors.textMuted,
    );
  }

  TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: primaryColor,
        height: 1.2,
      );

  TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: primaryColor,
        height: 1.25,
      );

  TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primaryColor,
        height: 1.3,
      );

  TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primaryColor,
        height: 1.35,
      );

  TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primaryColor,
      );

  TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      );

  TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.1,
        color: primaryColor,
      );

  TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.1,
        color: secondaryColor,
      );

  TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: mutedColor,
      );

  TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: secondaryColor,
      );

  TextStyle get monoLabel => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: mutedColor,
      );

  // Static getters that adapt automatically via DefaultTextStyle when no context is provided
  static TextStyle get staticDisplayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.2,
      );

  static TextStyle get staticHeadlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.3,
      );

  static TextStyle get staticTitleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      );

  static TextStyle get staticBodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.1,
      );
}

extension BuildContextTypographyExtension on BuildContext {
  AppTypography get typo => AppTypography.of(this);
}
