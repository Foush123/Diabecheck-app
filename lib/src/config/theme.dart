/// Theme Configuration for Diabecheck App
/// 
/// This file contains the app's color scheme, typography, and theme configuration.
/// It defines a consistent design system used throughout the application.
/// 
/// Design Philosophy:
/// - Clean, modern interface with medical app aesthetics
/// - High contrast for accessibility
/// - Calming blue color scheme for health-focused app
/// - Poppins font for readability and modern feel

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppColors - Centralized color palette for the Diabecheck application
/// 
/// All colors used throughout the app should reference these constants
/// to maintain consistency and enable easy theme updates
class AppColors {
  /// Primary brand color - Trustworthy blue for medical app
  static const Color primary = Color(0xFF2E86DE);
  
  /// Secondary accent color - Lighter blue for highlights and accents
  static const Color secondary = Color(0xFF63C1FF);
  
  /// Background color - Very light blue for clean, medical feel
  static const Color background = Color(0xFFF7FBFF);
  
  /// Card background - Pure white for content cards
  static const Color card = Colors.white;
  
  /// Primary text color - Dark blue-gray for high contrast readability
  static const Color textPrimary = Color(0xFF1E2A3A);
  
  /// Secondary text color - Medium gray for less important text
  static const Color textSecondary = Color(0xFF6B7C93);
}

/// Builds the light theme configuration for the Diabecheck app
/// 
/// This function creates a Material 3 theme with custom colors, typography,
/// and component styling that matches the app's design system.
/// 
/// Key theme features:
/// - Material 3 design system for modern UI components
/// - Poppins font family for better readability
/// - Custom color scheme based on AppColors
/// - Rounded corners and modern card styling
/// - Transparent app bars for modern look
ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    // Color scheme configuration using app's primary colors
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
    ),
    // Scaffold background color for consistent app background
    scaffoldBackgroundColor: AppColors.background,
    // Typography configuration with Poppins font
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    // App bar styling for modern, clean look
    appBarTheme: const AppBarTheme(
      elevation: 0, // No shadow for flat design
      backgroundColor: Colors.transparent, // Transparent background
      foregroundColor: AppColors.textPrimary, // Text color
    ),
    // Card styling with rounded corners and no elevation
    cardTheme: CardThemeData(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      elevation: 0, // Flat design with no shadows
    ),
    // Floating action button styling
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
  );
}


