#!/bin/bash

# Quick publish script for Umbra
# This script helps you publish Umbra to GitHub

set -e

REPO_URL="https://github.com/YOUR_USERNAME/umbra.git"

echo "🚀 Umbra GitHub Publishing Assistant"
echo ""

# Check if git remote exists
if git remote | grep -q "origin"; then
    echo "✓ Git remote 'origin' already configured"
    CURRENT_REMOTE=$(git remote get-url origin)
    echo "  Current remote: $CURRENT_REMOTE"
else
    echo "❌ Git remote 'origin' not configured"
    echo ""
    echo "To set up your GitHub repository:"
    echo "1. Create a new repository at: https://github.com/new"
    echo "2. Name it: umbra"
    echo "3. Do NOT initialize with README"
    echo ""
    echo "Then run:"
    echo "  git remote add origin https://github.com/YOUR_USERNAME/umbra.git"
    echo "  git push -u origin main"
    exit 1
fi

# Check if already pushed
if git ls-remote origin &> /dev/null; then
    echo "✓ Repository is connected to GitHub"
else
    echo "⚠️  Repository exists but may not be pushed yet"
    echo ""
    read -p "Push to GitHub now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push -u origin main
        echo "✓ Pushed to GitHub!"
    fi
fi

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo ""
    echo "⚠️  You have uncommitted changes:"
    git status -s
    echo ""
    read -p "Commit and push these changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Commit message: " COMMIT_MSG
        git add .
        git commit -m "$COMMIT_MSG"
        git push
        echo "✓ Changes committed and pushed!"
    fi
fi

echo ""
echo "📦 Create GitHub Release"
echo ""
echo "Current status:"
echo "  ✓ Code is on GitHub"
echo "  ✓ PKG installer ready: release/Umbra-1.0.0.pkg"
echo ""
echo "To create a release:"
echo ""
echo "Option 1: Via GitHub Web (Recommended)"
echo "  1. Go to: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases/new"
echo "  2. Tag: v1.0.0"
echo "  3. Title: Umbra v1.0.0 - Initial Release"
echo "  4. Upload: release/Umbra-1.0.0.pkg"
echo "  5. Click 'Publish release'"
echo ""
echo "Option 2: Via GitHub CLI"
if command -v gh &> /dev/null; then
    echo "  ✓ GitHub CLI is installed"
    echo ""
    read -p "Create release now with GitHub CLI? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "release/Umbra-1.0.0.pkg" ]; then
            gh release create v1.0.0 \
              release/Umbra-1.0.0.pkg \
              --title "Umbra v1.0.0 - Initial Release" \
              --notes "🔒 Automatic Mac locking when your iPhone or Apple Watch goes out of range.

## Features
- Proximity-based automatic screen locking
- Multi-device support (iPhone, Apple Watch, iPad, AirPods)
- Customizable distance and delay settings
- Beautiful SwiftUI interface
- Menu bar integration

## Installation
1. Download Umbra-1.0.0.pkg
2. Double-click to install
3. Grant permissions when prompted
4. Add your devices in Settings

See [README.md](README.md) for full documentation."
            echo ""
            echo "✅ Release created successfully!"
            echo ""
            echo "View it at: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases"
        else
            echo "❌ PKG file not found. Run ./Installer/build-installer.sh first"
        fi
    fi
else
    echo "  ❌ GitHub CLI not installed"
    echo "  Install with: brew install gh"
    echo "  Then run: gh auth login"
fi

echo ""
echo "📚 Next Steps:"
echo "  1. Add screenshots to README.md"
echo "  2. Share your release on social media"
echo "  3. Monitor issues and pull requests"
echo ""
echo "See PUBLISHING.md for detailed instructions"
