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
            return "Today is \(serviceType)!"
        } else if isTomorrow {
            return "Tomorrow is \(serviceType)"
        } else {
            return "Next: \(serviceType)"
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
            return ("#0066CC", "#004499")
        case .yard_waste:
            return ("#228B22", "#006400")
        case .trash_only:
            return ("#2F2F2F", "#1A1A1A")
        case .no_pickup:
            return ("#8B0000", "#550000")
        }
    }
}