@echo off
REM Quick Deploy Script for AutoCare Pro
echo 🚗 AutoCare Pro - Quick Deployment
echo ==================================
echo.

echo [INFO] This script will help you get AutoCare Pro live quickly!
echo.

REM Check prerequisites
echo [INFO] Checking prerequisites...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found. Please install Flutter first.
    echo Download from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found. Please install Node.js first.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

echo [INFO] Prerequisites OK ✓
echo.

REM Install dependencies
echo [INFO] Installing Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)

echo [INFO] Dependencies installed ✓
echo.

REM Build web version
echo [INFO] Building web version...
flutter build web --release
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build web version
    pause
    exit /b 1
)

echo [INFO] Web build completed ✓
echo [INFO] Build files: build/web/
echo.

REM Check if Firebase CLI is installed
echo [INFO] Checking Firebase CLI...
where firebase >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Firebase CLI not installed. Installing...
    npm install -g firebase-tools
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Firebase CLI
        echo Please install manually: npm install -g firebase-tools
        pause
        exit /b 1
    )
)

echo [INFO] Firebase CLI installed ✓
echo.

REM Firebase login
echo [INFO] Please login to Firebase (this will open your browser)...
firebase login
echo.

REM Initialize hosting
echo [INFO] Initializing Firebase hosting...
firebase init hosting --yes
echo.

REM Configure firebase.json
echo [INFO] Configuring Firebase hosting settings...
if exist firebase.json (
    echo [INFO] Firebase config already exists
) else (
    echo { > firebase.json
    echo   "hosting": { >> firebase.json
    echo     "public": "build/web", >> firebase.json
    echo     "ignore": [ >> firebase.json
    echo       "firebase.json", >> firebase.json
    echo       "**/.*", >> firebase.json
    echo       "**/node_modules/**" >> firebase.json
    echo     ], >> firebase.json
    echo     "rewrites": [ >> firebase.json
    echo       { >> firebase.json
    echo         "source": "**", >> firebase.json
    echo         "destination": "/index.html" >> firebase.json
    echo       } >> firebase.json
    echo     ] >> firebase.json
    echo   } >> firebase.json
    echo } >> firebase.json
)

echo [INFO] Firebase configuration updated ✓
echo.

REM Deploy
echo [INFO] Deploying to Firebase Hosting...
firebase deploy --only hosting
if %errorlevel% neq 0 (
    echo [ERROR] Deployment failed
    pause
    exit /b 1
)

echo.
echo 🎉 SUCCESS! Your AutoCare Pro app is now live!
echo.
echo Next steps:
echo 1. Test your app at the provided Firebase URL
echo 2. Customize the app branding and colors
echo 3. Add more features as needed
echo 4. Set up a custom domain (optional)
echo 5. Prepare for app store submissions
echo.
echo 📚 For more detailed instructions, see:
echo    - README.md
echo    - firebase-setup-guide.md
echo.
pause
