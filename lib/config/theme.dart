import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════
  // GLINTS-INSPIRED COLOR PALETTE - Bold & Professional
  // ═══════════════════════════════════════════════════════════════
  
  // Primary - Deep Indigo/Purple (Glints signature)
  static const Color primaryColor = Color(0xFF4F46E5);      // Vibrant Indigo
  static const Color primaryDark = Color(0xFF3730A3);       // Darker Indigo
  static const Color primaryLight = Color(0xFF818CF8);      // Light Indigo
  
  // Secondary - Teal/Cyan accent
  static const Color secondaryColor = Color(0xFF06B6D4);    // Cyan
  static const Color secondaryDark = Color(0xFF0891B2);     // Dark Cyan
  
  // Accent - Warm Orange for CTAs
  static const Color accentColor = Color(0xFFFF6B35);       // Vibrant Orange
  static const Color accentLight = Color(0xFFFFB088);       // Light Orange
  
  // Status Colors
  static const Color successColor = Color(0xFF10B981);      // Emerald Green
  static const Color warningColor = Color(0xFFF59E0B);      // Amber
  static const Color errorColor = Color(0xFFEF4444);        // Red
  static const Color infoColor = Color(0xFF3B82F6);         // Blue
  
  // Application Status Colors
  static const Color pendingColor = Color(0xFFF59E0B);      // Amber
  static const Color reviewColor = Color(0xFF6366F1);       // Indigo
  static const Color acceptedColor = Color(0xFF10B981);     // Emerald
  static const Color rejectedColor = Color(0xFFEF4444);     // Red
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF8FAFC);   // Slate 50
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color onSurfaceColor = Color(0xFF0F172A);    // Slate 900
  static const Color subtitleColor = Color(0xFF64748B);     // Slate 500
  static const Color dividerColor = Color(0xFFE2E8F0);      // Slate 200
  static const Color shimmerColor = Color(0xFFCBD5E1);      // Slate 300

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF7C3AED)], // Indigo to Violet
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFFFF8A50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)], // Indigo 950 to 900
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
          letterSpacing: -0.5,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: primaryColor, width: 1.5),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: subtitleColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: shimmerColor,
          fontSize: 15,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: onSurfaceColor,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
          letterSpacing: -1,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: subtitleColor,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurfaceColor,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceColor,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: subtitleColor,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: subtitleColor,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: subtitleColor,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: subtitleColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceColor,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor,
        circularTrackColor: dividerColor,
      ),
    );
  }
}
