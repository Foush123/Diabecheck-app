/// Data Models for Diabecheck App
/// 
/// This file contains all the data models used throughout the application.
/// These models represent the core data structures for tracking health metrics,
/// meals, exercises, and other app-related information.
/// 
/// Key Models:
/// - SugarLog: Blood glucose level tracking
/// - CaloriesLog: Calorie intake tracking
/// - WaterLog: Hydration tracking
/// - Meal: Meal information with nutritional data
/// - Exercise: Exercise tracking and recommendations

/// SugarLog - Represents a single blood glucose measurement
/// 
/// This model stores blood sugar readings with timestamps for tracking
/// glucose levels over time. Essential for diabetes management.
class SugarLog {
  /// Timestamp when the measurement was taken
  final DateTime timestamp;
  
  /// Blood glucose level in mg/dL (milligrams per deciliter)
  final double mgPerDl;

  /// Creates a new SugarLog instance
  /// 
  /// [timestamp] - When the measurement was taken
  /// [mgPerDl] - Blood glucose level in mg/dL
  SugarLog({required this.timestamp, required this.mgPerDl});

  /// Converts SugarLog to JSON for storage
  /// Uses abbreviated keys ('t' for timestamp, 'v' for value) to save space
  Map<String, dynamic> toJson() => {'t': timestamp.toIso8601String(), 'v': mgPerDl};
  
  /// Creates SugarLog from JSON data
  /// 
  /// [j] - JSON map containing timestamp and value
  /// Returns a new SugarLog instance
  factory SugarLog.fromJson(Map<String, dynamic> j) => SugarLog(
    timestamp: DateTime.parse(j['t'] as String), 
    mgPerDl: (j['v'] as num).toDouble()
  );
}

/// CaloriesLog - Represents a single calorie intake entry
/// 
/// This model stores calorie consumption data with timestamps for tracking
/// daily caloric intake and maintaining a balanced diet.
class CaloriesLog {
  /// Timestamp when the calories were consumed
  final DateTime timestamp;
  
  /// Number of calories consumed
  final int kcal;

  /// Creates a new CaloriesLog instance
  /// 
  /// [timestamp] - When the calories were consumed
  /// [kcal] - Number of calories consumed
  CaloriesLog({required this.timestamp, required this.kcal});

  /// Converts CaloriesLog to JSON for storage
  Map<String, dynamic> toJson() => {'t': timestamp.toIso8601String(), 'v': kcal};
  
  /// Creates CaloriesLog from JSON data
  factory CaloriesLog.fromJson(Map<String, dynamic> j) => CaloriesLog(
    timestamp: DateTime.parse(j['t'] as String), 
    kcal: (j['v'] as num).toInt()
  );
}

/// WaterLog - Represents a single water intake entry
/// 
/// This model stores hydration data with timestamps for tracking
/// daily water consumption and maintaining proper hydration levels.
class WaterLog {
  /// Timestamp when the water was consumed
  final DateTime timestamp;
  
  /// Number of cups of water consumed
  final int cups;

  /// Creates a new WaterLog instance
  /// 
  /// [timestamp] - When the water was consumed
  /// [cups] - Number of cups of water consumed
  WaterLog({required this.timestamp, required this.cups});

  /// Converts WaterLog to JSON for storage
  Map<String, dynamic> toJson() => {'t': timestamp.toIso8601String(), 'v': cups};
  
  /// Creates WaterLog from JSON data
  factory WaterLog.fromJson(Map<String, dynamic> j) => WaterLog(
    timestamp: DateTime.parse(j['t'] as String), 
    cups: (j['v'] as num).toInt()
  );
}

/// MealType - Enumeration of different meal categories
/// 
/// Defines the four main meal types used throughout the application
/// for categorization and filtering purposes.
enum MealType { 
  breakfast, // Morning meal
  lunch,     // Midday meal
  dinner,    // Evening meal
  snacks     // Light meals between main meals
}

/// Meal - Represents a complete meal with nutritional information
/// 
/// This comprehensive model stores all meal-related data including
/// nutritional values, preparation details, and metadata for the
/// meal planning and tracking features.
class Meal {
  /// Unique identifier for the meal
  final String id;
  
  /// Name of the meal
  final String name;
  
  /// Brief description of the meal
  final String description;
  
  /// Category/type of meal (breakfast, lunch, dinner, snacks)
  final MealType type;
  
  /// Total calories in the meal
  final int calories;
  
  /// Sugar content in grams
  final double sugar;
  
  /// Protein content in grams
  final double protein;
  
  /// Carbohydrate content in grams
  final double carbs;
  
  /// Fat content in grams
  final double fat;
  
  /// URL or path to meal image
  final String imageUrl;
  
  /// Whether this meal is currently trending
  final bool isTrending;
  
  /// Whether this meal requires premium access
  final bool isPremium;
  
  /// List of ingredients in the meal
  final List<String> ingredients;
  
  /// Preparation time in minutes
  final int prepTime;

  /// Creates a new Meal instance
  /// 
  /// All nutritional values are required, while optional fields have defaults
  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.calories,
    required this.sugar,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.imageUrl,
    this.isTrending = false,
    this.isPremium = false,
    this.ingredients = const [],
    this.prepTime = 0,
  });

  /// Converts Meal to JSON for storage or API communication
  /// 
  /// Returns a Map containing all meal data in JSON format
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'calories': calories,
    'sugar': sugar,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'imageUrl': imageUrl,
    'isTrending': isTrending,
    'isPremium': isPremium,
    'ingredients': ingredients,
    'prepTime': prepTime,
  };

  /// Creates Meal from JSON data
  /// 
  /// [json] - JSON map containing meal data
  /// Returns a new Meal instance with data from JSON
  /// 
  /// Handles optional fields with default values for backward compatibility
  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    type: MealType.values.firstWhere((e) => e.name == json['type']),
    calories: json['calories'] as int,
    sugar: (json['sugar'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    imageUrl: json['imageUrl'] as String,
    isTrending: json['isTrending'] as bool? ?? false,
    isPremium: json['isPremium'] as bool? ?? false,
    ingredients: List<String>.from(json['ingredients'] as List? ?? []),
    prepTime: json['prepTime'] as int? ?? 0,
  );
}


