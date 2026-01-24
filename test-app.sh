#!/bin/bash

# Quick test script to build and run Umbra as a proper .app bundle

set -e

echo "🔨 Building Umbra..."
swift build -c debug

echo "📦 Creating test app bundle..."
APP_DIR="build/Umbra.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy binary
cp .build/debug/Umbra "$APP_DIR/Contents/MacOS/"

# Copy Info.plist
cp Info.plist "$APP_DIR/Contents/Info.plist"

# Copy app icon if it exists
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "$APP_DIR/Contents/Resources/"
    echo "  ✓ App icon copied"
fi

# Update bundle identifier for testing (avoid conflicts)
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.umbra.app.test" "$APP_DIR/Contents/Info.plist" 2>/dev/null || true

echo "✅ Test app bundle created at: $APP_DIR"
echo ""
echo "To run:"
echo "  open $APP_DIR"
echo ""
echo "To test from command line:"
echo "  $APP_DIR/Contents/MacOS/Umbra"
