# 🚗 AutoCare Pro - Smart Vehicle Maintenance Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-3.0+-003B57?logo=sqlite&logoColor=white)](https://sqlite.org)
[![Material Design](https://img.shields.io/badge/Material%20Design-3-757575?logo=material-design&logoColor=white)](https://material.io/design)

A professional, cross-platform Flutter mobile application for smart vehicle maintenance tracking. Built with modern architecture patterns and Material Design 3.

## 📱 Screenshots

| Dashboard | Vehicle List | Add Vehicle |
|-----------|-------------|-------------|
| ![Dashboard](screenshots/dashboard.png) | ![Vehicle List](screenshots/vehicle_list.png) | ![Add Vehicle](screenshots/add_vehicle.png) |

## ✨ Features

### 🏢 Core Features
- **Vehicle Management**: Add, edit, delete multiple vehicles with detailed specs
- **Maintenance Scheduling**: Pre-defined and custom service schedules
- **Service Records**: Digital receipt scanning with camera integration
- **Analytics & Reports**: Cost trends, service frequency analysis
- **Dark/Light Theme**: Automatic theme switching with user preference
- **Offline Functionality**: Full offline capability with data sync
- **Data Backup & Restore**: Secure data export/import functionality

### 🚗 Vehicle Management
- Support for cars, motorcycles, trucks
- Detailed vehicle specifications (make, model, year, VIN, mileage)
- Vehicle photos and custom notes
- Vehicle status tracking (active, sold, serviced)
- Mileage tracking and updates

### 🛠️ Service Management
- Pre-defined service schedules (oil changes, tire rotations, inspections)
- Custom maintenance reminders
- Mileage-based and date-based notifications
- Service history with costs and dates
- Mechanic contact information storage

### 📊 Analytics & Reporting
- Maintenance cost trends over time
- Service frequency analysis
- Upcoming service predictions
- Exportable maintenance reports
- Visual charts and graphs

### 🔧 Additional Features
- **Multi-language Support**: English and Spanish
- **Cross-platform**: iOS & Android compatibility
- **Material Design 3**: Modern UI components
- **Local Notifications**: Maintenance reminders
- **Camera Integration**: Receipt scanning
- **Data Encryption**: Secure local storage

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/          # App constants and configurations
│   ├── theme/             # Material Design 3 theme setup
│   ├── utils/             # Helper functions and utilities
│   └── widgets/           # Reusable UI components
├── data/
│   ├── models/            # Data models (Vehicle, Service, etc.)
│   ├── repositories/      # Repository pattern implementation
│   └── services/          # Database and API services
├── presentation/
│   ├── screens/           # App screens and pages
│   ├── widgets/           # Screen-specific widgets
│   └── providers/         # State management providers
├── config/
│   └── routes.dart        # App routing configuration
└── main.dart              # App entry point
```

### 🏛️ Design Patterns
- **MVVM Architecture**: Model-View-ViewModel pattern
- **Repository Pattern**: Data abstraction layer
- **Provider Pattern**: State management
- **Clean Architecture**: Separation of concerns
- **Dependency Injection**: GetIt/Provider injection

## 🛠️ Technology Stack

### Core Technologies
- **Flutter 3.19+**: Cross-platform framework
- **Dart 3.0+**: Programming language
- **SQLite**: Local database
- **Provider**: State management

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.5

  # Database
  sqflite: ^2.3.0
  path: ^1.8.3

  # Local Storage
  shared_preferences: ^2.2.2

  # Notifications
  flutter_local_notifications: ^16.3.2
  timezone: ^0.9.2

  # Camera & Image
  image_picker: ^1.0.4

  # Charts & Analytics
  fl_chart: ^0.66.1

  # UI & Utilities
  google_fonts: ^6.1.0
  intl: ^0.19.0
  uuid: ^4.2.1

  cupertino_icons: ^1.0.2
```

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.19.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development on macOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/autocare_pro.git
   cd autocare_pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   flutter run --device-id=<device_id>

   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

### 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run tests with coverage
flutter test --coverage
```

### 📦 Building for Production

#### Android APK
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

#### Android App Bundle (AAB)
```bash
flutter build appbundle --release
```

#### iOS
```bash
# Build for iOS (macOS only)
flutter build ios --release

# Archive for App Store
flutter build ios --release --no-codesign
```

## 📱 Platform-Specific Setup

### Android Setup
1. **Minimum SDK**: API 21 (Android 5.0)
2. **Target SDK**: API 34 (Android 14)
3. **Permissions** in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   ```

### iOS Setup
1. **Minimum iOS Version**: 12.0
2. **Permissions** in `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Camera access for scanning receipts</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Photo library access for vehicle photos</string>
   ```

## 🌐 Deployment & Distribution

### 📤 Google Play Store

#### 1. Prepare Release Build
```bash
# Clean and build release
flutter clean
flutter build appbundle --release
```

#### 2. Generate Signing Key (if not exists)
```bash
# Create keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Move to android/app/
mv ~/upload-keystore.jks android/app/
```

#### 3. Configure Signing in `android/app/build.gradle`
```gradle
android {
    signingConfigs {
        release {
            keyAlias 'upload'
            keyPassword 'your_key_password'
            storeFile file('upload-keystore.jks')
            storePassword 'your_store_password'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 4. Upload to Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or update existing
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Fill app details, screenshots, descriptions
5. Set pricing and distribution
6. Publish to production

### 🍎 Apple App Store

#### 1. Prepare iOS Build
```bash
# Clean and build
flutter clean
flutter build ios --release --no-codesign

# Open Xcode project
open ios/Runner.xcworkspace
```

#### 2. Configure App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Generate Bundle ID: `com.yourcompany.autocarepro`

#### 3. Archive in Xcode
1. **Product** → **Archive**
2. Wait for archive to complete
3. **Window** → **Organizer** → **Archives**
4. Select latest archive → **Distribute App**
5. Choose **App Store Connect** → **Upload**

#### 4. Submit for Review
1. In App Store Connect, select your app
2. **App Store** → **Prepare for Submission**
3. Fill app information, screenshots, descriptions
4. Submit for review

### 🌐 Web Deployment (Optional)

#### 1. Enable Web Support
```bash
flutter config --enable-web
```

#### 2. Build for Web
```bash
flutter build web --release
```

#### 3. Deploy to Hosting
```bash
# Firebase Hosting
firebase init hosting
firebase deploy

# GitHub Pages
# Copy build/web contents to docs/ or gh-pages branch

# Netlify
# Drag and drop build/web folder to Netlify dashboard
```

## 🔧 Configuration

### Environment Variables
Create `.env` file in root directory:
```env
# Database
DATABASE_NAME=autocare_pro.db

# API Keys (if needed)
GOOGLE_MAPS_API_KEY=your_api_key

# App Configuration
APP_ENV=development
DEBUG=true
```

### Firebase Configuration (Optional)
For cloud backup features:
1. Create Firebase project
2. Enable Authentication and Firestore
3. Add `google-services.json` to `android/app/`
4. Add `GoogleService-Info.plist` to `ios/Runner/`

## 📊 Database Schema

### Vehicles Table
```sql
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  vin TEXT,
  license_plate TEXT,
  current_mileage INTEGER NOT NULL,
  purchase_date TEXT,
  photo_path TEXT,
  status INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### Services Table
```sql
CREATE TABLE services (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL,
  service_type TEXT NOT NULL,
  service_date TEXT NOT NULL,
  mileage_at_service INTEGER NOT NULL,
  cost REAL NOT NULL,
  notes TEXT,
  receipt_path TEXT,
  mechanic_info TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
);
```

### Service Schedules Table
```sql
CREATE TABLE service_schedules (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL,
  service_type TEXT NOT NULL,
  interval_miles INTEGER NOT NULL,
  interval_months INTEGER NOT NULL,
  last_service_date TEXT NOT NULL,
  last_service_mileage INTEGER NOT NULL,
  next_service_date TEXT NOT NULL,
  next_service_mileage INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
);
```

## 🧪 Testing Strategy

### Unit Tests
```dart
// Example test
void main() {
  test('Vehicle model test', () {
    final vehicle = Vehicle(
      make: 'Toyota',
      model: 'Camry',
      year: 2020,
      currentMileage: 50000,
    );

    expect(vehicle.make, 'Toyota');
    expect(vehicle.displayName, '2020 Toyota Camry');
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('Dashboard shows welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoCareProApp());

    expect(find.text('Welcome to AutoCare Pro'), findsOneWidget);
  });
}
```

### Integration Tests
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoCareProApp());

    // Test full user flow
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
  });
}
```

## 🔒 Security & Privacy

### Data Security
- **Local Encryption**: Sensitive data encrypted using Flutter Secure Storage
- **No Cloud Storage**: All data stored locally on device
- **Permission-Based**: Camera and storage access only when needed

### Privacy Compliance
- **GDPR Compliant**: No personal data collection
- **Minimal Permissions**: Only required permissions requested
- **Data Export**: Users can export their data anytime

## 🚀 Performance Optimization

### Build Optimization
```yaml
# pubspec.yaml
flutter:
  uses-material-design: true

  # Enable build optimization
  build:
    preview: true
  ```

### Runtime Optimization
- **Lazy Loading**: Implement pagination for large lists
- **Image Optimization**: Compress images before storage
- **Memory Management**: Proper disposal of resources
- **Background Tasks**: Efficient notification scheduling

## 📈 Monitoring & Analytics

### Firebase Analytics (Optional)
```dart
// Add to pubspec.yaml
firebase_analytics: ^10.4.0

// Usage
await FirebaseAnalytics.instance.logEvent(
  name: 'vehicle_added',
  parameters: {'make': vehicle.make},
);
```

### Crash Reporting
```dart
// Firebase Crashlytics
firebase_crashlytics: ^3.3.0

// Usage
FirebaseCrashlytics.instance.recordError(error, stackTrace);
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
```bash
# Run linting
flutter analyze

# Format code
dart format lib/

# Run tests before committing
flutter test
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- SQLite for reliable local storage
- All contributors and users

## 📞 Support

For support, email support@autocarepro.com or join our Discord community.

---

**Built with ❤️ using Flutter**

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
