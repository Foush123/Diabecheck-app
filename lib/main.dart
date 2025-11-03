/// Diabecheck - Flutter Mobile App
/// 
/// A comprehensive diabetes management application built with Flutter.
/// This app helps users track their blood sugar levels, manage meals,
/// log exercise activities, and connect with a supportive community.
/// 
/// Main Features:
/// - Blood sugar level tracking and monitoring
/// - Meal planning and nutritional information
/// - Exercise tracking and recommendations
/// - Community support and sharing
/// - User profile and progress tracking
/// 
/// Author: Diabecheck Development Team
/// Version: 1.0.0
/// Flutter Version: 3.0+

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'src/services/notification_service.dart';

/// Main entry point of the Diabecheck application
/// Initializes and runs the Flutter app with the DiabecheckApp widget
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure we have an authenticated user (anonymous) for Firestore rules
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      // Anonymous sign-in may be disabled in Firebase Console
      // Features requiring auth will be limited until a user signs in
    }
  }
  await NotificationService.instance.init();
  runApp(const DiabecheckApp());
}
