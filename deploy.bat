@echo off
REM AutoCare Pro Deployment Script for Windows
echo 🚗 AutoCare Pro Deployment Script
echo =================================
echo.

REM Colors for output (Windows CMD doesn't support colors easily, so we'll use symbols)
echo [INFO] Checking Flutter installation...

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [INFO] Flutter found
echo [INFO] Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)

echo [INFO] Building web version...
flutter build web --release
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build web version
    pause
    exit /b 1
)

echo [INFO] Web build completed successfully!
echo [INFO] Build output available in: build/web/
echo.

echo 🌐 Deployment Options:
echo ====================
echo 1. Firebase Hosting (Recommended)
echo 2. GitHub Pages
echo 3. Netlify
echo 4. Vercel
echo 5. Manual hosting
echo.

set /p choice="Choose deployment option (1-5): "

if "%choice%"=="1" (
    echo 🚀 Deploying to Firebase Hosting...
    where firebase >nul 2>nul
    if %errorlevel% neq 0 (
        echo [ERROR] Firebase CLI not installed. Install it with: npm install -g firebase-tools
        echo Then run: firebase login ^&^& firebase init hosting ^&^& firebase deploy
    ) else (
        firebase deploy --only hosting
        echo [INFO] Deployed to Firebase! Check your Firebase console for the live URL.
    )
) else if "%choice%"=="2" (
    echo [INFO] GitHub Pages deployment:
    echo 1. Push your code to GitHub
    echo 2. Enable Pages in repository settings
    echo 3. Set source to 'GitHub Actions'
    echo 4. Your app will be available at: https://yourusername.github.io/your-repo-name/
) else if "%choice%"=="3" (
    echo [INFO] Netlify deployment:
    echo 1. Build command: flutter build web --release
    echo 2. Publish directory: build/web
    echo 3. Drag and drop the build/web folder to Netlify
    echo 4. Or connect your GitHub repository for automatic deployment
) else if "%choice%"=="4" (
    echo [INFO] Vercel deployment:
    echo 1. Install Vercel CLI: npm install -g vercel
    echo 2. Run: vercel --prod
    echo 3. Set build command: flutter build web --release
    echo 4. Output directory: build/web
) else if "%choice%"=="5" (
    echo [INFO] Manual hosting:
    echo 1. Upload the contents of build/web/ to your web server
    echo 2. Make sure all files are served with correct MIME types
    echo 3. Enable HTTPS for production use
) else (
    echo [ERROR] Invalid option selected
    pause
    exit /b 1
)

echo.
echo [INFO] Deployment script completed!
echo.
echo 📱 Next Steps:
echo =============
echo • Test your app thoroughly
echo • Consider setting up Firebase for backend features
echo • Prepare app store listings if deploying to mobile
echo • Set up analytics and monitoring
echo • Create a marketing plan
echo.
pause
