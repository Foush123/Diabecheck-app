# Diabecheck - Diabetes Management Flutter App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

A comprehensive diabetes management application built with Flutter that helps users track their blood sugar levels, manage meals, log exercise activities, and connect with a supportive community.

## 🌟 Features

### 📊 Health Tracking
- **Blood Sugar Monitoring**: Track glucose levels with timestamps
- **Calorie Logging**: Monitor daily caloric intake
- **Hydration Tracking**: Log water consumption
- **Progress Visualization**: Charts and graphs for health metrics

### 🍎 Meal Management
- **Meal Planning**: Browse and filter meals by type (breakfast, lunch, dinner, snacks)
- **Nutritional Information**: Detailed calorie, sugar, protein, and macro tracking
- **Trending Meals**: Discover popular and recommended meal options
- **Meal Details**: Ingredients lists and step-by-step preparation instructions
- **Search Functionality**: Find meals by name, ingredients, or nutritional benefits

### 💪 Exercise Tracking
- **Exercise Categories**: Cardio, Strength, and Flexibility workouts
- **Exercise Recommendations**: Personalized suggestions for diabetes management
- **Calorie Burn Tracking**: Monitor calories burned during workouts
- **Difficulty Levels**: Easy, Medium, and Hard exercise options
- **Benefits Tracking**: Track health benefits of different exercises

### 👥 Community Features
- **Social Support**: Connect with other diabetes patients
- **Progress Sharing**: Share achievements and milestones
- **Community Feed**: Stay updated with community activities

### 👤 User Profile
- **Personal Information**: Manage user account details
- **Health History**: View past health metrics and trends
- **Settings**: Customize app preferences and notifications

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── src/
│   ├── app.dart             # Main app configuration
│   ├── config/
│   │   └── theme.dart       # App theme and colors
│   ├── data/
│   │   ├── models.dart      # Data models (SugarLog, Meal, etc.)
│   │   └── local_storage.dart # Local data persistence
│   ├── routing/
│   │   └── routes.dart      # Navigation and routing
│   ├── widgets/
│   │   └── app_navbar.dart  # Bottom navigation bar
│   └── features/
│       ├── onboarding/      # Onboarding screens
│       ├── auth/           # Authentication (login/signup)
│       ├── shell/          # Main app container
│       ├── home/           # Dashboard and overview
│       ├── meals/          # Meal planning and nutrition
│       ├── exercise/       # Workout tracking
│       ├── community/      # Social features
│       └── profile/        # User settings
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/diabecheck.git
   cd diabecheck
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS App:**
```bash
flutter build ios --release
```

## 🎨 Design System

### Color Palette
- **Primary Blue**: `#2E86DE` - Trustworthy medical blue
- **Secondary Blue**: `#63C1FF` - Light accent blue
- **Background**: `#F7FBFF` - Very light blue for clean feel
- **Text Primary**: `#1E2A3A` - Dark blue-gray for readability
- **Text Secondary**: `#6B7C93` - Medium gray for less important text

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Design System**: Material 3
- **Accessibility**: High contrast ratios for medical app standards

### UI Components
- **Cards**: Rounded corners (20px radius), no elevation for flat design
- **Navigation**: Floating bottom bar with shadows
- **Buttons**: Material 3 design with custom colors
- **Forms**: Rounded input fields with proper validation

## 📱 Screenshots

### Home Dashboard
- Health metrics overview
- Quick action buttons
- Recent activity summary

### Meals Screen
- Trending meals carousel
- Meal type filtering
- Nutritional information display
- Search functionality

### Exercise Screen
- Exercise categories
- Recommended workouts
- Calorie burn tracking
- Difficulty levels

## 🔧 Technical Details

### Architecture
- **State Management**: Flutter StatefulWidget
- **Navigation**: Material Page Routes
- **Local Storage**: SharedPreferences
- **Data Models**: Custom Dart classes with JSON serialization

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^4.0.5
  shared_preferences: ^2.2.2
  crystal_navigation_bar: ^0.0.1
```

### Key Features Implementation
- **Responsive Design**: Adapts to different screen sizes
- **Local Data Persistence**: All health data stored locally
- **Modern UI**: Material 3 design with custom theming
- **Accessibility**: High contrast and readable fonts
- **Performance**: Optimized for smooth scrolling and animations

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/
```

### Test Coverage
- Unit tests for data models
- Widget tests for UI components
- Integration tests for user flows

## 📈 Future Enhancements

### Planned Features
- [ ] **Cloud Sync**: Backup data to cloud storage
- [ ] **Notifications**: Reminders for medication and meals
- [ ] **Health Integration**: Connect with health apps (Apple Health, Google Fit)
- [ ] **AI Recommendations**: Smart meal and exercise suggestions
- [ ] **Doctor Integration**: Share data with healthcare providers
- [ ] **Multi-language Support**: Internationalization
- [ ] **Dark Mode**: Theme switching capability
- [ ] **Offline Mode**: Full functionality without internet

### Technical Improvements
- [ ] **State Management**: Implement Provider or Bloc
- [ ] **API Integration**: Connect to backend services
- [ ] **Database**: SQLite for complex queries
- [ ] **Testing**: Increase test coverage
- [ ] **Performance**: Optimize for large datasets

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Contribution Guidelines
- Follow the existing code style
- Add comments for new features
- Write tests for new functionality
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Development Team**: Diabecheck Development Team
- **Design**: Material Design 3 guidelines
- **Medical Consultation**: Healthcare professionals

## 📞 Support

For support, email support@diabecheck.com or join our community discussions.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Open source community for inspiration
- Healthcare professionals for medical guidance

---

**Made with ❤️ for the diabetes community**

*This app is designed to assist with diabetes management but should not replace professional medical advice. Always consult with healthcare providers for medical decisions.*