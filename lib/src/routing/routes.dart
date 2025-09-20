/// App Router - Centralized routing configuration
/// 
/// This file manages all navigation routes within the Diabecheck application.
/// It provides a centralized way to handle navigation between different screens
/// and ensures consistent route management throughout the app.
/// 
/// Navigation Flow:
/// 1. Onboarding (first-time users)
/// 2. Welcome/Auth screens (login/signup)
/// 3. Main Shell (home, meals, exercise, community, profile)

import 'package:flutter/material.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/shell/shell_screen.dart';

/// AppRouter - Handles all route generation and navigation logic
/// 
/// This class provides a centralized routing system that maps route names
/// to their corresponding screen widgets. It ensures type-safe navigation
/// and consistent page transitions throughout the application.
class AppRouter {
  /// Generates routes based on the provided route settings
  /// 
  /// This method is called by Flutter's navigation system whenever
  /// a new route needs to be generated. It maps route names to their
  /// corresponding screen widgets.
  /// 
  /// [settings] - Contains the route name and arguments
  /// Returns a MaterialPageRoute for the requested screen
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Onboarding screen - First screen for new users
      case OnboardingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      // Welcome screen - Entry point for authentication flow
      case WelcomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      
      // Login screen - User authentication
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      // Signup screen - New user registration
      case SignupScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      // Main shell - Contains bottom navigation and main app screens
      case ShellScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ShellScreen());
      
      // Default fallback - Redirect to onboarding for unknown routes
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    }
  }
}


