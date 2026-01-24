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
            case .other: return "antenna.radiowaves.left.and.right"
            }
        }
    }
    
    static func detectType(from name: String, advertisementData: [String: Any]? = nil) -> DeviceType {
        let lowercaseName = name.lowercased()
        
        // Check manufacturer data for Apple devices (Company ID: 0x004C = 76)
        if let manufacturerData = advertisementData?[CBAdvertisementDataManufacturerDataKey] as? Data,
           manufacturerData.count >= 2 {
            let companyId = UInt16(manufacturerData[0]) | (UInt16(manufacturerData[1]) << 8)
            
            // Apple company identifier
            if companyId == 0x004C {
                // This is an Apple device - try to determine which one
                // If name doesn't specify, default to iPhone (most common)
                if lowercaseName.contains("watch") {
                    return .appleWatch
                } else if lowercaseName.contains("ipad") {
                    return .iPad
                } else if lowercaseName.contains("airpod") {
                    return .airPods
                } else if lowercaseName.contains("macbook") || lowercaseName.contains("imac") || 
                          lowercaseName.contains("mac mini") || lowercaseName.contains("mac pro") {
                    return .mac
                } else if lowercaseName.contains("homepod") {
                    return .homePod
                } else if lowercaseName.contains("apple tv") || lowercaseName.contains("appletv") {
                    return .appleTV
                } else if !lowercaseName.contains("unknown") && lowercaseName != "unknown device" {
                    // Apple device with custom name (likely iPhone)
                    return .iPhone
                }
            }
        }
        
        // Explicit name-based detection
        if lowercaseName.contains("iphone") {
            return .iPhone
        }
        
        if lowercaseName.contains("watch") || lowercaseName.contains("apple watch") {
            return .appleWatch
        }
        
        if lowercaseName.contains("ipad") {
            return .iPad
        }
        
        if lowercaseName.contains("airpod") || lowercaseName.contains("airpods") {
            return .airPods
        }
        
        if lowercaseName.contains("macbook") || lowercaseName.contains("imac") ||
           lowercaseName.contains("mac mini") || lowercaseName.contains("mac pro") ||
           lowercaseName.contains("mac studio") {
            return .mac
        }
        
        if lowercaseName.contains("homepod") {
            return .homePod
        }
        
        if lowercaseName.contains("apple tv") || lowercaseName.contains("appletv") {
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
