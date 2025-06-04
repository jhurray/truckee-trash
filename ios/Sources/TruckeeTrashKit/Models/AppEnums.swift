import Foundation

// MARK: - Weekday Enum

public enum Weekday: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    
    public var displayName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        }
    }
    
    public var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        }
    }
}

// MARK: - Notification Preference Enum

public enum NotificationPreference: String, CaseIterable {
    case none = "none"
    case eveningBefore = "evening_before"
    case morningOf = "morning_of"
    
    public var title: String {
        switch self {
        case .none:
            return "No Notifications"
        case .eveningBefore:
            return "Evening Before"
        case .morningOf:
            return "Morning Of"
        }
    }
    
    public var description: String {
        switch self {
        case .none:
            return "I'll check the app myself"
        case .eveningBefore:
            return "Remind me the night before pickup"
        case .morningOf:
            return "Remind me the morning of pickup"
        }
    }
}

// MARK: - Onboarding Step Enum

public enum OnboardingStep: Int, CaseIterable {
    case pickupDay = 0
    case notifications = 1
    case completing = 2
}