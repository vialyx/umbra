import Foundation
import Combine
import ServiceManagement

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
        // This will be handled by the installer with a LaunchAgent
        // For now, we'll use ServiceManagement framework
        #if !DEBUG
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
        #endif
    }
}
