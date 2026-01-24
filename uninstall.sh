#!/bin/bash

# Uninstall script for Umbra
# Completely removes Umbra from your Mac

set -e

echo "🗑️  Uninstalling Umbra..."
echo ""

# Get current user
CURRENT_USER=$(whoami)
USER_HOME=$HOME
LAUNCH_AGENTS_DIR="$USER_HOME/Library/LaunchAgents"
PLIST_NAME="com.umbra.app.plist"
PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

# 1. Stop the app if running
echo "1. Stopping Umbra..."
killall Umbra 2>/dev/null && echo "   ✓ App stopped" || echo "   • App not running"

# 2. Unload LaunchAgent
echo "2. Removing LaunchAgent..."
if [ -f "$PLIST_PATH" ]; then
    launchctl unload "$PLIST_PATH" 2>/dev/null && echo "   ✓ LaunchAgent unloaded" || echo "   • Already unloaded"
    rm -f "$PLIST_PATH" && echo "   ✓ LaunchAgent removed" || echo "   • Not found"
else
    echo "   • LaunchAgent not found"
fi

# 3. Remove application
echo "3. Removing application..."
if [ -d "/Applications/Umbra.app" ]; then
    sudo rm -rf "/Applications/Umbra.app" && echo "   ✓ Application removed"
else
    echo "   • Application not found"
fi

# 4. Remove preferences (optional - comment out if you want to keep settings)
echo "4. Removing preferences..."
defaults delete com.umbra.app 2>/dev/null && echo "   ✓ Preferences removed" || echo "   • No preferences found"
defaults delete com.umbra.app.test 2>/dev/null && echo "   ✓ Test preferences removed" || echo "   • No test preferences found"

# 5. Clean up any leftover files
echo "5. Cleaning up..."
rm -rf "$USER_HOME/Library/Preferences/com.umbra.app.plist" 2>/dev/null && echo "   ✓ Preference files removed" || true
rm -rf "$USER_HOME/Library/Caches/com.umbra.app" 2>/dev/null && echo "   ✓ Cache files removed" || true

echo ""
echo "✅ Umbra has been completely uninstalled!"
echo ""
echo "Note: If you want to test a fresh installation:"
echo "  1. Run this script to uninstall"
echo "  2. Install the PKG again"
echo "  3. The onboarding will appear as a first-time user"
