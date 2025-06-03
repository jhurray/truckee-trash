import XCTest
@testable import TruckeeTrashKit

final class DateUtilsTests: XCTestCase {
    
    func testNextOccurrenceOfWeekday() throws {
        let calendar = Calendar.truckeeCalendar
        
        // Create a specific test date: Monday, June 2, 2025
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 2 // This is a Monday
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let monday = calendar.date(from: components)!
        
        // Test getting next Friday (weekday 5)
        let nextFriday = monday.nextOccurrence(of: 5)
        let fridayComponents = calendar.dateComponents([.year, .month, .day], from: nextFriday)
        
        XCTAssertEqual(fridayComponents.year, 2025)
        XCTAssertEqual(fridayComponents.month, 6)
        XCTAssertEqual(fridayComponents.day, 6) // June 6, 2025 is Friday
        
        // Test getting next Monday (should be same day since it's already Monday)
        let nextMonday = monday.nextOccurrence(of: 1)
        let mondayComponents = calendar.dateComponents([.year, .month, .day], from: nextMonday)
        
        XCTAssertEqual(mondayComponents.year, 2025)
        XCTAssertEqual(mondayComponents.month, 6)
        XCTAssertEqual(mondayComponents.day, 2) // Same day
    }
    
    func testIsWeekdayAndWeekend() throws {
        let calendar = Calendar.truckeeCalendar
        
        // Create Monday, June 2, 2025
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 2 // Monday
        
        let monday = calendar.date(from: components)!
        XCTAssertTrue(monday.isWeekday())
        XCTAssertFalse(monday.isWeekend())
        
        // Create Saturday, June 7, 2025
        components.day = 7 // Saturday
        let saturday = calendar.date(from: components)!
        XCTAssertFalse(saturday.isWeekday())
        XCTAssertTrue(saturday.isWeekend())
        
        // Create Sunday, June 8, 2025
        components.day = 8 // Sunday
        let sunday = calendar.date(from: components)!
        XCTAssertFalse(sunday.isWeekday())
        XCTAssertTrue(sunday.isWeekend())
    }
    
    func testTruckeeCalendar() throws {
        let calendar = Calendar.truckeeCalendar
        
        XCTAssertEqual(calendar.timeZone.identifier, "America/Los_Angeles")
        XCTAssertEqual(calendar.identifier, .gregorian)
    }
}