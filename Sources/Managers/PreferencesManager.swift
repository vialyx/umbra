import Foundation
import Combine

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    @Published var autoLockEnabled: Bool {
        didSet { UserDefaults.standard.set(autoLockEnabled, forKey: "autoLockEnabled") }
    }
    
    @Published var rssiThreshold: Int {
        didSet { UserDefaults.standard.set(rssiThreshold, forKey: "rssiThreshold") }
    }
    
    @Published var lockDelay: Int {
        didSet { UserDefaults.standard.set(lockDelay, forKey: "lockDelay") }
    }
    
    @Published var launchAtLogin: Bool {
        didSet { 
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLaunchAtLogin()
        }
    }
    
    @Published var showNotifications: Bool {
        didSet { UserDefaults.standard.set(showNotifications, forKey: "showNotifications") }
    }
    
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    
    private init() {
        self.autoLockEnabled = UserDefaults.standard.object(forKey: "autoLockEnabled") as? Bool ?? true
        self.rssiThreshold = UserDefaults.standard.object(forKey: "rssiThreshold") as? Int ?? -70
        self.lockDelay = UserDefaults.standard.object(forKey: "lockDelay") as? Int ?? 10
        self.launchAtLogin = UserDefaults.standard.object(forKey: "launchAtLogin") as? Bool ?? true
        self.showNotifications = UserDefaults.standard.object(forKey: "showNotifications") as? Bool ?? true
        self.hasCompletedOnboarding = UserDefaults.standard.object(forKey: "hasCompletedOnboarding") as? Bool ?? false
    }
    
    private func updateLaunchAtLogin() {
        // Launch at login is handled by the LaunchAgent installed in ~/Library/LaunchAgents/
        // The installer creates com.umbra.app.plist which handles auto-start
        // We don't need to use SMAppService as it would create duplicate instances
        
        // For future: Could modify the LaunchAgent plist's RunAtLoad value instead
        // For now, this setting is cosmetic - the LaunchAgent always runs at login
        print("Launch at login setting: \(launchAtLogin) (handled by LaunchAgent)")
    }
}
