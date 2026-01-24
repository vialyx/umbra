import Foundation
import AppKit
import UserNotifications

class LockManager {
    static let shared = LockManager()
    
    private var lastLockTime: Date?
    private let minimumLockInterval: TimeInterval = 60 // Prevent rapid locks
    private var notificationsAvailable = false
    
    private init() {
        // Only request notifications if running from app bundle
        if Bundle.main.bundleIdentifier != nil {
            requestNotificationPermissions()
            notificationsAvailable = true
        }
    }
    
    func lockScreen() {
        // Prevent locking too frequently
        if let lastLock = lastLockTime,
           Date().timeIntervalSince(lastLock) < minimumLockInterval {
            return
        }
        
        lastLockTime = Date()
        
        // Send notification before locking (if available)
        if notificationsAvailable {
            sendLockNotification()
            
            // Wait a moment for notification to show
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performLock()
            }
        } else {
            performLock()
        }
    }
    
    private func performLock() {
        // Method 1: Using CGSession (most reliable)
        let task = Process()
        task.launchPath = "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"
        task.arguments = ["-suspend"]
        
        do {
            try task.run()
            print("Screen locked successfully")
        } catch {
            print("Failed to lock screen: \(error)")
            // Fallback method
            fallbackLock()
        }
    }
    
    private func fallbackLock() {
        // Method 2: Using AppleScript
        let script = """
        tell application "System Events"
            keystroke "q" using {command down, control down}
        end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func sendLockNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Umbra"
        content.body = "Device out of range. Locking your Mac..."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}
