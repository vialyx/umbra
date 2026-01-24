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
    
    func lockScreen(force: Bool = false) {
        // Prevent locking too frequently (unless forced for testing)
        if !force {
            if let lastLock = lastLockTime,
               Date().timeIntervalSince(lastLock) < minimumLockInterval {
                print("Lock prevented - too soon (\(Int(Date().timeIntervalSince(lastLock)))s ago)")
                return
            }
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
        // Method 1: Using pmset (works without accessibility permissions)
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["displaysleepnow"]
        
        do {
            try task.run()
            task.waitUntilExit()
            print("Screen locked successfully using pmset")
        } catch {
            print("Failed to lock screen with pmset: \(error)")
            // Fallback method
            fallbackLock()
        }
    }
    
    private func fallbackLock() {
        // Method 2: Using open command to activate screen saver
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "ScreenSaverEngine"]
        
        do {
            try task.run()
            print("Activated screen saver as fallback")
        } catch {
            print("Screen saver activation failed: \(error)")
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
        content.title = "Device Out of Range"
        content.subtitle = "Locking your Mac for security"
        content.body = "Your monitored device has moved away. Your screen will be locked in a moment."
        content.sound = .default
        
        // Add app icon to notification
        if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
           let iconURL = URL(string: "file://\(iconPath)") {
            do {
                let attachment = try UNNotificationAttachment(identifier: "icon", url: iconURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("Failed to attach icon: \(error)")
            }
        }
        
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
