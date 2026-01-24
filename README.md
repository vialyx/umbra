# Umbra

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/License-Proprietary-red.svg" alt="Proprietary License">
</p>

<p align="center">
  <strong>💖 Support Development</strong><br>
  <a href="https://www.paypal.com/paypalme/vialyx">
    <img src="https://img.shields.io/badge/Donate-PayPal-blue.svg" alt="Donate via PayPal">
  </a>
</p>

Umbra automatically locks your Mac when you walk away with your iPhone or Apple Watch, providing seamless security for your workspace using Bluetooth proximity detection.

## 🎥 Demo Video

[![Umbra Demo](https://img.youtube.com/vi/mKpcqu5VCc0/maxresdefault.jpg)](https://youtu.be/mKpcqu5VCc0)

Watch Umbra in action! Click above to see how it works.

> **Note**: This software is free for personal use. Commercial use requires a paid license. [Contact us](https://www.paypal.com/paypalme/vialyx) for commercial licensing.

## Features

- 🔒 **Automatic Locking** - Locks your Mac when monitored devices go out of range
- 📱 **Multi-Device Support** - Monitor iPhone, Apple Watch, iPad, AirPods, and more
- 🎯 **Smart Detection** - Uses Apple manufacturer data for accurate device identification
- ⏱️ **Configurable Delay** - Set delay before locking to prevent false triggers
- 🎨 **Modern SwiftUI Interface** - Clean, native macOS design with 3-step onboarding
- 🔕 **Menu Bar App** - Unobtrusive, always accessible
- 🚀 **Launch at Login** - Runs automatically in the background
- 📦 **Easy Installation** - Professional PKG installer with auto-launch
- 🔋 **Battery Optimized** - Pauses scanning when screen is already locked
- 🔐 **Privacy-Focused** - No accessibility permissions required, all data stays on your Mac
- 📊 **Signal Strength Display** - Real-time RSSI monitoring for all devices

## Requirements

- macOS 13.0 (Ventura) or later
- Bluetooth 4.0 or later
- iPhone, Apple Watch, or other Bluetooth device
- Xcode 15.0+ (for building from source)

## Installation

### Option 1: From Release (Recommended)

1. Download the latest `Umbra-1.0.10.pkg` from [Releases](https://github.com/vialyx/umbra/releases)
2. Double-click to install
3. Follow the installer prompts
4. Umbra will launch automatically after installation
5. Grant Bluetooth permissions when prompted

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/vialyx/umbra.git
cd umbra

# Build the application
swift build -c release

# Or run the test build script
./test-app.sh

# Build the installer
chmod +x Installer/build-installer.sh
./Installer/build-installer.sh
```

## Quick Start

1. **Launch Umbra** - The app opens automatically after installation, or look for the shield icon in your menu bar
2. **Complete Onboarding** - Follow the 3-step setup wizard:
   - Welcome screen with feature overview
   - Bluetooth permission request
   - Device scanning and selection
3. **Add Your Device** - Select your iPhone, Apple Watch, or other Apple device from the list
4. **Customize Settings** (Optional) - Adjust distance threshold and lock delay in Settings
5. **Done!** - Umbra will now monitor your device and lock your Mac when you walk away

## Permissions

Umbra requires minimal permissions:

- **Bluetooth** - To detect your devices (requested automatically during onboarding)
- **Notifications** - To show lock alerts (optional but recommended)

**Note:** Unlike other solutions, Umbra does NOT require Accessibility permissions. It uses the native `pmset displaysleepnow` command for locking.

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
- **10 seconds** - *Default* (recommended)
- **15-30 seconds** - For less aggressive locking

**Smart Lock Logic:** Umbra only locks when ALL monitored devices have been out of range for the full delay period, preventing false triggers.

## How It Works

1. **Bluetooth Scanning** - Continuously scans for monitored devices using Core Bluetooth
2. **Device Detection** - Uses Apple manufacturer data (Company ID: 0x004C) to identify Apple devices
3. **RSSI Monitoring** - Measures signal strength to determine distance
4. **Smart Tracking** - Tracks when each device goes out of range independently
5. **Delay Timer** - Waits for configured delay period (all devices must be out of range)
6. **Auto-Lock** - Locks Mac using `pmset displaysleepnow` command
7. **Battery Optimization** - Pauses scanning when screen is already locked
8. **Notifications** - Sends notification before locking (optional)

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
├── Sources/
│   ├── UmbraApp.swift              # App entry point, menu bar setup
│   ├── Models/
│   │   └── Device.swift            # Device data model with type detection
│   ├── Managers/
│   │   ├── DeviceMonitor.swift     # Bluetooth scanning & monitoring
│   │   ├── LockManager.swift       # Screen locking with pmset
│   │   └── PreferencesManager.swift # Settings persistence
│   └── Views/
│       ├── OnboardingView.swift    # 3-step onboarding wizard
│       └── SettingsView.swift      # 3-tab settings interface
├── Resources/
│   └── AppIcon.icns                # App icon
├── Installer/
│   ├── build-installer.sh          # PKG installer builder
│   └── scripts/
│       ├── preinstall              # Pre-installation cleanup
│       └── postinstall             # LaunchAgent setup & app launch
└── Tests/
    └── DeviceMonitorTests.swift    # Unit tests
```

### Security

- All device data stored locally in UserDefaults
- No network communication - fully offline operation
- No accessibility permissions required
- Open source - audit the code yourself
- Uses native macOS locking mechanism (`pmset`)
- Privacy-focused - your data never leaves your Mac

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

- **Screen won't lock** - Umbra uses `pmset displaysleepnow` which works without special permissions
- **Locks too often** - Increase RSSI threshold or lock delay in Settings → Behavior
- **Doesn't lock** - Check that monitoring is enabled (menu bar icon shows status) and device is truly out of range
- **False triggers** - Increase lock delay to 15-20 seconds for more stability

### Reset Settings

Open Settings → Advanced tab → Click "Reset All Settings" to restore defaults

## Updates

Umbra follows semantic versioning. Check [Releases](https://github.com/vialyx/umbra/releases) for the latest version.

**Current Version:** 1.0.10

**Recent Updates:**
- v1.0.10 - Smart device prioritization (Apple devices first in list)
- v1.0.9 - UX polish and stability improvements
- v1.0.8 - Intelligent Apple device detection using manufacturer data
- v1.0.7 - Device sorting and enhanced type detection
- v1.0.6 - Onboarding UI layout fixes

## Uninstallation

1. Quit Umbra from the menu bar
2. Delete `/Applications/Umbra.app`
3. Delete `~/Library/LaunchAgents/com.umbra.app.plist`
4. Run: `launchctl unload ~/Library/LaunchAgents/com.umbra.app.plist`

## Roadmap

- [ ] Widget support for monitoring status
- [ ] Multiple distance profiles (home, office, etc.)
- [ ] Geofencing integration
- [ ] Custom notification sounds
- [ ] Activity log and statistics
- [ ] iCloud sync for settings
- [ ] Shortcuts app integration

## License

**Umbra Proprietary License**

- ✅ **Free for Personal Use** - Use Umbra at home for personal security
- ✅ **Educational Use** - Study the source code for learning
- ❌ **Commercial Use Restricted** - Requires a paid commercial license

**Commercial Use Includes:**
- Using in a business environment
- Deploying on company computers
- Incorporating into commercial products
- Any use for profit or commercial advantage

**Get a Commercial License:**
- Email: [maksim.vialykh@icloud.com](mailto:maksim.vialykh@icloud.com) to discuss commercial licensing
- Or [contact via PayPal](https://www.paypal.com/paypalme/vialyx)
- See [LICENSE](LICENSE) file for full terms and conditions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

**Note**: By contributing to this project, you agree that your contributions will be licensed under the same proprietary license terms. For substantial contributions or commercial partnerships, please contact us first.

**How to contribute:**
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**Areas where contributions are especially welcome:**
- Bug fixes and performance improvements
- Better device detection algorithms
- UI/UX enhancements
- Documentation improvements
- Unit test coverage

## Support & Donations

Love Umbra? Support its development!

💖 **[Donate via PayPal](https://www.paypal.com/paypalme/vialyx)**

Your donations help:
- Continue active development
- Add new features
- Provide support and bug fixes
- Keep the project maintained

## Acknowledgments

- Inspired by the need for seamless Mac security
- Built with SwiftUI and Core Bluetooth
- Thanks to the macOS developer community

## Contact

- **Issues & Bug Reports** - [GitHub Issues](https://github.com/vialyx/umbra/issues)
- **Feature Requests** - [GitHub Discussions](https://github.com/vialyx/umbra/discussions)
- **Email** - [maksim.vialykh@icloud.com](mailto:maksim.vialykh@icloud.com)
- **Commercial Licensing** - [maksim.vialykh@icloud.com](mailto:maksim.vialykh@icloud.com)

## Links

- 🎥 [Demo Video](https://youtu.be/mKpcqu5VCc0)
- 📦 [Latest Release](https://github.com/vialyx/umbra/releases/latest)
- 📚 [Documentation](https://github.com/vialyx/umbra/wiki) (coming soon)
- 💖 [Donate via PayPal](https://www.paypal.com/paypalme/vialyx)

---

Made with ❤️ for macOS users who value security and convenience
