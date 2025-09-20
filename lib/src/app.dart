/// DiabecheckApp - Main application widget
/// 
/// This is the root widget of the Diabecheck application that configures
/// the MaterialApp with theme, routing, and initial screen settings.
/// 
/// Key configurations:
/// - App title and branding
/// - Theme configuration (light theme)
/// - Route management and navigation
/// - Initial screen (onboarding for new users)

import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'routing/routes.dart';
import 'features/onboarding/onboarding_screen.dart';

/// Main application widget that serves as the root of the Diabecheck app
/// Configures MaterialApp with theme, routing, and initial screen
class DiabecheckApp extends StatelessWidget {
  const DiabecheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabecheck', // App name displayed in system UI
      debugShowCheckedModeBanner: false, // Hide debug banner in release
      theme: buildLightTheme(), // Apply custom light theme
      initialRoute: OnboardingScreen.routeName, // Start with onboarding
      onGenerateRoute: AppRouter.onGenerateRoute, // Custom route handling
    );
  }
}


