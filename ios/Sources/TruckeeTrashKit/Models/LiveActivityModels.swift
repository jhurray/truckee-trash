import Foundation
import ActivityKit

// MARK: - Live Activity Attributes

@available(iOS 16.1, *)
public struct TruckeeTrashLiveActivityAttributes: ActivityAttributes {
    public typealias ContentState = TruckeeTrashLiveActivityContentState
    
    // Static attributes that don't change during the activity
    public let pickupDay: String // e.g., "Friday"
    
    public init(pickupDay: String) {
        self.pickupDay = pickupDay
    }
}

@available(iOS 16.1, *)
public struct TruckeeTrashLiveActivityContentState: Codable, Hashable {
    // Dynamic content that can be updated
    public let pickupType: DayPickupTypeString
    public let isToday: Bool
    public let timeRemaining: String? // e.g., "2 hours", "30 minutes"
    public let nextPickupDate: Date
    
    public init(pickupType: DayPickupTypeString, isToday: Bool, timeRemaining: String?, nextPickupDate: Date) {
        self.pickupType = pickupType
        self.isToday = isToday
        self.timeRemaining = timeRemaining
        self.nextPickupDate = nextPickupDate
    }
    
    // Computed property to get display data for widgets
    public var pickupDisplayData: PickupDisplayData {
        return PickupDisplayData(pickupType: pickupType, nextPickupDate: nextPickupDate)
    }
}

// MARK: - Live Activity State

@available(iOS 16.1, *)
public enum LiveActivityState {
    case notStarted
    case active(Activity<TruckeeTrashLiveActivityAttributes>)
    case ended
    
    public var isActive: Bool {
        switch self {
        case .active:
            return true
        default:
            return false
        }
    }
}