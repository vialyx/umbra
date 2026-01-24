import Foundation
import CoreBluetooth
import Combine

class DeviceMonitor: NSObject, ObservableObject {
    static let shared = DeviceMonitor()
    
    @Published var discoveredDevices: [Device] = []
    @Published var monitoredDevices: [Device] = []
    @Published var isScanning = false
    @Published var isMonitoring = false
    @Published var bluetoothState: CBManagerState = .unknown
    
    private var centralManager: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var monitoringTimer: Timer?
    private var deviceOutOfRangeTime: [UUID: Date] = [:] // Track when devices went out of range
    private let lockManager = LockManager.shared
    private let preferences = PreferencesManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
        loadMonitoredDevices()
        setupMonitoring()
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth not ready")
            return
        }
        
        isScanning = true
        discoveredDevices.removeAll()
        
        // Scan for all devices
        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ])
        
        // Auto-stop after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func toggleMonitoring(for device: Device) {
        if let index = monitoredDevices.firstIndex(where: { $0.id == device.id }) {
            monitoredDevices.remove(at: index)
        } else {
            var newDevice = device
            newDevice.isMonitored = true
            monitoredDevices.append(newDevice)
        }
        saveMonitoredDevices()
        
        // Notify menu bar to update status
        NotificationCenter.default.post(name: NSNotification.Name("MonitoringStateChanged"), object: nil)
        
        if !monitoredDevices.isEmpty && !isMonitoring {
            startMonitoring()
        } else if monitoredDevices.isEmpty {
            stopMonitoring()
        }
    }
    
    func startMonitoring() {
        guard !monitoredDevices.isEmpty else { return }
        
        isMonitoring = true
        
        // Start continuous scanning for monitored devices
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ])
        }
        
        // Check device proximity every 2 seconds
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Pause scanning if screen is locked to save battery
            if self.isScreenLocked() {
                if self.centralManager.isScanning {
                    self.centralManager.stopScan()
                }
                return
            }
            
            // Resume scanning if needed
            if !self.centralManager.isScanning && self.centralManager.state == .poweredOn {
                self.centralManager.scanForPeripherals(withServices: nil, options: [
                    CBCentralManagerScanOptionAllowDuplicatesKey: true
                ])
            }
            
            self.checkDeviceProximity()
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        centralManager.stopScan()
    }
    
    private func checkDeviceProximity() {
        // Don't check if screen is already locked
        if isScreenLocked() {
            return
        }
        
        let threshold = preferences.rssiThreshold
        let lockDelay = Double(preferences.lockDelay)
        let now = Date()
        
        // Check if ALL monitored devices are out of range
        var allDevicesOutOfRange = !monitoredDevices.isEmpty
        
        for device in monitoredDevices {
            let timeSinceLastSeen = now.timeIntervalSince(device.lastSeen)
            let isInRange = timeSinceLastSeen <= 5.0 && device.rssi >= threshold
            
            if isInRange {
                // Device is in range - reset the timer for this device
                deviceOutOfRangeTime.removeValue(forKey: device.id)
                allDevicesOutOfRange = false
            } else if !isInRange && deviceOutOfRangeTime[device.id] == nil {
                // Device just went out of range - start timer
                deviceOutOfRangeTime[device.id] = now
                allDevicesOutOfRange = false // Don't lock yet, just started timer
            } else if let outOfRangeStart = deviceOutOfRangeTime[device.id] {
                // Device has been out of range - check if enough time has passed
                let timeOutOfRange = now.timeIntervalSince(outOfRangeStart)
                if timeOutOfRange < lockDelay {
                    allDevicesOutOfRange = false // Not enough time has passed yet
                }
            }
        }
        
        // Only lock if all devices have been out of range for the full delay period
        if allDevicesOutOfRange && preferences.autoLockEnabled {
            print("All devices out of range for \(lockDelay)s - locking screen")
            lockManager.lockScreen()
            // Clear the tracking after locking
            deviceOutOfRangeTime.removeAll()
        }
    }
    
    private func isScreenLocked() -> Bool {
        // Use DistributedNotificationCenter to check for screen lock events
        // For now, we'll use a simple approach: check if screen saver is running
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["-x", "ScreenSaverEngine"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0 // 0 means process found (screen locked)
        } catch {
            return false
        }
    }
    
    private func setupMonitoring() {
        // Auto-start monitoring if devices are configured
        if !monitoredDevices.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.startMonitoring()
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveMonitoredDevices() {
        if let encoded = try? JSONEncoder().encode(monitoredDevices) {
            UserDefaults.standard.set(encoded, forKey: "monitoredDevices")
        }
    }
    
    private func loadMonitoredDevices() {
        if let data = UserDefaults.standard.data(forKey: "monitoredDevices"),
           let devices = try? JSONDecoder().decode([Device].self, from: data) {
            monitoredDevices = devices
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension DeviceMonitor: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        
        switch central.state {
        case .poweredOn:
            print("Bluetooth is ready")
            if isMonitoring {
                startMonitoring()
            }
        case .poweredOff:
            print("Bluetooth is off")
            stopMonitoring()
        case .unauthorized:
            print("Bluetooth unauthorized")
        case .unsupported:
            print("Bluetooth not supported")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let rssiValue = RSSI.intValue
        
        // Filter out very weak signals
        guard rssiValue > -100 else { return }
        
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Device"
        
        // Detect device type using both name and manufacturer data
        let deviceType = Device.detectType(from: name, advertisementData: advertisementData)
        
        // Update discovered devices during scan
        if isScanning {
            if let index = discoveredDevices.firstIndex(where: { $0.id == peripheral.identifier }) {
                discoveredDevices[index].rssi = rssiValue
                discoveredDevices[index].lastSeen = Date()
            } else {
                let device = Device(
                    id: peripheral.identifier,
                    name: name,
                    type: deviceType,
                    rssi: rssiValue,
                    isMonitored: false,
                    lastSeen: Date()
                )
                discoveredDevices.append(device)
            }
        }
        
        // Update monitored devices
        if let index = monitoredDevices.firstIndex(where: { $0.id == peripheral.identifier }) {
            monitoredDevices[index].rssi = rssiValue
            monitoredDevices[index].lastSeen = Date()
            saveMonitoredDevices()
        }
        
        peripherals[peripheral.identifier] = peripheral
    }
}
