# Changelog

All notable changes to Umbra will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
