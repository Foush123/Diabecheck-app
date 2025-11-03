import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shell/shell_screen.dart';
import '../../data/health_questionnaire_model.dart';

/// Health questionnaire screen for collecting user health information during signup
/// This screen collects comprehensive health data to provide personalized diabetes management
class HealthQuestionnaireScreen extends StatefulWidget {
  static const String routeName = '/health-questionnaire';
  const HealthQuestionnaireScreen({super.key});

  @override
  State<HealthQuestionnaireScreen> createState() => _HealthQuestionnaireScreenState();
}

class _HealthQuestionnaireScreenState extends State<HealthQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  // Controllers for text inputs
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _physicalActivityDaysController = TextEditingController();
  final _physicalActivityMinutesController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _bloodSugarController = TextEditingController();

  // Selected values for dropdowns and radio buttons
  String? _selectedSex;
  bool? _familyHistoryDiabetes;
  bool? _historyHighBloodPressure;
  bool? _historyHighCholesterol;
  String? _dietQuality;
  String? _smokingStatus;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _physicalActivityDaysController.dispose();
    _physicalActivityMinutesController.dispose();
    _symptomsController.dispose();
    _bloodSugarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validate current page before proceeding
    if (_validateCurrentPage()) {
      if (_currentPage < _totalPages - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitQuestionnaire();
      }
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Page 1 - Basic Information
        return _validatePage1();
      case 1: // Page 2 - Health History
        return _validatePage2();
      case 2: // Page 3 - Lifestyle & Symptoms
        return _validatePage3();
      default:
        return true;
    }
  }

  bool _validatePage1() {
    bool isValid = true;
    
    // Validate age
    if (_ageController.text.isEmpty) {
      _showValidationError('Please enter your age');
      return false;
    }
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 1 || age > 120) {
      _showValidationError('Please enter a valid age (1-120)');
      return false;
    }
    
    // Validate sex
    if (_selectedSex == null) {
      _showValidationError('Please select your sex');
      return false;
    }
    
    // Validate height
    if (_heightController.text.isEmpty) {
      _showValidationError('Please enter your height');
      return false;
    }
    final height = double.tryParse(_heightController.text);
    if (height == null || height < 50 || height > 250) {
      _showValidationError('Please enter a valid height (50-250 cm)');
      return false;
    }
    
    // Validate weight
    if (_weightController.text.isEmpty) {
      _showValidationError('Please enter your weight');
      return false;
    }
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight < 20 || weight > 300) {
      _showValidationError('Please enter a valid weight (20-300 kg)');
      return false;
    }
    
    // Validate waist circumference
    if (_waistController.text.isEmpty) {
      _showValidationError('Please enter your waist circumference');
      return false;
    }
    final waist = double.tryParse(_waistController.text);
    if (waist == null || waist < 30 || waist > 200) {
      _showValidationError('Please enter a valid waist measurement (30-200 cm)');
      return false;
    }
    
    return isValid;
  }

  bool _validatePage2() {
    // Validate family history
    if (_familyHistoryDiabetes == null) {
      _showValidationError('Please answer about family history of diabetes');
      return false;
    }
    
    // Validate blood pressure history
    if (_historyHighBloodPressure == null) {
      _showValidationError('Please answer about your blood pressure history');
      return false;
    }
    
    // Validate cholesterol history
    if (_historyHighCholesterol == null) {
      _showValidationError('Please answer about your cholesterol history');
      return false;
    }
    
    // Validate physical activity
    if (_physicalActivityDaysController.text.isEmpty) {
      _showValidationError('Please enter your physical activity days per week');
      return false;
    }
    final days = int.tryParse(_physicalActivityDaysController.text);
    if (days == null || days < 0 || days > 7) {
      _showValidationError('Please enter valid days (0-7)');
      return false;
    }
    
    if (_physicalActivityMinutesController.text.isEmpty) {
      _showValidationError('Please enter your physical activity minutes per session');
      return false;
    }
    final minutes = int.tryParse(_physicalActivityMinutesController.text);
    if (minutes == null || minutes < 0 || minutes > 300) {
      _showValidationError('Please enter valid minutes (0-300)');
      return false;
    }
    
    return true;
  }

  bool _validatePage3() {
    // Validate diet quality
    if (_dietQuality == null) {
      _showValidationError('Please select your diet quality');
      return false;
    }
    
    // Validate smoking status
    if (_smokingStatus == null) {
      _showValidationError('Please select your smoking status');
      return false;
    }
    
    // Validate symptoms
    if (_symptomsController.text.trim().isEmpty) {
      _showValidationError('Please describe any symptoms or write "None"');
      return false;
    }
    
    // Validate blood sugar results
    if (_bloodSugarController.text.trim().isEmpty) {
      _showValidationError('Please enter blood sugar results or write "None"');
      return false;
    }
    
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuestionnaire() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showValidationError('You must be logged in to submit.');
        return;
      }
      // Create the health questionnaire data model
      final questionnaire = HealthQuestionnaire(
        age: int.parse(_ageController.text),
        sex: _selectedSex!,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        waistCircumference: double.parse(_waistController.text),
        familyHistoryDiabetes: _familyHistoryDiabetes!,
        historyHighBloodPressure: _historyHighBloodPressure!,
        historyHighCholesterol: _historyHighCholesterol!,
        physicalActivityDaysPerWeek: int.parse(_physicalActivityDaysController.text),
        physicalActivityMinutesPerSession: int.parse(_physicalActivityMinutesController.text),
        dietQuality: _dietQuality!,
        smokingStatus: _smokingStatus!,
        recentSymptoms: _symptomsController.text,
        bloodSugarTestResults: _bloodSugarController.text,
      );

      // Show summary dialog before completing signup
      _showSummaryDialog(questionnaire);
    }
  }

  void _showSummaryDialog(HealthQuestionnaire questionnaire) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Health Profile Summary'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryItem('BMI', '${questionnaire.bmi.toStringAsFixed(1)} (${questionnaire.bmiCategory})'),
              _buildSummaryItem('Physical Activity', questionnaire.physicalActivityLevel),
              _buildSummaryItem('Diabetes Risk', '${questionnaire.diabetesRiskScore}/10 (${questionnaire.diabetesRiskLevel})'),
              const SizedBox(height: 16),
              const Text(
                'This information will help us provide personalized recommendations for your diabetes management.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _completeSignup(questionnaire);
            },
            child: const Text('Complete Signup'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _completeSignup(HealthQuestionnaire questionnaire) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showValidationError('Please log in to submit.');
        return;
      }
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profiles')
          .doc('health_questionnaire');

      await docRef.set({
        ...questionnaire.toMap(),
        'bmi': questionnaire.bmi,
        'bmiCategory': questionnaire.bmiCategory,
        'physicalActivityLevel': questionnaire.physicalActivityLevel,
        'diabetesRiskScore': questionnaire.diabetesRiskScore,
        'diabetesRiskLevel': questionnaire.diabetesRiskLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(ShellScreen.routeName);
    } catch (e) {
      _showValidationError('Failed to save data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Page content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPage1(), // Basic info: Age, Sex, Height, Weight, Waist
                  _buildPage2(), // Health history: Family history, Blood pressure, Cholesterol, Physical activity
                  _buildPage3(), // Lifestyle: Diet, Smoking, Symptoms, Blood sugar
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentPage + 1} of $_totalPages',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${((_currentPage + 1) / _totalPages * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your basic health profile (All fields required)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Age
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            hint: 'Enter your age',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Age is required';
              final age = int.tryParse(value);
              if (age == null || age < 1 || age > 120) {
                return 'Please enter a valid age';
              }
              return null;
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          
          // Sex
          _buildDropdownField(
            label: 'Sex',
            value: _selectedSex,
            items: const ['Male', 'Female', 'Other', 'Prefer not to say'],
            onChanged: (value) => setState(() => _selectedSex = value),
            validator: (value) => value == null ? 'Please select your sex' : null,
          ),
          const SizedBox(height: 16),
          
          // Height
          _buildTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'Enter your height in centimeters',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Height is required';
              final height = double.tryParse(value);
              if (height == null || height < 50 || height > 250) {
                return 'Please enter a valid height (50-250 cm)';
              }
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          const SizedBox(height: 16),
          
          // Weight
          _buildTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'Enter your weight in kilograms',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Weight is required';
              final weight = double.tryParse(value);
              if (weight == null || weight < 20 || weight > 300) {
                return 'Please enter a valid weight (20-300 kg)';
              }
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          const SizedBox(height: 16),
          
          // Waist circumference
          _buildTextField(
            controller: _waistController,
            label: 'Waist Circumference (cm)',
            hint: 'Enter your waist circumference',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Waist circumference is required';
              final waist = double.tryParse(value);
              if (waist == null || waist < 30 || waist > 200) {
                return 'Please enter a valid waist measurement (30-200 cm)';
              }
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your family history and current health conditions (All fields required)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Family history of diabetes
          _buildYesNoField(
            label: 'Do you have a family history of diabetes?',
            value: _familyHistoryDiabetes,
            onChanged: (value) => setState(() => _familyHistoryDiabetes = value),
            validator: (value) => value == null ? 'Please answer this question' : null,
          ),
          const SizedBox(height: 16),
          
          // History of high blood pressure
          _buildYesNoField(
            label: 'Have you ever been diagnosed with high blood pressure?',
            value: _historyHighBloodPressure,
            onChanged: (value) => setState(() => _historyHighBloodPressure = value),
            validator: (value) => value == null ? 'Please answer this question' : null,
          ),
          const SizedBox(height: 16),
          
          // History of high cholesterol
          _buildYesNoField(
            label: 'Have you ever been diagnosed with high cholesterol?',
            value: _historyHighCholesterol,
            onChanged: (value) => setState(() => _historyHighCholesterol = value),
            validator: (value) => value == null ? 'Please answer this question' : null,
          ),
          const SizedBox(height: 16),
          
          // Physical activity
          Text(
            'How often do you exercise or do physical activity?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Include activities like walking, running, gym workouts, sports, etc.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _physicalActivityDaysController,
                  label: 'Days per week',
                  hint: '0-7',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final days = int.tryParse(value);
                    if (days == null || days < 0 || days > 7) {
                      return 'Enter 0-7 days';
                    }
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _physicalActivityMinutesController,
                  label: 'Minutes per session',
                  hint: '0-300',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final minutes = int.tryParse(value);
                    if (minutes == null || minutes < 0 || minutes > 300) {
                      return 'Enter 0-300 minutes';
                    }
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lifestyle & Symptoms',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your lifestyle and any symptoms you may have (All fields required)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Diet quality
          _buildDropdownField(
            label: 'How would you describe your typical diet?',
            value: _dietQuality,
            items: const [
              'Very healthy',
              'Pretty good ',
              'Average',
              'Could be better',
            ],
            onChanged: (value) => setState(() => _dietQuality = value),
            validator: (value) => value == null ? 'Please select your diet quality' : null,
          ),
          const SizedBox(height: 16),
          
          // Smoking status
          _buildDropdownField(
            label: 'Do you smoke or have you smoked in the past?',
            value: _smokingStatus,
            items: const [
              'Never smoked',
              'Used to smoke but quit',
              'Currently smoke regularly',
              'Occasionally smoke',
            ],
            onChanged: (value) => setState(() => _smokingStatus = value),
            validator: (value) => value == null ? 'Please select your smoking status' : null,
          ),
          const SizedBox(height: 16),
          
          // Recent symptoms
          _buildTextField(
            controller: _symptomsController,
            label: 'Have you experienced any of these symptoms recently?',
            hint: 'Describe any symptoms like increased thirst, frequent urination, fatigue, blurred vision, or write "None" if you haven\'t experienced any',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe any symptoms or write "None"';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Blood sugar test results
          _buildTextField(
            controller: _bloodSugarController,
            label: 'Do you have any recent blood sugar test results?',
            hint: 'Enter your most recent blood sugar reading (mg/dL) or write "None" if you haven\'t had any tests',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter test results or write "None"';
              }
              // Allow "None" or valid numbers
              if (value.toLowerCase().trim() == 'none') return null;
              final bloodSugar = double.tryParse(value);
              if (bloodSugar == null || bloodSugar < 50 || bloodSugar > 500) {
                return 'Please enter a valid blood sugar reading (50-500 mg/dL) or "None"';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoField({
    required String label,
    required bool? value,
    required void Function(bool?) onChanged,
    String? Function(bool?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Yes'),
                value: true,
                groupValue: value,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
                value: false,
                groupValue: value,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        if (validator != null && validator(value) != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              validator(value)!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: const StadiumBorder(),
              ),
              child: Text(_currentPage == _totalPages - 1 ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
