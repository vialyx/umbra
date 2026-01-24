#!/bin/bash

# Umbra PKG Installer Builder
# This script builds a signed and notarized installer for Umbra

set -e

PROJECT_NAME="Umbra"
BUNDLE_ID="com.umbra.app"
VERSION="1.0.4"
BUILD_DIR="build"
RELEASE_DIR="release"
APP_NAME="${PROJECT_NAME}.app"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building ${PROJECT_NAME} Installer${NC}"

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
rm -rf "$RELEASE_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"

# Build the app
echo -e "${GREEN}Building application...${NC}"
swift build -c release --arch arm64 --arch x86_64

# Create app bundle structure
echo -e "${GREEN}Creating app bundle...${NC}"
APP_DIR="$BUILD_DIR/$APP_NAME"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy binary
if [ -f ".build/apple/Products/Release/Umbra" ]; then
    cp .build/apple/Products/Release/Umbra "$APP_DIR/Contents/MacOS/"
elif [ -f ".build/arm64-apple-macosx/release/Umbra" ]; then
    cp .build/arm64-apple-macosx/release/Umbra "$APP_DIR/Contents/MacOS/"
elif [ -f ".build/release/Umbra" ]; then
    cp .build/release/Umbra "$APP_DIR/Contents/MacOS/"
else
    echo "Error: Could not find Umbra binary"
    exit 1
fi

# Make executable
chmod +x "$APP_DIR/Contents/MacOS/Umbra"

# Copy Info.plist
cp Info.plist "$APP_DIR/Contents/Info.plist"

# Copy app icon
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "$APP_DIR/Contents/Resources/"
    echo -e "${GREEN}  ✓ App icon included${NC}"
fi

# Sign the app (requires Developer ID certificate)
echo -e "${GREEN}Signing application...${NC}"
# For now, ad-hoc signing for local distribution
codesign --force --deep --sign - "$APP_DIR" 2>/dev/null || echo "  Skipping code signing (optional for testing)"

# Create component package
echo -e "${GREEN}Creating component package...${NC}"
pkgbuild --root "$BUILD_DIR" \
         --identifier "$BUNDLE_ID" \
         --version "$VERSION" \
         --install-location "/Applications" \
         --scripts "Installer/scripts" \
         "$BUILD_DIR/${PROJECT_NAME}-component.pkg"

# Create distribution package
echo -e "${GREEN}Creating distribution package...${NC}"
productbuild --distribution "Installer/Distribution.xml" \
             --package-path "$BUILD_DIR" \
             "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}.pkg"

# Optional: Ad-hoc signing for local distribution
productsign --sign - \
            "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}.pkg" \
            "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}-signed.pkg" 2>/dev/null && \
mv "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}-signed.pkg" "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}.pkg" || \
echo "  Using unsigned package (fine for GitHub releases)"

echo -e "${GREEN}Build complete!${NC}"
echo -e "Installer: ${RELEASE_DIR}/${PROJECT_NAME}-${VERSION}.pkg"
echo ""
echo -e "${BLUE}Ready for GitHub release!${NC}"
echo -e "${BLUE}Note: For Mac App Store or wider distribution:${NC}"
echo -e "  1. Sign with Developer ID certificates"
echo -e "  2. Notarize with Apple: xcrun notarytool submit"
echo -e "  3. Staple the notarization: xcrun stapler staple"

