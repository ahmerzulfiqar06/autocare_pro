#!/bin/bash

# AutoCare Pro Deployment Script
echo "🚗 AutoCare Pro Deployment Script"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

print_status "Flutter found: $(flutter --version | head -1)"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep -oP 'Flutter \K[^\s]+')
REQUIRED_VERSION="3.19.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$FLUTTER_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_warning "Recommended Flutter version is $REQUIRED_VERSION, you have $FLUTTER_VERSION"
fi

# Install dependencies
print_status "Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    print_error "Failed to install dependencies"
    exit 1
fi

# Build web version
print_status "Building web version..."
flutter build web --release

if [ $? -ne 0 ]; then
    print_error "Failed to build web version"
    exit 1
fi

print_status "Web build completed successfully!"
print_status "Build output available in: build/web/"

# Deployment options
echo ""
echo "🌐 Deployment Options:"
echo "===================="
echo "1. Firebase Hosting (Recommended)"
echo "2. GitHub Pages"
echo "3. Netlify"
echo "4. Vercel"
echo "5. Manual hosting"
echo ""

read -p "Choose deployment option (1-5): " choice

case $choice in
    1)
        echo "🚀 Deploying to Firebase Hosting..."
        if command -v firebase &> /dev/null; then
            firebase deploy --only hosting
            print_status "Deployed to Firebase! Check your Firebase console for the live URL."
        else
            print_error "Firebase CLI not installed. Install it with: npm install -g firebase-tools"
            echo "Then run: firebase login && firebase init hosting && firebase deploy"
        fi
        ;;
    2)
        print_status "GitHub Pages deployment:"
        echo "1. Push your code to GitHub"
        echo "2. Enable Pages in repository settings"
        echo "3. Set source to 'GitHub Actions'"
        echo "4. Your app will be available at: https://yourusername.github.io/your-repo-name/"
        ;;
    3)
        print_status "Netlify deployment:"
        echo "1. Build command: flutter build web --release"
        echo "2. Publish directory: build/web"
        echo "3. Drag and drop the build/web folder to Netlify"
        echo "4. Or connect your GitHub repository for automatic deployment"
        ;;
    4)
        print_status "Vercel deployment:"
        echo "1. Install Vercel CLI: npm install -g vercel"
        echo "2. Run: vercel --prod"
        echo "3. Set build command: flutter build web --release"
        echo "4. Output directory: build/web"
        ;;
    5)
        print_status "Manual hosting:"
        echo "1. Upload the contents of build/web/ to your web server"
        echo "2. Make sure all files are served with correct MIME types"
        echo "3. Enable HTTPS for production use"
        ;;
    *)
        print_error "Invalid option selected"
        exit 1
        ;;
esac

print_status "Deployment script completed!"
echo ""
echo "📱 Next Steps:"
echo "============="
echo "• Test your app thoroughly"
echo "• Consider setting up Firebase for backend features"
echo "• Prepare app store listings if deploying to mobile"
echo "• Set up analytics and monitoring"
echo "• Create a marketing plan"
