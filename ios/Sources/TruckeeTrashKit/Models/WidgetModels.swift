import Foundation

// MARK: - Widget Data Model

public struct PickupDisplayData {
    public let pickupType: DayPickupTypeString
    public let nextPickupDate: Date
    public let isToday: Bool
    public let isTomorrow: Bool
    
    public init(pickupType: DayPickupTypeString, nextPickupDate: Date, currentDate: Date = Date()) {
        self.pickupType = pickupType
        self.nextPickupDate = nextPickupDate
        
        let calendar = Calendar.current
        self.isToday = calendar.isDate(nextPickupDate, inSameDayAs: currentDate)
        self.isTomorrow = calendar.isDate(nextPickupDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)
    }
    
    public var primaryMessage: String {
        let serviceType = pickupType.userFriendlyDescription
        
        if isToday {
            return "Today is\n\(serviceType)!"
        } else if isTomorrow {
            return "Tomorrow is\n\(serviceType)"
        } else {
            return "\(serviceType)"
        }
    }
    
    public var secondaryMessage: String? {
        if isToday || isTomorrow {
            return nil
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            return formatter.string(from: nextPickupDate)
        }
    }
    
    public var compactMessage: String {
        if isToday {
            return "Today!"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            return formatter.string(from: nextPickupDate)
        }
    }
}

// MARK: - Widget Gradient Helper

public extension DayPickupTypeString {
    var widgetGradient: (start: String, end: String) {
        switch self {
        case .recycling:
            return ("#007AFF", "#0051D5") // Brighter blue
        case .yard_waste:
            return ("#34C759", "#248A3D") // Brighter green
        case .trash_only:
            return ("#48484A", "#1C1C1E") // Better contrast gray
        case .no_pickup:
            return ("#FF3B30", "#D70015") // Brighter red
        }
    }
}
