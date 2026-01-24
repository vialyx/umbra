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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - menu bar app only
        NSApp.setActivationPolicy(.accessory)
        
        // Create menu bar item
        setupMenuBar()
        
        // Request permissions
        requestPermissions()
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
        menu.addItem(NSMenuItem(title: "Monitoring: Off", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Umbra", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
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
