import Foundation

public struct ReportedWeekInfo: Codable, Hashable {
    public let startDate: String // "YYYY-MM-DD"
    public let endDate: String   // "YYYY-MM-DD"
    
    public init(startDate: String, endDate: String) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

public enum WeekStatusString: String, Codable, Hashable, CaseIterable {
    case recycling_week
    case yard_waste_week
    case normal_trash_week
    case no_pickup_week
    
    public var displayName: String {
        switch self {
        case .recycling_week:
            return "Recycling Week"
        case .yard_waste_week:
            return "Yard Waste Week"
        case .normal_trash_week:
            return "Normal Trash Week"
        case .no_pickup_week:
            return "No Pickup Week"
        }
    }
    
    public var color: String {
        switch self {
        case .recycling_week:
            return "blue"
        case .yard_waste_week:
            return "green"
        case .normal_trash_week:
            return "gray"
        case .no_pickup_week:
            return "red"
        }
    }
}

public struct RelevantWeekStatusInfo: Codable, Hashable, Identifiable {
    // To make it Identifiable for potential lists, provide an ID
    public var id: String { reportedWeek.startDate + weekStatus.rawValue }
    public let reportedWeek: ReportedWeekInfo
    public let weekStatus: WeekStatusString
    public let specialPickupDayInWeek: String? // "YYYY-MM-DD"
    public let specialPickupTypeOnDate: DayPickupTypeString? // "recycling" or "yard_waste"
    
    public init(
        reportedWeek: ReportedWeekInfo,
        weekStatus: WeekStatusString,
        specialPickupDayInWeek: String?,
        specialPickupTypeOnDate: DayPickupTypeString?
    ) {
        self.reportedWeek = reportedWeek
        self.weekStatus = weekStatus
        self.specialPickupDayInWeek = specialPickupDayInWeek
        self.specialPickupTypeOnDate = specialPickupTypeOnDate
    }
}