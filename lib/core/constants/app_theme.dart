import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.dark.surface,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSurface: AppColors.dark.textPrimary,
      ),
      extensions: const [
        AppThemeColors.dark,
      ],
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.dark.textPrimary,
        displayColor: AppColors.dark.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.dark.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.dark.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.dark.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.dark.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dark.surfaceElevated,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.dark.border, width: 1),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.dark.textPrimary,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.dark.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.dark.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.dark.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.dark.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.dark.textMuted,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dark.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.dark.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dark.border),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        secondary: AppColors.primary,
        surface: AppColors.light.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.light.textPrimary,
      ),
      extensions: const [
        AppThemeColors.light,
      ],
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.light.textPrimary,
        displayColor: AppColors.light.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.light.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.light.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.light.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.light.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.light.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.light.border, width: 1),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.light.textPrimary,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.light.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.light.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.light.surface,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.light.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.light.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.light.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.light.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.light.textMuted,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.light.border,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.light.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.light.border),
        ),
      ),
    );
  }
}
