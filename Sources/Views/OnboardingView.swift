import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var deviceMonitor: DeviceMonitor
    @EnvironmentObject var preferences: PreferencesManager
    @State private var currentPage = 0
    @State private var bluetoothGranted = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            
            // Current page content
            Group {
                switch currentPage {
                case 0:
                    WelcomePage()
                case 1:
                    BluetoothPermissionPage(granted: $bluetoothGranted)
                case 2:
                    DeviceSetupPage()
                default:
                    WelcomePage()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.slide)
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                }
                
                Spacer()
                
                if currentPage < 2 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceed)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .padding(.bottom, 10) // Extra padding to prevent cutoff
        }
        .frame(width: 600, height: 540) // Increased height for better layout
    }
    
    var canProceed: Bool {
        switch currentPage {
        case 0: return true
        case 1: return bluetoothGranted
        case 2: return true
        default: return false
        }
    }
    
    func completeOnboarding() {
        preferences.hasCompletedOnboarding = true
        dismiss()
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 12) {
                Text("Welcome to Umbra")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Automatic Mac locking when you walk away")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "iphone.and.arrow.forward", text: "Monitor your iPhone or Apple Watch")
                FeatureRow(icon: "lock.circle", text: "Automatically lock when out of range")
                FeatureRow(icon: "slider.horizontal.3", text: "Customize distance and delay")
                FeatureRow(icon: "bolt.fill", text: "Runs efficiently in the background")
            }
            .padding(.horizontal, 60)
            
            Spacer()
            
            Text("Let's set up your device in just a few steps")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding(40)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}

struct BluetoothPermissionPage: View {
    @Binding var granted: Bool
    @State private var isChecking = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: granted ? "checkmark.circle.fill" : "wave.3.right.circle")
                .font(.system(size: 80))
                .foregroundColor(granted ? .green : .accentColor)
            
            VStack(spacing: 12) {
                Text("Bluetooth Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Umbra needs Bluetooth to detect your devices")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Why Bluetooth?")
                    .font(.headline)
                
                Text("• Detects when your iPhone or Apple Watch is nearby")
                Text("• Monitors signal strength to determine distance")
                Text("• No internet connection required")
                Text("• Your data stays on your Mac")
            }
            .padding(.horizontal, 60)
            .foregroundColor(.secondary)
            
            if !granted {
                Button(action: requestBluetoothPermission) {
                    Label(isChecking ? "Checking..." : "Grant Bluetooth Access", 
                          systemImage: "wave.3.right")
                        .frame(minWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isChecking)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Bluetooth access granted!")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
        }
        .padding(40)
        .onAppear {
            requestBluetoothPermission()
        }
    }
    
    func requestBluetoothPermission() {
        // Check current state first
        if DeviceMonitor.shared.bluetoothState == .poweredOn {
            granted = true
            return
        }
        
        isChecking = true
        // Trigger Bluetooth permission by starting the central manager
        DeviceMonitor.shared.startScanning()
        
        // Check periodically for permission grant
        var attempts = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            attempts += 1
            self.checkBluetoothPermission()
            
            if self.granted || attempts >= 10 {
                timer.invalidate()
                DeviceMonitor.shared.stopScanning()
            }
        }
    }
    
    func checkBluetoothPermission() {
        granted = DeviceMonitor.shared.bluetoothState == .poweredOn
        if granted {
            isChecking = false
        }
    }
}

struct AccessibilityPermissionPage: View {
    @Binding var granted: Bool
    @State private var isChecking = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: granted ? "checkmark.circle.fill" : "hand.raised.circle")
                .font(.system(size: 80))
                .foregroundColor(granted ? .green : .accentColor)
            
            VStack(spacing: 12) {
                Text("Accessibility Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Required to lock your Mac automatically")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("What happens:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    StepRow(number: 1, text: "We'll open System Settings for you")
                    StepRow(number: 2, text: "Navigate to Privacy & Security → Accessibility")
                    StepRow(number: 3, text: "Find 'Umbra' in the list")
                    StepRow(number: 4, text: "Toggle the switch to enable it")
                }
            }
            .padding(.horizontal, 60)
            
            if !granted {
                VStack(spacing: 12) {
                    Button(action: openSystemSettings) {
                        Label("Open System Settings", systemImage: "gear")
                            .frame(minWidth: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: checkAccessibilityPermission) {
                        Text(isChecking ? "Checking..." : "I've Granted Access")
                    }
                    .disabled(isChecking)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Accessibility access granted!")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            checkAccessibilityPermission()
        }
    }
    
    func openSystemSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
    
    func checkAccessibilityPermission() {
        isChecking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
            granted = AXIsProcessTrustedWithOptions(options)
            isChecking = false
        }
    }
}

struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            }
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct DeviceSetupPage: View {
    @EnvironmentObject var deviceMonitor: DeviceMonitor
    @State private var hasStartedScanning = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 12) {
                Text("Add Your Device")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Let's find your iPhone or Apple Watch")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            if !hasStartedScanning {
                VStack(spacing: 16) {
                    Text("Make sure your device is:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            Text("Nearby (within a few meters)")
                        }
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            Text("Bluetooth is enabled")
                        }
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            Text("Unlocked or recently used")
                        }
                    }
                    .foregroundColor(.secondary)
                    
                    Button(action: startScanning) {
                        Label("Scan for Devices", systemImage: "magnifyingglass")
                            .frame(minWidth: 200)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 60)
            } else if deviceMonitor.isScanning && deviceMonitor.discoveredDevices.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Scanning for devices...")
                        .font(.headline)
                    
                    Text("Looking for nearby Bluetooth devices")
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                    Button("Stop Scanning") {
                        deviceMonitor.stopScanning()
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 60)
            } else if !deviceMonitor.discoveredDevices.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Found Devices:")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(deviceMonitor.discoveredDevices.prefix(5)) { device in
                            OnboardingDeviceRow(device: device)
                        }
                        
                        if deviceMonitor.monitoredDevices.isEmpty {
                            Text("Tap a device to start monitoring")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("\(deviceMonitor.monitoredDevices.count) device(s) added")
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .frame(height: 200)
            }
            
            Spacer()
        }
        .padding(40)
        .onDisappear {
            // Stop scanning when leaving this page
            deviceMonitor.stopScanning()
        }
    }
    
    func startScanning() {
        hasStartedScanning = true
        deviceMonitor.startScanning()
        
        // Auto-stop after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak deviceMonitor] in
            deviceMonitor?.stopScanning()
        }
    }
}

struct OnboardingDeviceRow: View {
    let device: Device
    @EnvironmentObject var deviceMonitor: DeviceMonitor
    
    var isMonitored: Bool {
        deviceMonitor.monitoredDevices.contains(where: { $0.id == device.id })
    }
    
    var body: some View {
        Button(action: {
            deviceMonitor.toggleMonitoring(for: device)
        }) {
            HStack(spacing: 12) {
                Image(systemName: device.type.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(device.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isMonitored {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isMonitored ? Color.green.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isMonitored ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(DeviceMonitor.shared)
        .environmentObject(PreferencesManager.shared)
}
