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
        case other = "Other"
        
        var icon: String {
            switch self {
            case .iPhone: return "iphone"
            case .appleWatch: return "applewatch"
            case .iPad: return "ipad"
            case .airPods: return "airpods"
            case .other: return "bluetooth"
            }
        }
    }
    
    static func detectType(from name: String) -> DeviceType {
        let lowercaseName = name.lowercased()
        if lowercaseName.contains("iphone") {
            return .iPhone
        } else if lowercaseName.contains("watch") {
            return .appleWatch
        } else if lowercaseName.contains("ipad") {
            return .iPad
        } else if lowercaseName.contains("airpod") {
            return .airPods
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
