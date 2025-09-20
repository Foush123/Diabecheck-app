/// Local Storage Service for Diabecheck App
/// 
/// This service handles all local data persistence using SharedPreferences.
/// It provides methods to store and retrieve health tracking data locally
/// on the device, ensuring data persistence between app sessions.
/// 
/// Key Features:
/// - Blood sugar level logging and storage
/// - Calorie intake tracking and storage
/// - Water consumption logging and storage
/// - JSON serialization for complex data structures
/// - Automatic timestamp generation for all entries

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// LocalStorageService - Handles local data persistence
/// 
/// This service manages all local storage operations for the Diabecheck app.
/// It uses SharedPreferences to store health tracking data locally on the device.
class LocalStorageService {
  // Storage keys for different data types
  static const _sugarKey = 'sugar_logs';
  static const _caloriesKey = 'calories_logs';
  static const _waterKey = 'water_logs';

  /// Adds a new blood sugar reading to local storage
  /// 
  /// [mgPerDl] - Blood glucose level in mg/dL
  /// 
  /// Creates a new SugarLog with current timestamp and stores it
  /// as JSON in SharedPreferences for persistence
  Future<void> addSugar(double mgPerDl) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_sugarKey) ?? <String>[];
    list.add(jsonEncode(SugarLog(timestamp: DateTime.now(), mgPerDl: mgPerDl).toJson()));
    await prefs.setStringList(_sugarKey, list);
  }

  /// Adds a new calorie intake entry to local storage
  /// 
  /// [kcal] - Number of calories consumed
  /// 
  /// Creates a new CaloriesLog with current timestamp and stores it
  /// as JSON in SharedPreferences for persistence
  Future<void> addCalories(int kcal) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_caloriesKey) ?? <String>[];
    list.add(jsonEncode(CaloriesLog(timestamp: DateTime.now(), kcal: kcal).toJson()));
    await prefs.setStringList(_caloriesKey, list);
  }

  /// Adds a new water intake entry to local storage
  /// 
  /// [cups] - Number of cups of water consumed
  /// 
  /// Creates a new WaterLog with current timestamp and stores it
  /// as JSON in SharedPreferences for persistence
  Future<void> addWater(int cups) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_waterKey) ?? <String>[];
    list.add(jsonEncode(WaterLog(timestamp: DateTime.now(), cups: cups).toJson()));
    await prefs.setStringList(_waterKey, list);
  }
}


