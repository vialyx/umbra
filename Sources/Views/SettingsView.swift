import SwiftUI
import CoreBluetooth

struct SettingsView: View {
    @EnvironmentObject var deviceMonitor: DeviceMonitor
    @EnvironmentObject var preferences: PreferencesManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DevicesTab()
                .tabItem {
                    Label("Devices", systemImage: "iphone.and.arrow.forward")
                }
                .tag(0)
            
            BehaviorTab()
                .tabItem {
                    Label("Behavior", systemImage: "gearshape")
                }
                .tag(1)
            
            AdvancedTab()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
                .tag(2)
        }
        .frame(minWidth: 600, minHeight: 500)
        .environmentObject(deviceMonitor)
        .environmentObject(preferences)
    }
}

struct DevicesTab: View {
    @EnvironmentObject var deviceMonitor: DeviceMonitor
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monitored Devices")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Select which devices to monitor for proximity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if deviceMonitor.isScanning {
                        deviceMonitor.stopScanning()
                    } else {
                        deviceMonitor.startScanning()
                    }
                }) {
                    Label(
                        deviceMonitor.isScanning ? "Stop Scanning" : "Scan for Devices",
                        systemImage: deviceMonitor.isScanning ? "stop.circle" : "magnifyingglass"
                    )
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            // Bluetooth Status
            if deviceMonitor.bluetoothState != .poweredOn {
                BluetoothWarningView(state: deviceMonitor.bluetoothState)
            }
            
            // Device Lists
            ScrollView {
                VStack(spacing: 20) {
                    // Monitored Devices
                    if !deviceMonitor.monitoredDevices.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Currently Monitoring")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(deviceMonitor.monitoredDevices) { device in
                                DeviceRow(device: device, isMonitored: true)
                            }
                        }
                    }
                    
                    // Discovered Devices
                    if deviceMonitor.isScanning && !deviceMonitor.discoveredDevices.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Discovered Devices")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(deviceMonitor.discoveredDevices) { device in
                                let isMonitored = deviceMonitor.monitoredDevices.contains(where: { $0.id == device.id })
                                if !isMonitored {
                                    DeviceRow(device: device, isMonitored: false)
                                }
                            }
                        }
                    }
                    
                    if !deviceMonitor.isScanning && deviceMonitor.monitoredDevices.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "iphone.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No Devices Monitored")
                                .font(.title3)
                            Text("Scan for nearby devices to get started")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct DeviceRow: View {
    let device: Device
    let isMonitored: Bool
    @EnvironmentObject var deviceMonitor: DeviceMonitor
    
    var body: some View {
        HStack(spacing: 16) {
            // Device Icon
            Image(systemName: device.type.icon)
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            // Device Info
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(device.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 3, height: 3)
                    
                    Text("RSSI: \(device.rssi) dBm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 3, height: 3)
                    
                    Text(device.signalStrength.rawValue)
                        .font(.caption)
                        .foregroundColor(colorForSignal(device.signalStrength.color))
                }
            }
            
            Spacer()
            
            // Signal Strength Indicator
            SignalStrengthIndicator(rssi: device.rssi)
            
            // Monitor Toggle
            Button(action: {
                deviceMonitor.toggleMonitoring(for: device)
            }) {
                Image(systemName: isMonitored ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(isMonitored ? .green : .accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isMonitored ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    func colorForSignal(_ colorName: String) -> Color {
        switch colorName {
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        default: return .secondary
        }
    }
}

struct SignalStrengthIndicator: View {
    let rssi: Int
    
    var bars: Int {
        switch rssi {
        case -50...0: return 4
        case -60..<(-50): return 3
        case -70..<(-60): return 2
        case -80..<(-70): return 1
        default: return 0
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < bars ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 3, height: CGFloat(8 + index * 4))
            }
        }
    }
}

struct BluetoothWarningView: View {
    let state: CBManagerState
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.subheadline)
            
            Spacer()
            
            if state == .poweredOff {
                Button("Open System Settings") {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.network")!)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
    }
    
    var message: String {
        switch state {
        case .poweredOff: return "Bluetooth is turned off. Please enable it to scan for devices."
        case .unauthorized: return "Bluetooth access not authorized. Please grant permission in System Settings."
        case .unsupported: return "Bluetooth is not supported on this device."
        default: return "Bluetooth is not available."
        }
    }
}

struct BehaviorTab: View {
    @EnvironmentObject var preferences: PreferencesManager
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Auto-Lock", isOn: $preferences.autoLockEnabled)
                    .toggleStyle(.switch)
                
                Text("Automatically lock your Mac when monitored devices go out of range")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Distance Threshold") {
                HStack {
                    Text("RSSI Threshold:")
                    Spacer()
                    Text("\(preferences.rssiThreshold) dBm")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { Double(preferences.rssiThreshold) },
                    set: { preferences.rssiThreshold = Int($0) }
                ), in: -90...(-40), step: 5)
                
                Text("Lower values = shorter distance. Typical: -70 dBm ≈ 3-5 meters")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Lock Delay") {
                HStack {
                    Text("Delay before locking:")
                    Spacer()
                    Text("\(preferences.lockDelay) seconds")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { Double(preferences.lockDelay) },
                    set: { preferences.lockDelay = Int($0) }
                ), in: 0...30, step: 5)
                
                Text("Wait time after device goes out of range before locking")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Toggle("Show Notifications", isOn: $preferences.showNotifications)
                    .toggleStyle(.switch)
                
                Text("Display a notification when auto-lock is triggered")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AdvancedTab: View {
    @EnvironmentObject var preferences: PreferencesManager
    @EnvironmentObject var deviceMonitor: DeviceMonitor
    
    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at Login", isOn: $preferences.launchAtLogin)
                    .toggleStyle(.switch)
                
                Text("Start Umbra automatically when you log in")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Monitoring Status") {
                HStack {
                    Text("Bluetooth:")
                    Spacer()
                    StatusIndicator(isActive: deviceMonitor.bluetoothState == .poweredOn)
                }
                
                HStack {
                    Text("Monitoring:")
                    Spacer()
                    StatusIndicator(isActive: deviceMonitor.isMonitoring)
                }
                
                HStack {
                    Text("Monitored Devices:")
                    Spacer()
                    Text("\(deviceMonitor.monitoredDevices.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version:")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build:")
                    Spacer()
                    Text("2026.1.24")
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button("Test Lock Screen") {
                    // Force lock for testing (bypass cooldown)
                    LockManager.shared.lockScreen(force: true)
                }
                .foregroundColor(.orange)
                
                Text("Tests the screen locking functionality")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Reset All Settings") {
                    resetSettings()
                }
                .foregroundColor(.red)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func resetSettings() {
        let alert = NSAlert()
        alert.messageText = "Reset All Settings?"
        alert.informativeText = "This will remove all monitored devices and reset preferences to defaults."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            // Reset everything
            deviceMonitor.monitoredDevices.removeAll()
            deviceMonitor.stopMonitoring()
            UserDefaults.standard.removeObject(forKey: "monitoredDevices")
            
            preferences.autoLockEnabled = true
            preferences.rssiThreshold = -70
            preferences.lockDelay = 5
            preferences.showNotifications = true
        }
    }
}

struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(isActive ? "Active" : "Inactive")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DeviceMonitor.shared)
        .environmentObject(PreferencesManager.shared)
}
