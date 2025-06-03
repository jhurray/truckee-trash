import Foundation

public enum DayPickupTypeString: String, Codable, Hashable, CaseIterable {
    case recycling
    case yard_waste
    case trash_only
    case no_pickup
    
    public var displayName: String {
        switch self {
        case .recycling:
            return "Recycling Day"
        case .yard_waste:
            return "Yard Waste Day"
        case .trash_only:
            return "Trash Day"
        case .no_pickup:
            return "No Pickup"
        }
    }
    
    public var description: String {
        switch self {
        case .recycling:
            return "Recycling and regular trash pickup"
        case .yard_waste:
            return "Yard waste and regular trash pickup"
        case .trash_only:
            return "Regular trash pickup only"
        case .no_pickup:
            return "No pickup services"
        }
    }
}

public struct DayPickupInfo: Codable, Hashable, Identifiable {
    public var id: String { date }
    public let date: String // "YYYY-MM-DD"
    public let pickupType: DayPickupTypeString
    
    public init(date: String, pickupType: DayPickupTypeString) {
        self.date = date
        self.pickupType = pickupType
    }
}