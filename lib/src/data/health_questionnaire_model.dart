/// Health Questionnaire Data Model
/// 
/// This model represents the health information collected during user signup.
/// It contains all the fields required for diabetes risk assessment and
/// personalized health recommendations.

class HealthQuestionnaire {
  // Basic Information
  final int age;
  final String sex;
  final double height; // in cm
  final double weight; // in kg
  final double waistCircumference; // in cm

  // Health History
  final bool familyHistoryDiabetes;
  final bool historyHighBloodPressure;
  final bool historyHighCholesterol;
  final int physicalActivityDaysPerWeek;
  final int physicalActivityMinutesPerSession;

  // Lifestyle & Symptoms
  final String dietQuality;
  final String smokingStatus;
  final String recentSymptoms;
  final String bloodSugarTestResults;

  const HealthQuestionnaire({
    required this.age,
    required this.sex,
    required this.height,
    required this.weight,
    required this.waistCircumference,
    required this.familyHistoryDiabetes,
    required this.historyHighBloodPressure,
    required this.historyHighCholesterol,
    required this.physicalActivityDaysPerWeek,
    required this.physicalActivityMinutesPerSession,
    required this.dietQuality,
    required this.smokingStatus,
    required this.recentSymptoms,
    required this.bloodSugarTestResults,
  });

  /// Creates a HealthQuestionnaire from a map (useful for JSON serialization)
  factory HealthQuestionnaire.fromMap(Map<String, dynamic> map) {
    return HealthQuestionnaire(
      age: map['age'] as int,
      sex: map['sex'] as String,
      height: map['height'] as double,
      weight: map['weight'] as double,
      waistCircumference: map['waistCircumference'] as double,
      familyHistoryDiabetes: map['familyHistoryDiabetes'] as bool,
      historyHighBloodPressure: map['historyHighBloodPressure'] as bool,
      historyHighCholesterol: map['historyHighCholesterol'] as bool,
      physicalActivityDaysPerWeek: map['physicalActivityDaysPerWeek'] as int,
      physicalActivityMinutesPerSession: map['physicalActivityMinutesPerSession'] as int,
      dietQuality: map['dietQuality'] as String,
      smokingStatus: map['smokingStatus'] as String,
      recentSymptoms: map['recentSymptoms'] as String,
      bloodSugarTestResults: map['bloodSugarTestResults'] as String,
    );
  }

  /// Converts a HealthQuestionnaire to a map (useful for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'sex': sex,
      'height': height,
      'weight': weight,
      'waistCircumference': waistCircumference,
      'familyHistoryDiabetes': familyHistoryDiabetes,
      'historyHighBloodPressure': historyHighBloodPressure,
      'historyHighCholesterol': historyHighCholesterol,
      'physicalActivityDaysPerWeek': physicalActivityDaysPerWeek,
      'physicalActivityMinutesPerSession': physicalActivityMinutesPerSession,
      'dietQuality': dietQuality,
      'smokingStatus': smokingStatus,
      'recentSymptoms': recentSymptoms,
      'bloodSugarTestResults': bloodSugarTestResults,
    };
  }

  /// Calculates BMI (Body Mass Index)
  double get bmi => weight / ((height / 100) * (height / 100));

  /// Returns BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Calculates total weekly physical activity in minutes
  int get totalWeeklyPhysicalActivity => 
      physicalActivityDaysPerWeek * physicalActivityMinutesPerSession;

  /// Returns physical activity level category
  String get physicalActivityLevel {
    final totalMinutes = totalWeeklyPhysicalActivity;
    if (totalMinutes == 0) return 'Sedentary';
    if (totalMinutes < 150) return 'Low activity';
    if (totalMinutes < 300) return 'Moderate activity';
    return 'High activity';
  }

  /// Calculates a simple diabetes risk score (0-10 scale)
  /// Higher scores indicate higher risk
  int get diabetesRiskScore {
    int score = 0;
    
    // Age factor
    if (age >= 45) {
      score += 2;
    } else if (age >= 35) {
      score += 1;
    }
    
    // BMI factor
    if (bmi >= 30) {
      score += 2;
    } else if (bmi >= 25) {
      score += 1;
    }
    
    // Family history
    if (familyHistoryDiabetes) {
      score += 2;
    }
    
    // Health conditions
    if (historyHighBloodPressure) {
      score += 1;
    }
    if (historyHighCholesterol) {
      score += 1;
    }
    
    // Physical activity
    if (totalWeeklyPhysicalActivity < 150) {
      score += 1;
    }
    
    // Smoking
    if (smokingStatus == 'Current smoker') {
      score += 1;
    }
    
    return score;
  }

  /// Returns diabetes risk level based on the risk score
  String get diabetesRiskLevel {
    final score = diabetesRiskScore;
    if (score <= 2) return 'Low risk';
    if (score <= 4) return 'Moderate risk';
    if (score <= 6) return 'High risk';
    return 'Very high risk';
  }

  /// Creates a copy of this HealthQuestionnaire with updated values
  HealthQuestionnaire copyWith({
    int? age,
    String? sex,
    double? height,
    double? weight,
    double? waistCircumference,
    bool? familyHistoryDiabetes,
    bool? historyHighBloodPressure,
    bool? historyHighCholesterol,
    int? physicalActivityDaysPerWeek,
    int? physicalActivityMinutesPerSession,
    String? dietQuality,
    String? smokingStatus,
    String? recentSymptoms,
    String? bloodSugarTestResults,
  }) {
    return HealthQuestionnaire(
      age: age ?? this.age,
      sex: sex ?? this.sex,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      waistCircumference: waistCircumference ?? this.waistCircumference,
      familyHistoryDiabetes: familyHistoryDiabetes ?? this.familyHistoryDiabetes,
      historyHighBloodPressure: historyHighBloodPressure ?? this.historyHighBloodPressure,
      historyHighCholesterol: historyHighCholesterol ?? this.historyHighCholesterol,
      physicalActivityDaysPerWeek: physicalActivityDaysPerWeek ?? this.physicalActivityDaysPerWeek,
      physicalActivityMinutesPerSession: physicalActivityMinutesPerSession ?? this.physicalActivityMinutesPerSession,
      dietQuality: dietQuality ?? this.dietQuality,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      recentSymptoms: recentSymptoms ?? this.recentSymptoms,
      bloodSugarTestResults: bloodSugarTestResults ?? this.bloodSugarTestResults,
    );
  }

  @override
  String toString() {
    return 'HealthQuestionnaire(age: $age, sex: $sex, height: $height, weight: $weight, waistCircumference: $waistCircumference, familyHistoryDiabetes: $familyHistoryDiabetes, historyHighBloodPressure: $historyHighBloodPressure, historyHighCholesterol: $historyHighCholesterol, physicalActivityDaysPerWeek: $physicalActivityDaysPerWeek, physicalActivityMinutesPerSession: $physicalActivityMinutesPerSession, dietQuality: $dietQuality, smokingStatus: $smokingStatus, recentSymptoms: $recentSymptoms, bloodSugarTestResults: $bloodSugarTestResults)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthQuestionnaire &&
        other.age == age &&
        other.sex == sex &&
        other.height == height &&
        other.weight == weight &&
        other.waistCircumference == waistCircumference &&
        other.familyHistoryDiabetes == familyHistoryDiabetes &&
        other.historyHighBloodPressure == historyHighBloodPressure &&
        other.historyHighCholesterol == historyHighCholesterol &&
        other.physicalActivityDaysPerWeek == physicalActivityDaysPerWeek &&
        other.physicalActivityMinutesPerSession == physicalActivityMinutesPerSession &&
        other.dietQuality == dietQuality &&
        other.smokingStatus == smokingStatus &&
        other.recentSymptoms == recentSymptoms &&
        other.bloodSugarTestResults == bloodSugarTestResults;
  }

  @override
  int get hashCode {
    return Object.hash(
      age,
      sex,
      height,
      weight,
      waistCircumference,
      familyHistoryDiabetes,
      historyHighBloodPressure,
      historyHighCholesterol,
      physicalActivityDaysPerWeek,
      physicalActivityMinutesPerSession,
      dietQuality,
      smokingStatus,
      recentSymptoms,
      bloodSugarTestResults,
    );
  }
}
