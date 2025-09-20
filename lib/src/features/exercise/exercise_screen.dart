import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'exercise_detail_screen.dart';

/// ExerciseScreen - Main screen for tracking and managing exercises
/// Features:
/// - Exercise categories (Cardio, Strength, Flexibility, etc.)
/// - Exercise tracking and logging
/// - Workout history and progress
/// - Exercise recommendations based on diabetes management
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  // Currently selected exercise category filter
  String? selectedCategory;
  
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  
  // Current search query string
  String _searchQuery = '';

  /// Sample exercise data - In a real app, this would come from an API or database
  /// Each exercise contains information relevant to diabetes management
  final List<Exercise> _allExercises = [
    const Exercise(
      id: '1',
      name: 'Brisk Walking',
      description: 'Moderate intensity walking for cardiovascular health',
      category: 'Cardio',
      duration: 30,
      calories: 150,
      difficulty: 'Easy',
      benefits: ['Heart health', 'Blood sugar control', 'Weight management'],
      isRecommended: true,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Start with 10-15 minutes and gradually increase',
        'Maintain a pace where you can talk but not sing',
        'Walk after meals to help control blood sugar',
        'Use proper walking shoes for comfort and safety'
      ],
    ),
    const Exercise(
      id: '2',
      name: 'Swimming',
      description: 'Low-impact full body workout',
      category: 'Cardio',
      duration: 45,
      calories: 300,
      difficulty: 'Medium',
      benefits: ['Joint-friendly', 'Full body workout', 'Stress relief'],
      isRecommended: true,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Start with 20-30 minutes sessions',
        'Focus on proper breathing techniques',
        'Mix different strokes for variety',
        'Stay hydrated before and after swimming'
      ],
    ),
    const Exercise(
      id: '3',
      name: 'Bodyweight Squats',
      description: 'Strength training for lower body',
      category: 'Strength',
      duration: 15,
      calories: 80,
      difficulty: 'Easy',
      benefits: ['Muscle building', 'Bone strength', 'Metabolism boost'],
      isRecommended: false,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Keep your back straight and chest up',
        'Lower until thighs are parallel to floor',
        'Start with 10-15 reps, 2-3 sets',
        'Breathe out on the way up, in on the way down'
      ],
    ),
    const Exercise(
      id: '4',
      name: 'Yoga',
      description: 'Mind-body practice for flexibility and stress relief',
      category: 'Flexibility',
      duration: 30,
      calories: 100,
      difficulty: 'Easy',
      benefits: ['Stress reduction', 'Flexibility', 'Mindfulness'],
      isRecommended: true,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Start with basic poses and gradually progress',
        'Focus on breathing throughout the practice',
        'Listen to your body and don\'t force positions',
        'Practice regularly for best results'
      ],
    ),
    const Exercise(
      id: '5',
      name: 'Cycling',
      description: 'Low-impact cardiovascular exercise',
      category: 'Cardio',
      duration: 40,
      calories: 250,
      difficulty: 'Medium',
      benefits: ['Heart health', 'Leg strength', 'Endurance'],
      isRecommended: false,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Adjust seat height for proper leg extension',
        'Start with flat terrain before hills',
        'Wear a helmet for safety',
        'Monitor your heart rate during cycling'
      ],
    ),
    const Exercise(
      id: '6',
      name: 'Resistance Bands',
      description: 'Portable strength training with bands',
      category: 'Strength',
      duration: 20,
      calories: 120,
      difficulty: 'Medium',
      benefits: ['Muscle tone', 'Portable', 'Versatile'],
      isRecommended: false,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Choose appropriate resistance level',
        'Control the movement both ways',
        'Start with 2-3 sets of 10-15 reps',
        'Focus on proper form over speed'
      ],
    ),
    const Exercise(
      id: '7',
      name: 'Tai Chi',
      description: 'Gentle martial art for balance and coordination',
      category: 'Flexibility',
      duration: 25,
      calories: 90,
      difficulty: 'Easy',
      benefits: ['Balance', 'Coordination', 'Relaxation'],
      isRecommended: true,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Practice in a quiet, open space',
        'Move slowly and deliberately',
        'Focus on breathing and mindfulness',
        'Start with basic forms and build up'
      ],
    ),
    const Exercise(
      id: '8',
      name: 'Dancing',
      description: 'Fun cardiovascular exercise with music',
      category: 'Cardio',
      duration: 30,
      calories: 200,
      difficulty: 'Easy',
      benefits: ['Fun factor', 'Social activity', 'Coordination'],
      isRecommended: false,
      youtubeUrl: 'dQw4w9WgXcQ',
      suggestions: [
        'Choose music with a steady beat',
        'Start with simple moves and build complexity',
        'Dance for 3-5 minute intervals',
        'Have fun and don\'t worry about perfection'
      ],
    ),
  ];

  /// Getter for recommended exercises - filters exercises marked as recommended
  /// Used to display the recommended exercises section
  List<Exercise> get _recommendedExercises => _allExercises.where((exercise) => exercise.isRecommended).toList();

  /// Getter for filtered exercises based on current search and category selection
  /// Applies both category filter and search query filter
  List<Exercise> get _filteredExercises {
    var exercises = _allExercises;
    
    // Filter by selected category if one is selected
    if (selectedCategory != null) {
      exercises = exercises.where((exercise) => exercise.category == selectedCategory).toList();
    }
    
    // Filter by search query if one is entered
    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((exercise) => 
        exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        exercise.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        exercise.benefits.any((benefit) => benefit.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    
    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with transparent background for modern look
      appBar: AppBar(
        title: const Text('Exercise'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar - allows users to search exercises by name, description, or benefits
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                hintText: 'Search exercises, benefits...',
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
          
          // Exercise Category Filter Chips - horizontal scrollable filter buttons
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('All', null),
                const SizedBox(width: 8),
                _buildCategoryChip('Cardio', 'Cardio'),
                const SizedBox(width: 8),
                _buildCategoryChip('Strength', 'Strength'),
                const SizedBox(width: 8),
                _buildCategoryChip('Flexibility', 'Flexibility'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Main content area - scrollable list containing recommended and all exercises
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                // Recommended Exercises Section - horizontal scrolling cards for recommended exercises
                if (_recommendedExercises.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended for You',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // "Recommended" indicator badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Best',
                              style: TextStyle(
                                color: Colors.green.shade700,
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
                  // Horizontal scrolling list of recommended exercise cards
                  SizedBox(
                    width: 215,
                    height: 215,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _recommendedExercises[index];
                        return _buildRecommendedExerciseCard(exercise);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // All Exercises Section Header - shows current filter and exercise count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory != null 
                        ? '$selectedCategory Exercises'
                        : 'All Exercises',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Dynamic exercise count based on current filters
                    Text(
                      '${_filteredExercises.length} exercises',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Exercises List - vertical list showing all filtered exercises
                ..._filteredExercises.map((exercise) => _buildExerciseCard(exercise)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a category filter chip with icon and label
  /// Changes appearance based on selection state
  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
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
              _getCategoryIcon(category),
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

  /// Returns appropriate icon for each exercise category
  /// Uses fitness-themed icons for better UX
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Cardio':
        return Icons.favorite_outline; // Heart for cardio
      case 'Strength':
        return Icons.fitness_center; // Dumbbell for strength
      case 'Flexibility':
        return Icons.accessibility_new; // Flexibility icon
      default:
        return Icons.sports_gymnastics; // General sports icon
    }
  }

  /// Builds a recommended exercise card for horizontal scrolling
  /// Compact design with essential information only
  Widget _buildRecommendedExerciseCard(Exercise exercise) {
    return GestureDetector(
      onTap: () => _navigateToExerciseDetail(exercise),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise image placeholder with category color coding
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: _getCategoryColor(exercise.category).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(exercise.category),
                    size: 32,
                    color: _getCategoryColor(exercise.category),
                  ),
                ),
              ),
              // Card content with essential info only
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category tag
                    _buildCategoryTag(exercise.category),
                    const SizedBox(height: 8),
                    // Essential info: duration, calories, difficulty
                    _buildEssentialInfo(exercise),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an exercise card for the vertical list
  /// Shows exercise image, name, category tag, and detailed information
  Widget _buildExerciseCard(Exercise exercise) {
    return GestureDetector(
      onTap: () => _navigateToExerciseDetail(exercise),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Exercise image placeholder with category color coding
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getCategoryColor(exercise.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(exercise.category),
                    size: 32,
                    color: _getCategoryColor(exercise.category),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Exercise information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (exercise.isRecommended)
                          Icon(Icons.star, size: 16, color: Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildCategoryTag(exercise.category),
                    const SizedBox(height: 8),
                    Text(
                      exercise.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildExerciseInfo(exercise, isCompact: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds category tag with color coding
  Widget _buildCategoryTag(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          color: _getCategoryColor(category),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds essential exercise information for recommended cards
  /// Shows only duration, calories, and difficulty in a compact format
  Widget _buildEssentialInfo(Exercise exercise) {
    return Column(
      children: [
        Row(
          children: [
            _buildInfoItem(Icons.access_time, '${exercise.duration}m', true),
            const SizedBox(width: 8),
            _buildInfoItem(Icons.local_fire_department, '${exercise.calories} cal', true),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildInfoItem(Icons.speed, exercise.difficulty, true),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  /// Builds exercise information display
  /// Shows duration, calories, and difficulty with appropriate icons
  Widget _buildExerciseInfo(Exercise exercise, {bool isCompact = false}) {
    return Row(
      children: [
        _buildInfoItem(Icons.access_time, '${exercise.duration}m', isCompact),
        const SizedBox(width: 12),
        _buildInfoItem(Icons.local_fire_department, '${exercise.calories} cal', isCompact),
        const SizedBox(width: 12),
        _buildInfoItem(Icons.speed, exercise.difficulty, isCompact),
      ],
    );
  }

  /// Builds individual info item with icon and text
  Widget _buildInfoItem(IconData icon, String text, bool isCompact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isCompact ? 12 : 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Returns color associated with each exercise category
  /// Used for consistent color coding throughout the UI
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cardio':
        return Colors.red; // Heart/energy color
      case 'Strength':
        return Colors.blue; // Strength/trust color
      case 'Flexibility':
        return Colors.purple; // Flexibility/creativity color
      default:
        return Colors.grey; // Default color
    }
  }

  /// Navigates to the exercise detail screen
  void _navigateToExerciseDetail(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }
}

/// Exercise data model for the exercise screen
/// Contains all necessary information for exercise tracking
class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final int duration; // in minutes
  final int calories; // estimated calories burned
  final String difficulty; // Easy, Medium, Hard
  final List<String> benefits;
  final bool isRecommended;
  final String youtubeUrl; // YouTube video URL for the exercise
  final List<String> suggestions; // Exercise suggestions and tips

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.duration,
    required this.calories,
    required this.difficulty,
    required this.benefits,
    this.isRecommended = false,
    required this.youtubeUrl,
    required this.suggestions,
  });
}