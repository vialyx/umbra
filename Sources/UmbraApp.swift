import SwiftUI
import AppKit

@main
struct UmbraApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var deviceMonitor = DeviceMonitor.shared
    @StateObject private var preferencesManager = PreferencesManager.shared
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var settingsWindow: NSWindow?
    var onboardingWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - menu bar app only
        NSApp.setActivationPolicy(.accessory)
        
        // Create menu bar item
        setupMenuBar()
        
        // Update menu bar when monitoring state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenuBarStatus),
            name: NSNotification.Name("MonitoringStateChanged"),
            object: nil
        )
        
        // Show onboarding if first launch
        checkAndShowOnboarding()
    }
    
    func checkAndShowOnboarding() {
        if !PreferencesManager.shared.hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboarding()
            }
        }
    }
    
    func showOnboarding() {
        if onboardingWindow == nil {
            let contentView = OnboardingView()
                .environmentObject(DeviceMonitor.shared)
                .environmentObject(PreferencesManager.shared)
            
            onboardingWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 560),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            onboardingWindow?.center()
            onboardingWindow?.title = "Welcome to Umbra"
            onboardingWindow?.contentView = NSHostingView(rootView: contentView)
            onboardingWindow?.isReleasedWhenClosed = false
            onboardingWindow?.level = .floating
        }
        
        onboardingWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "lock.shield", accessibilityDescription: "Umbra")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        setupMenu()
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        
        // Dynamic monitoring status
        let isMonitoring = !DeviceMonitor.shared.monitoredDevices.isEmpty
        let statusText = isMonitoring ? "Monitoring: On" : "Monitoring: Off"
        let statusMenuItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        // Show monitored device count if any
        if isMonitoring {
            let count = DeviceMonitor.shared.monitoredDevices.count
            let deviceText = count == 1 ? "device" : "devices"
            let countItem = NSMenuItem(title: "  \(count) \(deviceText) tracked", action: nil, keyEquivalent: "")
            countItem.isEnabled = false
            menu.addItem(countItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Umbra", action: #selector(quit), keyEquivalent: "q"))
        
        self.statusItem?.menu = menu
    }
    
    @objc func togglePopover() {
        // Quick status view could go here
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let contentView = SettingsView()
                .environmentObject(DeviceMonitor.shared)
                .environmentObject(PreferencesManager.shared)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.center()
            settingsWindow?.title = "Umbra Settings"
            settingsWindow?.contentView = NSHostingView(rootView: contentView)
            settingsWindow?.isReleasedWhenClosed = false
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func updateMenuBarStatus() {
        setupMenu() // Rebuild menu with current status
    }
    
    func requestPermissions() {
        // Bluetooth permissions are requested automatically by CoreBluetooth
        // Show alert about accessibility permissions needed for locking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkAccessibilityPermissions()
        }
    }
    
    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            showPermissionAlert()
        }
    }
    
    func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = "Umbra needs accessibility permissions to lock your Mac automatically. Please grant access in System Settings."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}
