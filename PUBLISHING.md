# Publishing Umbra to GitHub

This guide walks you through publishing Umbra to GitHub and creating your first release.

## Prerequisites

- GitHub account
- Git installed on your Mac
- The Umbra repository ready to push

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `umbra`
3. Description: "Automatic Mac locking based on iPhone/Apple Watch proximity"
4. Choose Public or Private
5. **DO NOT** initialize with README (we already have one)
6. Click "Create repository"

## Step 2: Push to GitHub

```bash
cd /Users/maksimvialykh/github/umbra

# Add GitHub remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/umbra.git

# Push the code
git branch -M main
git push -u origin main
```

## Step 3: Create Your First Release

### Option A: Via GitHub Web Interface (Recommended)

1. Go to your repository on GitHub
2. Click on "Releases" (right sidebar)
3. Click "Create a new release"
4. Tag version: `v1.0.0`
5. Release title: `Umbra v1.0.0 - Initial Release`
6. Description: Copy from the release notes below
7. Upload the PKG file: `release/Umbra-1.0.0.pkg`
8. Click "Publish release"

### Option B: Via Command Line

```bash
# Install GitHub CLI (if not already installed)
brew install gh

# Authenticate
gh auth login

# Create release and upload installer
gh release create v1.0.0 \
  release/Umbra-1.0.0.pkg \
  --title "Umbra v1.0.0 - Initial Release" \
  --notes "$(cat RELEASE_NOTES.md)"
```

## Release Notes Template

```markdown
## 🔒 Umbra v1.0.0 - Initial Release

Umbra automatically locks your Mac when you walk away with your iPhone or Apple Watch, providing seamless security for your workspace.

### ✨ Features

- 🔐 Automatic screen locking based on device proximity
- 📱 Support for iPhone, Apple Watch, iPad, and AirPods
- 🎯 Customizable distance threshold (RSSI-based)
- ⏱️ Configurable lock delay (0-30 seconds)
- 🎨 Beautiful native SwiftUI interface
- 📊 Real-time signal strength monitoring
- 🔕 Menu bar app - unobtrusive and always accessible
- 🚀 Launch at login support
- 📦 Professional PKG installer

### 📥 Installation

1. Download `Umbra-1.0.0.pkg`
2. Double-click to install
3. Launch Umbra (look for shield icon in menu bar)
4. Grant Bluetooth and Accessibility permissions when prompted
5. Click Settings → Devices → Scan for Devices
6. Add your iPhone or Apple Watch
7. Configure distance and delay in Behavior tab
8. Done! Your Mac will now lock automatically

### 📋 Requirements

- macOS 13.0 (Ventura) or later
- Bluetooth 4.0 or later
- iPhone, Apple Watch, or other Bluetooth device
- Accessibility permissions (for screen locking)

### 🐛 Known Issues

- First run requires manual Accessibility permission grant
- Bluetooth interference may affect range detection accuracy
- Range estimation is approximate (±2-3 meters)

### 📝 Notes

This is an **unsigned** release for testing. Users may need to right-click → Open on first launch. For wider distribution, the app should be signed with a Developer ID and notarized.

### 🔗 Links

- [Full Documentation](README.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
- [Report Issues](https://github.com/YOUR_USERNAME/umbra/issues)

---

**First time using Umbra?** Check out our [Quick Start Guide](README.md#quick-start)!
```

## Step 4: Update Repository Settings

### Add Topics/Tags
1. Go to your repo → About section (gear icon)
2. Add topics: `macos`, `swift`, `swiftui`, `bluetooth`, `security`, `productivity`, `menu-bar-app`
3. Add website (if you have one)

### Enable Issues and Discussions
1. Settings → Features
2. ✅ Issues
3. ✅ Discussions (optional, for community)

### Add a License
You already have MIT License in the installer resources. Make it visible:
```bash
cp Installer/Resources/license.txt LICENSE
git add LICENSE
git commit -m "Add MIT License"
git push
```

### Add Repository Description
Settings → General → Description: "🔒 Automatic Mac locking when your iPhone or Apple Watch goes out of range • SwiftUI • Core Bluetooth"

## Step 5: Promote Your Release

### Share On
- Twitter/X: "Just released Umbra v1.0.0 - automatically locks your Mac when you walk away with your iPhone! 🔒 Open source, SwiftUI, Core Bluetooth"
- Reddit: r/macapps, r/swift, r/iOSProgramming
- Hacker News: Show HN
- Product Hunt (for more exposure)

### Create a Landing Page (Optional)
Consider creating a simple GitHub Pages site:
```bash
# Enable GitHub Pages
# Settings → Pages → Source: main branch → /docs folder

mkdir docs
# Add index.html, screenshots, etc.
```

## Step 6: Monitor and Respond

- Watch for Issues and respond promptly
- Review Pull Requests
- Update CHANGELOG.md for each release
- Consider adding screenshots to README

## Future Releases

For subsequent releases:

1. Update version in `Installer/build-installer.sh`
2. Update `CHANGELOG.md`
3. Build new PKG: `./Installer/build-installer.sh`
4. Commit changes: `git commit -am "Release v1.1.0"`
5. Create tag: `git tag v1.1.0`
6. Push: `git push && git push --tags`
7. GitHub Actions will automatically create the release (or create manually)

## Tips for Success

- Add screenshots to README (GIFs are even better!)
- Respond to issues quickly
- Keep documentation updated
- Consider user feedback for features
- Regular security updates
- Write good commit messages

---

**Ready to publish?** Start with Step 1 above!

For code signing and notarization (for wider distribution), see [SIGNING.md](SIGNING.md) (create this if needed).
