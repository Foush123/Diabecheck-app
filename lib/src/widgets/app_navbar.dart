/// App Navigation Bar Widget
/// 
/// This widget provides the main bottom navigation bar for the Diabecheck app.
/// It uses the CrystalNavigationBar package to create a modern, floating-style
/// navigation bar with smooth animations and visual feedback.
/// 
/// Navigation Items:
/// - Home: Main dashboard and overview
/// - Meals: Meal planning and nutrition tracking
/// - Exercise: Workout tracking and recommendations
/// - Community: Social features and support
/// - Profile: User settings and account management

import 'package:flutter/material.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';

/// AppNavbar - Custom bottom navigation bar widget
/// 
/// This widget creates a floating-style navigation bar with rounded corners,
/// shadows, and smooth animations. It provides navigation between the main
/// app sections and maintains the current selected tab state.
class AppNavbar extends StatelessWidget {
  /// Currently selected tab index (0-4)
  final int currentIndex;
  
  /// Callback function called when a tab is tapped
  final ValueChanged<int> onChanged;
  
  /// Creates a new AppNavbar instance
  /// 
  /// [currentIndex] - Index of currently selected tab
  /// [onChanged] - Callback for tab selection changes
  const AppNavbar({super.key, required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16), // Margin for floating effect
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Subtle shadow
            blurRadius: 20,
            offset: const Offset(0, 8), // Shadow offset
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25), // Clip content to rounded corners
        child: CrystalNavigationBar(
          currentIndex: currentIndex, // Currently selected tab
          onTap: onChanged, // Tab selection callback
          items: [
            // Home tab - Main dashboard
            CrystalNavigationBarItem(
              icon: Icons.home_outlined,
              selectedColor: Colors.blue,
            ),
            // Meals tab - Nutrition and meal planning
            CrystalNavigationBarItem(
              icon: Icons.restaurant_outlined,
              selectedColor: Colors.blue,
            ),
            // Exercise tab - Workout tracking
            CrystalNavigationBarItem(
              icon: Icons.fitness_center,
              selectedColor: Colors.blue,
            ),
            // Community tab - Social features
            CrystalNavigationBarItem(
              icon: Icons.groups_outlined,
              selectedColor: Colors.blue,
            ),
            // Profile tab - User settings
            CrystalNavigationBarItem(
              icon: Icons.person_outline,
              selectedColor: Colors.blue,
            ),
          ],
          backgroundColor: Colors.white, // White background
          unselectedItemColor: Colors.grey, // Unselected tab color
          borderRadius: 25, // Rounded corners
          enableFloatingNavBar: false, // Disable floating animation
        ),
      ),
    );
  }
}


