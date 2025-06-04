import Foundation

public extension Date {
    /// Get the next occurrence of a specific weekday (1 = Monday, 7 = Sunday)
    /// This always finds the NEXT occurrence, not today even if today matches
    func nextOccurrence(of weekday: Int, in timeZone: TimeZone = TimeZone(identifier: "America/Los_Angeles")!) -> Date {
        let currentCalendar = Calendar.current
        
        // Convert current date to Truckee timezone
        let currentComponents = currentCalendar.dateComponents(in: timeZone, from: self)
        let currentWeekday = currentComponents.weekday! // 1 = Sunday, 7 = Saturday
        
        // Convert to Monday = 1, Sunday = 7 format
        let adjustedCurrentWeekday = currentWeekday == 1 ? 7 : currentWeekday - 1
        let targetWeekday = weekday
        
        var daysToAdd: Int
        
        if adjustedCurrentWeekday == targetWeekday {
            // If today is the target weekday, its today
            daysToAdd = 0
        } else if adjustedCurrentWeekday < targetWeekday {
            // Target is later this week
            daysToAdd = targetWeekday - adjustedCurrentWeekday
        } else {
            // Target is next week
            daysToAdd = 7 - adjustedCurrentWeekday + targetWeekday
        }
        
        return currentCalendar.date(byAdding: .day, value: daysToAdd, to: self) ?? self
    }
    
    /// Check if this date is a weekday (Monday-Friday) in Truckee timezone
    func isWeekday(in timeZone: TimeZone = TimeZone(identifier: "America/Los_Angeles")!) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        return weekday >= 2 && weekday <= 6 // Monday = 2, Friday = 6
    }
    
    /// Check if this date is a weekend (Saturday-Sunday) in Truckee timezone
    func isWeekend(in timeZone: TimeZone = TimeZone(identifier: "America/Los_Angeles")!) -> Bool {
        return !isWeekday(in: timeZone)
    }
}

public extension Calendar {
    /// Get a calendar configured for Truckee timezone
    static var truckeeCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }
}
