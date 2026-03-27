import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (from HTML design)
  static const Color primary = Color(0xFF154212);
  static const Color primaryContainer = Color(0xFF2d5a27);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF9dd090);
  static const Color primaryFixed = Color(0xFFbcf0ae);
  static const Color primaryFixedDim = Color(0xFFa1d494);
  static const Color inversePrimary = Color(0xFFa1d494);

  static const Color secondary = Color(0xFF77574d);
  static const Color secondaryContainer = Color(0xFFfed3c7);
  static const Color onSecondaryContainer = Color(0xFF795950);

  static const Color tertiary = Color(0xFF003c60);
  static const Color tertiaryContainer = Color(0xFF005484);
  static const Color onTertiaryContainer = Color(0xFF8dc8ff);
  static const Color tertiaryFixedDim = Color(0xFF96ccff);

  static const Color background = Color(0xFFf5fcef);
  static const Color surface = Color(0xFFf5fcef);
  static const Color surfaceBright = Color(0xFFf5fcef);
  static const Color surfaceDim = Color(0xFFd5dcd0);
  static const Color surfaceContainerLowest = Colors.white;
  static const Color surfaceContainerLow = Color(0xFFeff6e9);
  static const Color surfaceContainer = Color(0xFFe9f0e4);
  static const Color surfaceContainerHigh = Color(0xFFe3eade);
  static const Color surfaceContainerHighest = Color(0xFFdee5d8);

  static const Color onBackground = Color(0xFF171d16);
  static const Color onSurface = Color(0xFF171d16);
  static const Color onSurfaceVariant = Color(0xFF42493e);
  static const Color outline = Color(0xFF72796e);
  static const Color outlineVariant = Color(0xFFc2c9bb);
  static const Color inverseSurface = Color(0xFF2b322a);
  static const Color inverseOnSurface = Color(0xFFecf3e6);

  static const Color error = Color(0xFFba1a1a);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onError = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: Colors.white,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: Color(0xFF93000a),
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 57, fontWeight: FontWeight.w800, color: onBackground,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 45, fontWeight: FontWeight.w800, color: onBackground,
        ),
        displaySmall: GoogleFonts.manrope(
          fontSize: 36, fontWeight: FontWeight.w700, color: onBackground,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32, fontWeight: FontWeight.w700, color: onBackground,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 28, fontWeight: FontWeight.w700, color: onBackground,
        ),
        headlineSmall: GoogleFonts.manrope(
          fontSize: 24, fontWeight: FontWeight.w700, color: onBackground,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w600, color: onBackground,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: onBackground,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: onBackground,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: onBackground,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: onBackground,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: onBackground,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: onBackground,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700, color: onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w800, color: primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF78716c),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
