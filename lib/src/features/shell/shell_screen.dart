/// Shell Screen - Main container for the Diabecheck app
/// 
/// This screen serves as the main container that holds all the primary app screens
/// and manages the bottom navigation. It acts as a shell that wraps the core
/// functionality and provides navigation between different sections.
/// 
/// Features:
/// - Bottom navigation bar with 5 main sections
/// - Tab-based navigation between screens
/// - State management for current tab selection
/// - Seamless switching between app sections

import 'package:flutter/material.dart';
import '../../widgets/app_navbar.dart';
import '../home/home_screen.dart';
import '../meals/meals_screen.dart';
import '../exercise/exercise_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';

/// ShellScreen - Main container widget for the app
/// 
/// This StatefulWidget manages the main app navigation and contains all
/// the primary screens accessible through the bottom navigation bar.
class ShellScreen extends StatefulWidget {
  /// Route name for navigation
  static const String routeName = '/';
  
  /// Creates a new ShellScreen instance
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

/// State class for ShellScreen
/// 
/// Manages the current tab selection and handles navigation between screens
class _ShellScreenState extends State<ShellScreen> {
  /// Currently selected tab index (0-4)
  int _index = 0;

  /// List of all main app screens
  /// 
  /// Each screen corresponds to a tab in the bottom navigation bar
  /// Order: Home, Meals, Exercise, Community, Profile
  final List<Widget> _tabs = const [
    HomeScreen(),      // Index 0 - Main dashboard
    MealsScreen(),     // Index 1 - Meal planning and nutrition
    ExerciseScreen(),  // Index 2 - Workout tracking
    CommunityScreen(), // Index 3 - Social features
    ProfileScreen(),   // Index 4 - User settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the currently selected screen
      body: _tabs[_index],
      
      // Bottom navigation bar for tab switching
      bottomNavigationBar: AppNavbar(
        currentIndex: _index, // Pass current tab index
        onChanged: (i) => setState(() => _index = i), // Handle tab changes
      ),
    );
  }
}


