import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: Color(0xFFCF6679),
        outline: AppColors.border,
      ),
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: GoogleFonts.cinzel(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.crimsonText(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.crimsonText(color: AppColors.textSecondary, fontSize: 16),
        hintStyle: GoogleFonts.crimsonText(color: AppColors.textDisabled, fontSize: 16),
        prefixIconColor: AppColors.primary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withAlpha(60),
        side: const BorderSide(color: AppColors.border),
        labelStyle: GoogleFonts.crimsonText(color: AppColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        titleTextStyle: GoogleFonts.cinzel(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.crimsonText(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: GoogleFonts.crimsonText(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static TextTheme _textTheme() {
    return TextTheme(
      // Display — Cinzel (fantasy headings)
      displayLarge: GoogleFonts.cinzel(fontSize: 57, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1.5),
      displayMedium: GoogleFonts.cinzel(fontSize: 45, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 1.2),
      displaySmall: GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 1.0),
      // Headline — Cinzel
      headlineLarge: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.8),
      headlineMedium: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.6),
      headlineSmall: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: 0.4),
      // Title — Cinzel
      titleLarge: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.4),
      titleMedium: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.3),
      titleSmall: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.2),
      // Body — Crimson Text (serif body)
      bodyLarge: GoogleFonts.crimsonText(fontSize: 18, color: AppColors.textPrimary, height: 1.5),
      bodyMedium: GoogleFonts.crimsonText(fontSize: 16, color: AppColors.textPrimary, height: 1.4),
      bodySmall: GoogleFonts.crimsonText(fontSize: 14, color: AppColors.textSecondary, height: 1.3),
      // Label
      labelLarge: GoogleFonts.crimsonText(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      labelMedium: GoogleFonts.crimsonText(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      labelSmall: GoogleFonts.crimsonText(fontSize: 11, color: AppColors.textDisabled),
    );
  }
}
