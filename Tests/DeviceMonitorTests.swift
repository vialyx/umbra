import XCTest
@testable import Umbra

class DeviceMonitorTests: XCTestCase {
    
    func testRSSIThresholdDetection() {
        // Test that devices with good signal are considered in range
        let device = Device(
            id: UUID(),
            name: "Test iPhone",
            type: .iPhone,
            rssi: -60, // Good signal
            isMonitored: true,
            lastSeen: Date()
        )
        
        // RSSI of -60 should be considered in range with default threshold of -70
        XCTAssertTrue(device.rssi >= -70, "Device with -60 RSSI should be in range")
        XCTAssertEqual(device.signalStrength, .good)
    }
    
    func testWeakSignalDetection() {
        let device = Device(
            id: UUID(),
            name: "Test iPhone",
            type: .iPhone,
            rssi: -80, // Weak signal
            isMonitored: true,
            lastSeen: Date()
        )
        
        // RSSI of -80 should be out of range with default threshold of -70
        XCTAssertTrue(device.rssi < -70, "Device with -80 RSSI should be out of range")
        XCTAssertEqual(device.signalStrength, .weak)
    }
    
    func testDeviceTypeDetection() {
        XCTAssertEqual(Device.detectType(from: "Maksim's iPhone"), .iPhone)
        XCTAssertEqual(Device.detectType(from: "Apple Watch"), .appleWatch)
        XCTAssertEqual(Device.detectType(from: "iPad Pro"), .iPad)
        XCTAssertEqual(Device.detectType(from: "AirPods Pro"), .airPods)
        XCTAssertEqual(Device.detectType(from: "Unknown Device"), .other)
    }
    
    func testDeviceIconMapping() {
        XCTAssertEqual(Device.DeviceType.iPhone.icon, "iphone")
        XCTAssertEqual(Device.DeviceType.appleWatch.icon, "applewatch")
        XCTAssertEqual(Device.DeviceType.iPad.icon, "ipad")
        XCTAssertEqual(Device.DeviceType.airPods.icon, "airpods")
        XCTAssertEqual(Device.DeviceType.other.icon, "bluetooth")
    }
    
    func testSignalStrengthRanges() {
        var device = Device(id: UUID(), name: "Test", type: .iPhone, rssi: -45, isMonitored: true, lastSeen: Date())
        XCTAssertEqual(device.signalStrength, .excellent, "RSSI -45 should be excellent")
        
        device.rssi = -55
        XCTAssertEqual(device.signalStrength, .good, "RSSI -55 should be good")
        
        device.rssi = -65
        XCTAssertEqual(device.signalStrength, .fair, "RSSI -65 should be fair")
        
        device.rssi = -75
        XCTAssertEqual(device.signalStrength, .weak, "RSSI -75 should be weak")
        
        device.rssi = -85
        XCTAssertEqual(device.signalStrength, .veryWeak, "RSSI -85 should be very weak")
    }
    
    func testDeviceLastSeenTracking() {
        let now = Date()
        let device = Device(
            id: UUID(),
            name: "Test iPhone",
            type: .iPhone,
            rssi: -60,
            isMonitored: true,
            lastSeen: now
        )
        
        let timeSinceLastSeen = Date().timeIntervalSince(device.lastSeen)
        XCTAssertTrue(timeSinceLastSeen < 1.0, "Device should have been seen recently")
    }
    
    func testPreferencesDefaults() {
        let prefs = PreferencesManager.shared
        
        // Check default values
        XCTAssertTrue(prefs.autoLockEnabled, "Auto-lock should be enabled by default")
        XCTAssertEqual(prefs.rssiThreshold, -70, "Default RSSI threshold should be -70")
        XCTAssertEqual(prefs.lockDelay, 10, "Default lock delay should be 10 seconds")
        XCTAssertTrue(prefs.launchAtLogin, "Launch at login should be enabled by default")
        XCTAssertTrue(prefs.showNotifications, "Notifications should be enabled by default")
    }
}
