# Umbra

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License">
</p>

Umbra automatically locks your Mac when you walk away with your iPhone or Apple Watch, providing seamless security for your workspace using Bluetooth proximity detection.

## Features

- 🔒 **Automatic Locking** - Locks your Mac when monitored devices go out of range
- 📱 **Multi-Device Support** - Monitor iPhone, Apple Watch, iPad, or AirPods
- 🎯 **Customizable Distance** - Adjust RSSI threshold for your preferred range
- ⏱️ **Configurable Delay** - Set delay before locking to prevent false triggers
- 🎨 **Modern SwiftUI Interface** - Clean, native macOS design
- 🔕 **Menu Bar App** - Unobtrusive, always accessible
- 🚀 **Launch at Login** - Runs automatically in the background
- 📦 **Easy Installation** - Professional PKG installer

## Requirements

- macOS 13.0 (Ventura) or later
- Bluetooth 4.0 or later
- iPhone, Apple Watch, or other Bluetooth device
- Xcode 15.0+ (for building from source)

## Installation

### Option 1: From Release (Recommended)

1. Download the latest `Umbra-X.X.X.pkg` from [Releases](https://github.com/yourusername/umbra/releases)
2. Double-click to install
3. Follow the installer prompts
4. Grant required permissions when prompted

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/umbra.git
cd umbra

# Build the application
swift build -c release

# Or build the installer
chmod +x Installer/build-installer.sh
./Installer/build-installer.sh
```

## Quick Start

1. **Launch Umbra** - Look for the shield icon in your menu bar
2. **Open Settings** - Click the icon and select "Settings..."
3. **Scan for Devices** - Click "Scan for Devices" in the Devices tab
4. **Add Device** - Click the + button next to your iPhone/Apple Watch
5. **Configure** - Adjust distance and delay settings in the Behavior tab
6. **Done!** - Umbra will now monitor your device

## Permissions

Umbra requires the following permissions:

- **Bluetooth** - To detect your devices (requested automatically)
- **Accessibility** - To lock your screen (manual approval required)
- **Notifications** - To show lock alerts (optional)

## Configuration

### Distance Threshold (RSSI)

The RSSI (Received Signal Strength Indicator) determines how close your device needs to be:

- **-50 dBm** - Very close (< 1 meter)
- **-60 dBm** - Close (1-2 meters)
- **-70 dBm** - Medium (3-5 meters) - *Default*
- **-80 dBm** - Far (5-10 meters)
- **-90 dBm** - Very far (10+ meters)

### Lock Delay

Time to wait after device goes out of range before locking:

- **0 seconds** - Immediate (may cause false triggers)
- **5 seconds** - *Default* (recommended)
- **10-30 seconds** - For less aggressive locking

## How It Works

1. **Bluetooth Scanning** - Continuously scans for monitored devices
2. **RSSI Monitoring** - Measures signal strength to determine distance
3. **Threshold Check** - Compares RSSI against configured threshold
4. **Delay Timer** - Waits for configured delay period
5. **Auto-Lock** - Locks Mac using system APIs

## Technical Details

### Core Technologies

- **SwiftUI** - Modern, declarative UI framework
- **Core Bluetooth** - BLE device scanning and monitoring
- **Combine** - Reactive data flow
- **UserNotifications** - Lock notifications
- **AppKit** - Menu bar integration

### Architecture

```
Umbra/
├── UmbraApp.swift           # App entry point, menu bar setup
├── Models/
│   └── Device.swift         # Device data model
├── Managers/
│   ├── DeviceMonitor.swift  # Bluetooth scanning & monitoring
│   ├── LockManager.swift    # Screen locking logic
│   └── PreferencesManager.swift # Settings persistence
└── Views/
    └── SettingsView.swift   # SwiftUI settings interface
```

### Security

- Device identifiers stored in UserDefaults (can be migrated to Keychain)
- No network communication - fully local
- Open source - audit the code yourself
- Minimal permissions required

## Building for Distribution

### Code Signing

1. Obtain a Developer ID Application certificate from Apple
2. Sign the app:
```bash
codesign --force --deep --sign "Developer ID Application: Your Name (TEAMID)" Umbra.app
```

### Notarization

1. Build and sign the installer
2. Submit for notarization:
```bash
xcrun notarytool submit Umbra-1.0.0.pkg \
  --apple-id "your-email@example.com" \
  --team-id "TEAMID" \
  --password "app-specific-password"
```

3. Staple the notarization:
```bash
xcrun stapler staple Umbra-1.0.0.pkg
```

## Troubleshooting

### Bluetooth Issues

- **Can't see devices** - Ensure Bluetooth is enabled and device is nearby
- **Intermittent detection** - Bluetooth can be affected by interference
- **Device not updating** - Check that device is unlocked and Bluetooth is on

### Locking Issues

- **Screen won't lock** - Verify Accessibility permissions
- **Locks too often** - Increase RSSI threshold or lock delay
- **Doesn't lock** - Check that monitoring is enabled and device is truly out of range

### Reset Settings

Go to Advanced tab → Reset All Settings to restore defaults

## Uninstallation

1. Quit Umbra from the menu bar
2. Delete `/Applications/Umbra.app`
3. Delete `~/Library/LaunchAgents/com.umbra.app.plist`
4. Run: `launchctl unload ~/Library/LaunchAgents/com.umbra.app.plist`

## Roadmap

- [ ] Multiple distance profiles (home, office, etc.)
- [ ] Geofencing integration
- [ ] Sleep prevention when device is present
- [ ] Custom notification sounds
- [ ] Activity log
- [ ] iCloud sync for settings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

- Inspired by the need for seamless Mac security
- Built with SwiftUI and Core Bluetooth
- Thanks to the macOS developer community

## Support

- **Issues** - [GitHub Issues](https://github.com/yourusername/umbra/issues)
- **Discussions** - [GitHub Discussions](https://github.com/yourusername/umbra/discussions)
- **Email** - support@example.com

---

Made with ❤️ for macOS users who value security and convenience
