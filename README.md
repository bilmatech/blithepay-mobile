# BLITHE - School Fee Management Flutter App

A production-ready Flutter application for managing school fees with secure authentication, dashboard analytics, and student management features.

## Features

- **Authentication System**
  - User registration and login
  - Password recovery and reset
  - OTP verification
  - Secure credential storage

- **Dashboard**
  - Financial summary with outstanding fees
  - Wallet balance tracking
  - Recent transactions history
  - Quick action buttons

- **School Management**
  - Search and add schools
  - School information verification
  - Multiple school support

- **Student Management**
  - Link multiple students
  - Guardian verification
  - Student information tracking

- **Profile Management**
  - Phone number updates
  - Profile information editing

- **UI/UX**
  - Shimmer loaders for data loading states
  - Smooth animations and transitions
  - Dark and light theme support
  - Responsive design

## Architecture

Built with **Clean Architecture** and **BLoC** state management:

```
lib/
├── core/              # Core functionality
│   ├── config/       # App configuration
│   ├── constants/    # App constants and styling
│   ├── navigation/   # Routing configuration
│   ├── network/      # API client setup
│   ├── storage/      # Local storage services
│   ├── theme/        # Theme management
│   └── utils/        # Helpers and validators
├── features/         # Feature modules
│   ├── auth/         # Authentication
│   ├── dashboard/    # Main dashboard
│   ├── schools/      # School management
│   ├── students/     # Student management
│   ├── profile/      # User profile
│   ├── splash/       # Splash screen
│   └── common/       # Shared feature screens
└── shared/           # Shared widgets and layouts
    ├── widgets/      # Reusable components
    └── layouts/      # Layout templates
```

## Getting Started

### Prerequisites

- Flutter 3.0.0 or higher
- Dart 3.0.0 or higher
- iOS 11.0+ or Android API level 23+

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure splash screen and app icons:
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Key Dependencies

- **flutter_bloc (^9.0.0)** - State management
- **dio (^5.3.1)** - HTTP client
- **go_router (^12.0.0)** - Navigation
- **shimmer (^3.0.0)** - Shimmer loading effects
- **flutter_secure_storage (^9.0.0)** - Secure storage
- **hive (^2.2.3)** - Local data storage
- **flutter_launcher_icons (^0.13.1)** - App icons
- **flutter_native_splash (^2.3.7)** - Splash screen

## Configuration

### Splash Screen
The splash screen is configured in `pubspec.yaml` with the primary app color (#0A1628). Customize by updating the `flutter_native_splash` section.

### App Icons
App icons are generated from `assets/images/app_icon.png`. Update this image and run:
```bash
dart run flutter_launcher_icons
```

### Theme
Customize the app theme in:
- `lib/core/constants/app_colors.dart` - Color palette
- `lib/core/theme/light_theme.dart` - Light theme
- `lib/core/theme/dark_theme.dart` - Dark theme

## API Integration

The app uses mock data by default. To integrate with a real API:

1. Update endpoints in `lib/core/network/api_endpoints.dart`
2. Modify the repository classes in `lib/features/*/data/repositories/`
3. Update BLoC logic to use real API calls instead of mock data

## Testing

Run tests with:
```bash
flutter test
```

## Build & Release

### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Project Structure Notes

- **Models**: Located in `data/models/` for data layer models
- **Repositories**: Implement business logic and API calls
- **BLoCs**: Handle state management and event processing
- **Views**: UI screens with widgets
- **Widgets**: Reusable UI components in `shared/widgets/`

## Loading States

All data-loading sections include shimmer loaders:
- Dashboard summary card
- Transaction lists
- Form fields
- List items

Customize shimmer appearance by modifying color values in `ShimmerWidget`.

## Support

For issues or questions, please open an issue in the repository.

## License

This project is proprietary software for BÜTHE School Fee Management.
