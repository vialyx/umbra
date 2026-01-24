import Foundation
import CoreBluetooth

struct Device: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let type: DeviceType
    var rssi: Int
    var isMonitored: Bool
    var lastSeen: Date
    
    enum DeviceType: String, Codable, CaseIterable {
        case iPhone
        case appleWatch = "Apple Watch"
        case iPad
        case airPods = "AirPods"
        case mac = "Mac"
        case homePod = "HomePod"
        case appleTV = "Apple TV"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .iPhone: return "iphone"
            case .appleWatch: return "applewatch"
            case .iPad: return "ipad"
            case .airPods: return "airpods"
            case .mac: return "laptopcomputer"
            case .homePod: return "homepod"
            case .appleTV: return "appletv"
            case .other: return "bluetooth"
            }
        }
    }
    
    static func detectType(from name: String) -> DeviceType {
        let lowercaseName = name.lowercased()
        
        // iPhone detection
        if lowercaseName.contains("iphone") || 
           lowercaseName.range(of: "\\biphone\\b", options: .regularExpression) != nil ||
           lowercaseName.range(of: "'s iphone", options: .regularExpression) != nil {
            return .iPhone
        }
        
        // Apple Watch detection
        if lowercaseName.contains("watch") || 
           lowercaseName.contains("apple watch") {
            return .appleWatch
        }
        
        // iPad detection
        if lowercaseName.contains("ipad") {
            return .iPad
        }
        
        // AirPods detection (including AirPods Pro, Max, etc.)
        if lowercaseName.contains("airpod") || 
           lowercaseName.contains("airpods") ||
           lowercaseName.contains("air pod") {
            return .airPods
        }
        
        // Mac detection
        if lowercaseName.contains("macbook") ||
           lowercaseName.contains("imac") ||
           lowercaseName.contains("mac mini") ||
           lowercaseName.contains("mac pro") ||
           lowercaseName.contains("mac studio") {
            return .mac
        }
        
        // HomePod detection
        if lowercaseName.contains("homepod") {
            return .homePod
        }
        
        // Apple TV detection
        if lowercaseName.contains("apple tv") ||
           lowercaseName.contains("appletv") {
            return .appleTV
        }
        
        return .other
    }
    
    var signalStrength: SignalStrength {
        switch rssi {
        case -50...0: return .excellent
        case -60..<(-50): return .good
        case -70..<(-60): return .fair
        case -80..<(-70): return .weak
        default: return .veryWeak
        }
    }
    
    enum SignalStrength: String {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case weak = "Weak"
        case veryWeak = "Very Weak"
        
        var color: String {
            switch self {
            case .excellent: return "green"
            case .good: return "green"
            case .fair: return "yellow"
            case .weak: return "orange"
            case .veryWeak: return "red"
            }
        }
    }
}
