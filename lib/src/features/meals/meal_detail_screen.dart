import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../config/theme.dart';

/// MealDetailScreen - Shows detailed information about a specific meal
/// Features:
/// - Meal image and basic information
/// - Ingredients list with quantities
/// - Step-by-step preparation instructions
/// - Nutritional information
/// - Back navigation
class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with meal name and back button
      appBar: AppBar(
        title: Text(meal.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image placeholder with meal type color coding
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: _getMealTypeColor(meal.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: _getMealTypeColor(meal.type),
                    ),
                  ),
                  // Premium meal indicator
                  if (meal.isPremium)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Meal type tag and description
            Row(
              children: [
                _buildMealTypeTag(meal.type),
                const Spacer(),
                if (meal.prepTime > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.prepTime} min',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Meal description
            Text(
              meal.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Nutritional Information Section
            _buildSectionTitle('Nutritional Information'),
            const SizedBox(height: 12),
            _buildNutritionGrid(),
            const SizedBox(height: 24),

            // Ingredients Section
            _buildSectionTitle('Ingredients'),
            const SizedBox(height: 12),
            _buildIngredientsList(),
            const SizedBox(height: 24),

            // Preparation Instructions Section
            _buildSectionTitle('Preparation Instructions'),
            const SizedBox(height: 12),
            _buildPreparationSteps(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds section title with consistent styling
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds meal type tag with color coding
  Widget _buildMealTypeTag(MealType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getMealTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: TextStyle(
          color: _getMealTypeColor(type),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds nutritional information grid
  Widget _buildNutritionGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  Icons.local_fire_department,
                  'Calories',
                  '${meal.calories}',
                  'kcal',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  Icons.cake,
                  'Sugar',
                  '${meal.sugar}',
                  'g',
                  Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  Icons.fitness_center,
                  'Protein',
                  '${meal.protein}',
                  'g',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  Icons.grain,
                  'Carbs',
                  '${meal.carbs}',
                  'g',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  Icons.opacity,
                  'Fat',
                  '${meal.fat}',
                  'g',
                  Colors.purple,
                ),
              ),
              const Expanded(child: SizedBox()), // Empty space for alignment
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual nutrition item
  Widget _buildNutritionItem(IconData icon, String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds ingredients list
  Widget _buildIngredientsList() {
    // Sample ingredients - in a real app, this would come from the meal data
    final ingredients = _getSampleIngredients(meal.name);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: ingredients.map((ingredient) => _buildIngredientItem(ingredient)).toList(),
      ),
    );
  }

  /// Builds individual ingredient item
  Widget _buildIngredientItem(Map<String, String> ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getMealTypeColor(meal.type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient['name']!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            ingredient['quantity']!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds preparation steps
  Widget _buildPreparationSteps() {
    // Sample preparation steps - in a real app, this would come from the meal data
    final steps = _getSamplePreparationSteps(meal.name);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _buildPreparationStep(index + 1, step);
        }).toList(),
      ),
    );
  }

  /// Builds individual preparation step
  Widget _buildPreparationStep(int stepNumber, String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getMealTypeColor(meal.type),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns sample ingredients based on meal name
  List<Map<String, String>> _getSampleIngredients(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'avocado toast':
        return [
          {'name': 'Whole grain bread', 'quantity': '2 slices'},
          {'name': 'Avocado', 'quantity': '1 medium'},
          {'name': 'Lemon juice', 'quantity': '1 tbsp'},
          {'name': 'Salt and pepper', 'quantity': 'to taste'},
          {'name': 'Red pepper flakes', 'quantity': 'pinch'},
        ];
      case 'grilled chicken salad':
        return [
          {'name': 'Chicken breast', 'quantity': '150g'},
          {'name': 'Mixed greens', 'quantity': '2 cups'},
          {'name': 'Cherry tomatoes', 'quantity': '1/2 cup'},
          {'name': 'Cucumber', 'quantity': '1/2 medium'},
          {'name': 'Olive oil', 'quantity': '1 tbsp'},
          {'name': 'Balsamic vinegar', 'quantity': '1 tbsp'},
        ];
      case 'salmon with quinoa':
        return [
          {'name': 'Salmon fillet', 'quantity': '150g'},
          {'name': 'Quinoa', 'quantity': '1/2 cup'},
          {'name': 'Broccoli', 'quantity': '1 cup'},
          {'name': 'Carrots', 'quantity': '1 medium'},
          {'name': 'Olive oil', 'quantity': '1 tbsp'},
          {'name': 'Garlic', 'quantity': '2 cloves'},
        ];
      default:
        return [
          {'name': 'Main ingredient', 'quantity': '1 portion'},
          {'name': 'Seasoning', 'quantity': 'to taste'},
          {'name': 'Oil', 'quantity': '1 tbsp'},
        ];
    }
  }

  /// Returns sample preparation steps based on meal name
  List<String> _getSamplePreparationSteps(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'avocado toast':
        return [
          'Toast the whole grain bread slices until golden brown.',
          'Cut the avocado in half and remove the pit.',
          'Mash the avocado with lemon juice, salt, and pepper.',
          'Spread the mashed avocado evenly on the toast.',
          'Sprinkle with red pepper flakes and serve immediately.',
        ];
      case 'grilled chicken salad':
        return [
          'Season the chicken breast with salt and pepper.',
          'Heat a grill pan over medium-high heat.',
          'Cook the chicken for 6-7 minutes per side until cooked through.',
          'Let the chicken rest for 5 minutes, then slice.',
          'Combine mixed greens, tomatoes, and cucumber in a bowl.',
          'Top with sliced chicken and drizzle with olive oil and balsamic vinegar.',
        ];
      case 'salmon with quinoa':
        return [
          'Rinse quinoa and cook according to package instructions.',
          'Season salmon with salt, pepper, and minced garlic.',
          'Heat olive oil in a pan over medium heat.',
          'Cook salmon for 4-5 minutes per side until flaky.',
          'Steam broccoli and carrots until tender.',
          'Serve salmon over quinoa with steamed vegetables.',
        ];
      default:
        return [
          'Prepare the main ingredients as needed.',
          'Season with salt and pepper to taste.',
          'Cook according to your preferred method.',
          'Serve hot and enjoy!',
        ];
    }
  }

  /// Returns color associated with each meal type
  Color _getMealTypeColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snacks:
        return Colors.blue;
    }
  }
}
