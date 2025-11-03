import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../services/user_data_service.dart';
import '../../config/theme.dart';
import 'meal_detail_screen.dart';

/// MealsScreen - Main screen for displaying and filtering meals
/// Features:
/// - Search functionality for meals and ingredients
/// - Filter by meal type (breakfast, lunch, dinner, snacks)
/// - Trending meals section with horizontal scrolling
/// - Grid view of all meals with nutritional information
/// - Meal type tags and color coding
class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  // Currently selected meal type filter (null means "All")
  MealType? selectedMealType;
  
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  
  // Current search query string
  String _searchQuery = '';

  /// Sample meal data - In a real app, this would come from an API or database
  /// Each meal contains nutritional information, meal type, and metadata
  final List<Meal> _allMeals = [
    // Trending breakfast option - healthy and popular
    const Meal(
      id: '1',
      name: 'Avocado Toast',
      description: 'Healthy breakfast with whole grain bread',
      type: MealType.breakfast,
      calories: 320,
      sugar: 2.5,
      protein: 12.0,
      carbs: 28.0,
      fat: 18.0,
      imageUrl: '',
      isTrending: true,
      prepTime: 10,
    ),
    // Trending lunch option - high protein, low calorie
    const Meal(
      id: '2',
      name: 'Grilled Chicken Salad',
      description: 'Fresh mixed greens with grilled chicken breast',
      type: MealType.lunch,
      calories: 280,
      sugar: 4.0,
      protein: 35.0,
      carbs: 12.0,
      fat: 8.0,
      imageUrl: '',
      isTrending: true,
      prepTime: 15,
    ),
    // Regular dinner option - balanced nutrition
    const Meal(
      id: '3',
      name: 'Salmon with Quinoa',
      description: 'Baked salmon with quinoa and steamed vegetables',
      type: MealType.dinner,
      calories: 450,
      sugar: 3.0,
      protein: 42.0,
      carbs: 35.0,
      fat: 18.0,
      imageUrl: '',
      isTrending: false,
      prepTime: 25,
    ),
    // Trending snack option - quick and healthy
    const Meal(
      id: '4',
      name: 'Greek Yogurt Parfait',
      description: 'Greek yogurt with berries and granola',
      type: MealType.snacks,
      calories: 180,
      sugar: 8.0,
      protein: 15.0,
      carbs: 22.0,
      fat: 4.0,
      imageUrl: '',
      isTrending: true,
      prepTime: 5,
    ),
    // Regular breakfast option - high fiber
    const Meal(
      id: '5',
      name: 'Oatmeal Bowl',
      description: 'Steel-cut oats with banana and nuts',
      type: MealType.breakfast,
      calories: 350,
      sugar: 12.0,
      protein: 14.0,
      carbs: 45.0,
      fat: 12.0,
      imageUrl: '',
      isTrending: false,
      prepTime: 8,
    ),
    // Regular lunch option - balanced macros
    const Meal(
      id: '6',
      name: 'Turkey Wrap',
      description: 'Whole wheat wrap with turkey and vegetables',
      type: MealType.lunch,
      calories: 380,
      sugar: 6.0,
      protein: 28.0,
      carbs: 32.0,
      fat: 16.0,
      imageUrl: '',
      isTrending: false,
      prepTime: 12,
    ),
    // Regular dinner option - vegetarian
    const Meal(
      id: '7',
      name: 'Vegetable Stir Fry',
      description: 'Mixed vegetables with tofu and brown rice',
      type: MealType.dinner,
      calories: 320,
      sugar: 8.0,
      protein: 18.0,
      carbs: 42.0,
      fat: 8.0,
      imageUrl: '',
      isTrending: false,
      prepTime: 20,
    ),
    // Regular snack option - natural sugars
    const Meal(
      id: '8',
      name: 'Apple with Almond Butter',
      description: 'Fresh apple slices with natural almond butter',
      type: MealType.snacks,
      calories: 220,
      sugar: 18.0,
      protein: 8.0,
      carbs: 28.0,
      fat: 12.0,
      imageUrl: '',
      isTrending: false,
      prepTime: 3,
    ),
  ];

  /// Getter for trending meals - filters meals marked as trending
  /// Used to display the horizontal scrolling trending section
  List<Meal> get _trendingMeals => _allMeals.where((meal) => meal.isTrending).toList();

  /// Getter for filtered meals based on current search and meal type selection
  /// Applies both meal type filter and search query filter
  List<Meal> get _filteredMeals {
    var meals = _allMeals;
    
    // Filter by selected meal type if one is selected
    if (selectedMealType != null) {
      meals = meals.where((meal) => meal.type == selectedMealType).toList();
    }
    
    // Filter by search query if one is entered
    if (_searchQuery.isNotEmpty) {
      meals = meals.where((meal) => 
        meal.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        meal.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return meals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with transparent background for modern look
      appBar: AppBar(
        title: const Text('Meals'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar - allows users to search meals by name or ingredients
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                hintText: 'Search meals, ingredients...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Meal Type Filter Chips - horizontal scrollable filter buttons
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMealTypeChip('All', null),
                const SizedBox(width: 8),
                _buildMealTypeChip('Breakfast', MealType.breakfast),
                const SizedBox(width: 8),
                _buildMealTypeChip('Lunch', MealType.lunch),
                const SizedBox(width: 8),
                _buildMealTypeChip('Dinner', MealType.dinner),
                const SizedBox(width: 8),
                _buildMealTypeChip('Snacks', MealType.snacks),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Main content area - scrollable list containing trending and all meals
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                // Trending Meals Section - horizontal scrolling cards for popular meals
                if (_trendingMeals.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trending Meals',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // "Hot" trending indicator badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Hot',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Horizontal scrolling list of trending meal cards
                  SizedBox(
                    height: 245,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trendingMeals.length,
                      itemBuilder: (context, index) {
                        final meal = _trendingMeals[index];
                        return _buildTrendingMealCard(meal);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // All Meals Section Header - shows current filter and meal count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                    Text(
                      selectedMealType != null 
                        ? '${selectedMealType!.name.toUpperCase()} Meals'
                        : 'All Meals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Dynamic meal count based on current filters
                    Text(
                      '${_filteredMeals.length} meals',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Meals Grid - 2-column grid showing all filtered meals
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Adjusted for proper card proportions
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredMeals.length,
                  itemBuilder: (context, index) {
                    final meal = _filteredMeals[index];
                    return _buildMealCard(meal);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a meal type filter chip with icon and label
  /// Changes appearance based on selection state
  Widget _buildMealTypeChip(String label, MealType? type) {
    final isSelected = selectedMealType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedMealType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getMealTypeIcon(type),
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns appropriate icon for each meal type
  /// Uses time-of-day themed icons for better UX
  IconData _getMealTypeIcon(MealType? type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined; // Morning sun
      case MealType.lunch:
        return Icons.wb_sunny; // Full sun
      case MealType.dinner:
        return Icons.nights_stay_outlined; // Night time
      case MealType.snacks:
        return Icons.local_dining_outlined; // Snack icon
      default:
        return Icons.restaurant_outlined; // General restaurant icon
    }
  }

  /// Builds a trending meal card for horizontal scrolling
  /// Compact design with essential information only
  Widget _buildTrendingMealCard(Meal meal) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _navigateToMealDetail(meal),
        child: Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder with meal type color coding
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: _getMealTypeColor(meal.type).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 40,
                    color: _getMealTypeColor(meal.type),
                  ),
                ),
              ),
              // Card content with meal info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Premium meal indicator
                        if (meal.isPremium)
                          const Icon(Icons.lock_outline, size: 16, color: Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildMealTypeTag(meal.type),
                    const SizedBox(height: 8),
                    _buildNutritionInfo(meal, isCompact: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a meal card for the grid view
  /// Shows meal image, name, type tag, nutrition info, and prep time
  Widget _buildMealCard(Meal meal) {
    return GestureDetector(
      onTap: () => _navigateToMealDetail(meal),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with meal type color coding
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: _getMealTypeColor(meal.type).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: _getMealTypeColor(meal.type),
                    ),
                  ),
                  // Premium meal indicator badge
                  if (meal.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Card content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Main content: name, type tag, nutrition info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildMealTypeTag(meal.type),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildNutritionInfo(meal, isCompact: true)),
                            IconButton(
                              tooltip: 'Ate today',
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () async {
                                await UserDataService.instance.addMealLog(meal: {
                                  'mealId': meal.id,
                                  'name': meal.name,
                                  'calories': meal.calories,
                                  'carbs': meal.carbs,
                                  'sugar': meal.sugar,
                                  'type': meal.type.name,
                                });
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Added to today's overview")),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the meal detail screen
  void _navigateToMealDetail(Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealDetailScreen(meal: meal),
      ),
    );
  }

  /// Builds a meal type tag with color coding
  /// Shows meal type (BREAKFAST, LUNCH, etc.) in a colored container
  Widget _buildMealTypeTag(MealType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getMealTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: TextStyle(
          color: _getMealTypeColor(type),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds nutritional information display
  /// Shows calories, sugar, and protein with appropriate icons
  /// isCompact parameter controls spacing and icon sizes
  Widget _buildNutritionInfo(Meal meal, {bool isCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNutritionRow(Icons.local_fire_department, '${meal.calories} cal', isCompact),
        if (!isCompact) const SizedBox(height: 2),
        _buildNutritionRow(Icons.cake, '${meal.sugar}g sugar', isCompact),
        if (!isCompact) const SizedBox(height: 2),
        _buildNutritionRow(Icons.fitness_center, '${meal.protein}g protein', isCompact),
      ],
    );
  }

  /// Builds a single nutrition row with icon and text
  /// Used for displaying individual nutritional values
  Widget _buildNutritionRow(IconData icon, String text, bool isCompact) {
    return Row(
      children: [
        Icon(
          icon,
          size: isCompact ? 10 : 12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Returns color associated with each meal type
  /// Used for consistent color coding throughout the UI
  Color _getMealTypeColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange; // Warm morning color
      case MealType.lunch:
        return Colors.green; // Fresh midday color
      case MealType.dinner:
        return Colors.purple; // Rich evening color
      case MealType.snacks:
        return Colors.blue; // Cool snack color
    }
  }
}


