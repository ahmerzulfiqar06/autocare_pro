# 🚀 AutoCare Pro - Setup & Testing Guide

## 📋 Prerequisites

### 1. Flutter SDK Installation

#### Windows Setup:
```bash
# Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
# Extract to: C:\flutter\

# Add to PATH:
# 1. Open Environment Variables
# 2. Add: C:\flutter\bin to Path
# 3. Restart terminal/command prompt

# Verify installation:
flutter doctor
```

#### Android Studio Setup:
1. Download Android Studio: https://developer.android.com/studio
2. Install Android SDK
3. Enable Developer Options on Android device
4. Enable USB Debugging

### 2. GitHub Repository
✅ **Already Set Up**: https://github.com/ahmerzulfiqar06/AutoCare-Pro---Smart-Vehicle-Maintenance-Tracker

## 🧪 Local Testing

### Step 1: Clone Repository
```bash
git clone https://github.com/ahmerzulfiqar06/AutoCare-Pro---Smart-Vehicle-Maintenance-Tracker.git
cd "AutoCare Pro - Smart Vehicle Maintenance Tracker"
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Check Setup
```bash
flutter doctor
```

### Step 4: Run on Android Device/Emulator
```bash
# Connect Android device or start emulator
flutter devices

# Run the app
flutter run
```

### Step 5: Run on iOS Simulator (macOS only)
```bash
# Open iOS Simulator
open -a Simulator

# Run on iOS
flutter run -d ios
```

## 📱 Testing Checklist

### ✅ Core Features to Test:
- [ ] **Dashboard**: Welcome message, stats cards, quick actions
- [ ] **Vehicle Management**:
  - [ ] Add new vehicle (all fields required)
  - [ ] View vehicle list (grid/list toggle)
  - [ ] Search vehicles by make/model
  - [ ] Edit vehicle details
  - [ ] Delete vehicle with confirmation
- [ ] **Theme**: Dark/Light mode toggle
- [ ] **Navigation**: Smooth transitions between screens

### 🐛 Common Issues & Solutions:

#### Issue: "flutter command not found"
**Solution**: Add Flutter to PATH environment variable

#### Issue: "No connected devices"
**Solution**:
```bash
# Start Android emulator
flutter emulators
flutter emulators --launch <emulator_name>

# Or connect physical device and enable USB debugging
```

#### Issue: "Android SDK not found"
**Solution**: Install Android Studio and set ANDROID_HOME

#### Issue: Build fails
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

## 🌐 Hosting & Deployment

### Option 1: Google Play Store (Android)

#### Step 1: Build Release APK
```bash
# Clean and build
flutter clean
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

#### Step 2: Generate Signed APK (Production)
```bash
# Create keystore (first time only)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure signing in android/app/build.gradle
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

# Build signed APK
flutter build apk --release
```

#### Step 3: Upload to Play Store
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or update existing
3. Upload APK to "Production" track
4. Fill app details, screenshots, description
5. Publish to production

### Option 2: Apple App Store (iOS)

#### Step 1: iOS Setup
```bash
# Install CocoaPods (macOS)
sudo gem install cocoapods

# Clean and build
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

#### Step 2: Build for iOS
```bash
flutter build ios --release
```

#### Step 3: Archive in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Upload to App Store Connect

#### Step 4: Submit to App Store
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Create new version
4. Upload build from Xcode
5. Fill app information and screenshots
6. Submit for review

### Option 3: Web Deployment (Optional)

#### Step 1: Enable Web Support
```bash
flutter config --enable-web
```

#### Step 2: Build for Web
```bash
flutter build web --release
```

#### Step 3: Deploy Options

**Firebase Hosting:**
```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Initialize Firebase
firebase init hosting

# Deploy
firebase deploy
```

**GitHub Pages:**
```bash
# Install gh-pages
npm install -g gh-pages

# Deploy
gh-pages -d build/web
```

**Netlify:**
1. Drag and drop `build/web` folder to Netlify dashboard
2. Set build command: `flutter build web --release`

## 🔧 Development Commands

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Analysis
```bash
# Check code formatting
flutter format lib/

# Analyze code
flutter analyze

# Fix common issues
dart fix --apply
```

### Build Commands
```bash
# Debug build
flutter build apk
flutter build ios

# Release build
flutter build apk --release
flutter build ios --release

# App Bundle (Android)
flutter build appbundle --release
```

## 📊 Performance Testing

### Profile Mode
```bash
flutter run --profile
```

### Observatory
```bash
flutter run --observatory-port=8888
```

## 🐛 Troubleshooting

### Common Flutter Issues:

#### 1. Gradle Build Issues
```bash
cd android
./gradlew clean
./gradlew build
cd ..
flutter clean
flutter pub get
```

#### 2. iOS Build Issues
```bash
cd ios
rm -rf Pods/
rm Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

#### 3. Cache Issues
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

#### 4. Device Connection Issues
```bash
flutter devices
adb devices  # For Android
```

## 📞 Support

If you encounter issues:

1. Check `flutter doctor` output
2. Review error logs carefully
3. Search Flutter documentation: https://flutter.dev/docs
4. Check GitHub issues: https://github.com/flutter/flutter/issues
5. Community forums: https://flutter.dev/community

## 🎯 Next Steps

After successful testing, you can:

1. **Add More Features**: Service management, notifications, analytics
2. **UI Improvements**: Animations, custom themes, icons
3. **Testing**: Unit tests, integration tests, widget tests
4. **CI/CD**: GitHub Actions, automated testing
5. **Documentation**: API docs, user guides

---

**Happy Coding! 🚀**

*Built with ❤️ using Flutter*
