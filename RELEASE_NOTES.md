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
- [Report Issues](https://github.com/vialyx/umbra/issues)

---

**First time using Umbra?** Check out our [Quick Start Guide](README.md#quick-start)!
