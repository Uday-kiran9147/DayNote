import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Palette
  static const Color paperBackground = Color(0xFFFBF9F4);
  static const Color paperSurface = Color(0xFFF5F1E8);
  static const Color paperHighlight = Color(0xFFFFFDF9);
  
  static const Color inkPrimary = Color(0xFF22201E);
  static const Color inkSecondary = Color(0xFF5F5953);
  static const Color inkTertiary = Color(0xFF948D85);
  static const Color inkDisabled = Color(0xFFC7C0B7);

  static const Color accentBrown = Color(0xFF7A5C43);
  static const Color accentBrownLight = Color(0xFFD4C3B3);
  static const Color separatorBeige = Color(0xFFE8E1D5);
  static const Color subtleHover = Color(0xFFEFE9DC);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFB84533);
  static const Color priorityHighBg = Color(0xFFF9EAE7);
  static const Color priorityMed = Color(0xFF9E6523);
  static const Color priorityMedBg = Color(0xFFFAF1E4);
  static const Color priorityLow = Color(0xFF527560);
  static const Color priorityLowBg = Color(0xFFECF3EE);

  // Clean, Simple Typography
  static TextStyle get serifHeading => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: inkPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get serifMonth => GoogleFonts.inter(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: inkPrimary,
    letterSpacing: -0.1,
  );

  static TextStyle get serifSelectedDate => GoogleFonts.inter(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: inkPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get serifSelectedYear => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: inkSecondary,
  );

  static TextStyle get serifSectionTitle => GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: inkSecondary,
    letterSpacing: 1.2,
  );

  static TextStyle get sansBody => GoogleFonts.inter(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: inkPrimary,
    height: 1.5,
  );

  static TextStyle get sansBodyDone => GoogleFonts.inter(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: inkTertiary,
    decoration: TextDecoration.lineThrough,
    decorationColor: inkTertiary,
    height: 1.5,
  );

  static TextStyle get sansNoteText => GoogleFonts.inter(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: inkPrimary,
    height: 1.6,
  );

  static TextStyle get sansCaption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: inkTertiary,
  );

  static TextStyle get sansButton => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: inkPrimary,
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paperBackground,
      colorScheme: const ColorScheme.light(
        primary: inkPrimary,
        onPrimary: paperBackground,
        surface: paperBackground,
        onSurface: inkPrimary,
        outline: separatorBeige,
        secondary: accentBrown,
      ),
      dividerTheme: const DividerThemeData(
        color: separatorBeige,
        thickness: 1,
        space: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paperBackground,
        foregroundColor: inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }
}
