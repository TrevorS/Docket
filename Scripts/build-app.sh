#!/bin/bash
# ABOUTME: Build script for creating a distributable macOS .app bundle
# ABOUTME: Handles release build, app bundle creation, and basic code signing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="Docket"

echo "🔨 Building $APP_NAME for macOS..."

# Clean and build for release
cd "$PROJECT_DIR"
swift package clean
swift build --configuration release

# Create app bundle structure
echo "📦 Creating app bundle..."
rm -rf "$BUILD_DIR/$APP_NAME.app"
mkdir -p "$BUILD_DIR/$APP_NAME.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/$APP_NAME.app/Contents/Resources"

# Copy executable
cp ".build/release/$APP_NAME" "$BUILD_DIR/$APP_NAME.app/Contents/MacOS/"

# Copy Info.plist
cp "Sources/DocketApp/Resources/Info.plist" "$BUILD_DIR/$APP_NAME.app/Contents/"

# Copy entitlements for reference
cp "Sources/DocketApp/Resources/Docket.entitlements" "$BUILD_DIR/$APP_NAME.app/Contents/Resources/"

# Copy assets if they exist
if [ -d "Sources/DocketApp/Resources/Assets.xcassets" ]; then
    cp -r "Sources/DocketApp/Resources/Assets.xcassets" "$BUILD_DIR/$APP_NAME.app/Contents/Resources/"
fi

# Make executable
chmod +x "$BUILD_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"

echo "✅ $APP_NAME.app created at $BUILD_DIR/$APP_NAME.app"

# Basic validation
if [ -x "$BUILD_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME" ]; then
    echo "✅ Executable is valid"
else
    echo "❌ Executable is missing or not executable"
    exit 1
fi

echo ""
echo "🚀 To run: open $BUILD_DIR/$APP_NAME.app"
echo "📥 To install: cp -r $BUILD_DIR/$APP_NAME.app /Applications/"