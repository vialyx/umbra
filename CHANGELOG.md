# Changelog

All notable changes to Umbra will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-01-24

### Added
- **App icon** for better notification display and app branding
- Icon generation script for consistent iconography

### Fixed
- **Test Lock Screen button** now works immediately without waiting for cooldown period
- **Notification icon** now displays properly with custom Umbra icon

### Technical
- Updated build scripts to include AppIcon.icns in app bundle
- Added force parameter to lock screen function for testing purposes
- Icon includes shield with lock design matching app's security theme

## [1.0.1] - 2026-01-24

### Added
- **Interactive onboarding flow** for first-time users
  - Welcome screen explaining app features
  - Bluetooth permission request with explanation
  - Accessibility permission guide with step-by-step instructions
  - Device setup wizard with live scanning
- Automatic app launch after installation
- Onboarding state persistence

### Improved
- Better user experience for new users
- Clear permission explanations
- Guided device setup process
- Post-installation workflow

### Fixed
- App now starts automatically after PKG installation
- Users are properly guided through all required permissions
- Device addition is now part of onboarding

## [1.0.0] - 2026-01-24

### Added
- Initial release of Umbra
- Core Bluetooth device scanning and monitoring
- Proximity-based automatic screen locking
- Multi-device support (iPhone, Apple Watch, iPad, AirPods)
- Real-time RSSI signal strength monitoring
- Customizable distance threshold and lock delay
- SwiftUI-based settings interface with 3 tabs:
  - Devices: Scan and manage monitored devices
  - Behavior: Configure auto-lock settings
  - Advanced: System status and testing
- Menu bar integration with status indicator
- Launch at login support
- User notifications before locking
- PKG installer with LaunchAgent setup
- Automatic permissions handling
- Signal strength visualization
- Device type detection and icons
- Background monitoring with minimal battery impact

### Known Limitations
- Requires macOS 13.0 (Ventura) or later
- Bluetooth must remain enabled
- First launch requires manual Accessibility permission grant
- Range accuracy depends on Bluetooth environment

[1.0.0]: https://github.com/yourusername/umbra/releases/tag/v1.0.0
