
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Sahityakaar color palette
class SahityakaarColors {
  static const background = Color(0xFFFDF6E3); // warm parchment
  static const primary = Color(0xFF5D4037);    // dark brown
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFFFFF3E0);  // pale cream
  static const onSecondary = Color(0xFF5D4037);
}

final appTheme = ThemeData(
  useMaterial3: true,

  // Override scaffold background
  scaffoldBackgroundColor: SahityakaarColors.background,

  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: SahityakaarColors.primary,
    onPrimary: SahityakaarColors.onPrimary,
    secondary: SahityakaarColors.secondary,
    onSecondary: SahityakaarColors.onSecondary,
    surface: SahityakaarColors.secondary,
    onSurface: SahityakaarColors.primary,
    error: Colors.red,
    onError: Colors.white,
    primaryContainer: SahityakaarColors.primary,
    onPrimaryContainer: SahityakaarColors.onPrimary,
    secondaryContainer: SahityakaarColors.secondary,
    onSecondaryContainer: SahityakaarColors.onSecondary,
  ),

  textTheme: GoogleFonts.interTextTheme().copyWith(
    titleLarge: GoogleFonts.playfairDisplay( // for app name
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: SahityakaarColors.primary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 16,
      color: SahityakaarColors.primary,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: SahityakaarColors.onPrimary,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: SahityakaarColors.primary,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: SahityakaarColors.primary,
      foregroundColor: SahityakaarColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: SahityakaarColors.secondary,
      foregroundColor: SahityakaarColors.primary,
      side: BorderSide(color: SahityakaarColors.primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
);
