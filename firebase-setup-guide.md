# 🚀 Firebase Setup Guide for AutoCare Pro

This guide will help you set up Firebase for your AutoCare Pro app to enable cloud features and hosting.

## 📋 Prerequisites

- Node.js installed (for Firebase CLI)
- Flutter SDK >=3.19.0
- Google account

## 🛠️ Step 1: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version
```

## 🔐 Step 2: Sign in to Firebase

```bash
# Login to your Google account
firebase login
```

This will open your browser to authenticate with Google.

## 🎯 Step 3: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: **AutoCare Pro**
4. Choose your Google Analytics settings (recommended)
5. Click "Create project"

## 🌐 Step 4: Set Up Hosting

```bash
# Initialize Firebase in your project
firebase init hosting

# Select options:
# 1. Use existing project
# 2. Select your AutoCare Pro project
# 3. Choose your hosting options:
#    - What do you want to use as your public directory? (public)
#    - Configure as a single-page app? (y/N) → N (Flutter handles routing)
#    - Set up automatic builds and deploys? (y/N) → N (for now)
```

## ⚙️ Step 5: Configure Hosting Settings

Edit `firebase.json` in your project root:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|ico)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

## 📱 Step 6: Optional - Add Mobile App Support

If you want to add cloud features to your mobile app:

### For Android:
1. In Firebase Console, add an Android app
2. Download `google-services.json`
3. Place it in `android/app/google-services.json`

### For iOS:
1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`

## 🚀 Step 7: Deploy Your App

```bash
# Build your Flutter web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy
```

## 🎉 Step 8: View Your Live App

After deployment, Firebase will provide you with a live URL like:
`https://your-project-id.web.app`

## 🔧 Optional: Add Firebase Services

### Analytics
```bash
firebase init analytics
```

### Authentication
```bash
firebase init auth
```

### Firestore (for cloud backup)
```bash
firebase init firestore
```

## 🧪 Testing Your Deployment

1. Open your live URL
2. Test adding a vehicle
3. Test adding a service record
4. Check if data persists (it should work with local SQLite)
5. Test on different devices and browsers

## 🔍 Troubleshooting

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### Deployment Issues
```bash
# Check Firebase status
firebase status

# Redeploy
firebase deploy --only hosting
```

### CORS Issues
If you encounter CORS issues, ensure your `firebase.json` has proper headers configured.

## 📞 Support

- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire: https://firebase.flutter.dev/
- AutoCare Pro Issues: [GitHub Issues](https://github.com/yourusername/autocare_pro/issues)

## 🎯 Next Steps

After Firebase setup:

1. ✅ **Test your live app thoroughly**
2. ⏭️ **Set up domain name** (optional)
3. ⏭️ **Add SSL certificate** (automatic with Firebase)
4. ⏭️ **Configure analytics** to track usage
5. ⏭️ **Prepare for app store submissions**

Your AutoCare Pro app is now live! 🚗✨
