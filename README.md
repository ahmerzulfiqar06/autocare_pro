# 🚗 AutoCare Pro - Smart Vehicle Maintenance Tracker

A comprehensive mobile and web application for tracking vehicle maintenance, services, and expenses. Built with Flutter for cross-platform compatibility.

## 📱 About AutoCare Pro

AutoCare Pro is your personal vehicle maintenance companion that helps you:

- **Track Multiple Vehicles**: Manage maintenance records for all your vehicles in one place
- **Service History**: Keep detailed records of all services, costs, and receipts
- **Maintenance Reminders**: Get notified about upcoming maintenance schedules
- **Analytics & Insights**: Visualize your maintenance costs and patterns
- **Cost Management**: Track and analyze your vehicle maintenance expenses
- **Photo Documentation**: Store photos of your vehicles and service receipts

## ✨ Features

### Core Features
- 🚗 Multi-vehicle management
- 🔧 Comprehensive service tracking (oil changes, tire rotations, brakes, etc.)
- 💰 Cost tracking and analytics
- 📊 Visual dashboards and insights
- 📱 Cross-platform support (iOS, Android, Web)
- 🎨 Modern, intuitive UI with dark/light theme support
- 🔍 Advanced search functionality
- 📸 Photo capture and storage

### Technical Features
- **Offline-First**: Works without internet connection
- **Local Database**: SQLite for reliable data storage
- **State Management**: Provider pattern for reactive UI
- **Material Design 3**: Modern design system
- **PWA Ready**: Installable web app
- **Push Notifications**: Local reminders for maintenance schedules

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (>=3.19.0)
- Dart SDK (>=3.0.0)
- Android Studio (for Android builds)
- Xcode (for iOS builds) - macOS only

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd autocare_pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For web (quickest to test)
   flutter run -d chrome

   # For Android
   flutter run -d android

   # For iOS
   flutter run -d ios
   ```

## 🌐 Deployment Options

### Option 1: Web Deployment (Quickest - 5 minutes)

#### Firebase Hosting (Recommended)
1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize hosting:
   ```bash
   firebase init hosting
   ```

4. Build and deploy:
   ```bash
   flutter build web --release
   firebase deploy
   ```

#### GitHub Pages (Alternative)
```bash
# Build the web app
flutter build web --release --base-href "/your-repo-name/"

# Deploy to GitHub Pages
# Use GitHub Actions or manually copy to gh-pages branch
```

#### GitHub Actions (Automated - Recommended)
1. Push your code to GitHub
2. Enable GitHub Actions in repository settings
3. Add Firebase service account key to repository secrets
4. Every push to main branch will automatically deploy to Firebase Hosting

### Option 2: Mobile App Stores

#### Android (Google Play Store)
1. Build APK/AAB:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

2. Create Google Play Console account
3. Upload your app bundle
4. Fill in store listing details
5. Submit for review

#### iOS (App Store)
1. Build for iOS:
   ```bash
   flutter build ios --release
   ```

2. Create Apple Developer account
3. Use Xcode to create App Store Connect record
4. Upload using Transporter
5. Submit for review

## 🏗️ Project Structure

```
lib/
├── core/                 # Core utilities and constants
│   ├── constants/        # App constants
│   ├── theme/           # Theme configurations
│   ├── utils/           # Helper functions
│   └── widgets/         # Reusable widgets
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Data repositories
│   └── services/        # Services (database, camera, etc.)
├── presentation/        # UI layer
│   ├── providers/       # State management providers
│   ├── screens/         # App screens
│   └── widgets/         # UI widgets
└── main.dart            # App entry point
```

## 📊 Key Models

- **Vehicle**: Car information, mileage, photos, status
- **Service**: Maintenance records, costs, types, receipts
- **ServiceSchedule**: Upcoming maintenance reminders

## 🎨 Customization

### Themes
The app supports both light and dark themes. Customize in `lib/core/theme/app_theme.dart`.

### Adding New Service Types
1. Update `ServiceType` enum in `lib/data/models/service.dart`
2. Add corresponding UI in service-related screens

### Localization
Ready for internationalization - add `.arb` files in `lib/l10n/`.

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📧 Email: support@autocarepro.com
- 📖 Documentation: [docs.autocarepro.com](https://docs.autocarepro.com)
- 🐛 Bug Reports: [GitHub Issues](https://github.com/yourusername/autocare_pro/issues)

## 🎯 Roadmap

- [ ] Cloud sync and backup
- [ ] Advanced analytics with charts
- [ ] Vehicle comparison features
- [ ] Integration with car diagnostic tools
- [ ] Social features (share maintenance tips)
- [ ] Multi-language support
- [ ] Offline-first improvements

---

**Made with ❤️ for car enthusiasts everywhere**

*Keep your vehicles running smoothly with AutoCare Pro!*
