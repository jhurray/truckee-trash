import XCTest
@testable import TruckeeTrashKit

final class ApiClientTests: XCTestCase {
    var apiClient: ApiClient!
    
    override func setUpWithError() throws {
        apiClient = ApiClient(baseURL: "https://truckee-trash.vercel.app")
    }
    
    override func tearDownWithError() throws {
        apiClient = nil
    }
    
    func testDateFormattingForAPI() throws {
        let date = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC
        let dateString = apiClient.formatDateForAPI(date)
        
        // Note: The exact result depends on timezone conversion
        XCTAssertFalse(dateString.isEmpty)
        XCTAssertTrue(dateString.matches(#"\d{4}-\d{2}-\d{2}"#))
    }
    
    func testDateParsingFromAPI() throws {
        let dateString = "2025-06-02"
        let date = apiClient.parseDateFromAPI(dateString)
        
        XCTAssertNotNil(date)
        
        let formatted = apiClient.formatDateForAPI(date!)
        XCTAssertEqual(formatted, dateString)
    }
    
    func testCurrentTruckeeDate() throws {
        let currentDate = apiClient.getCurrentTruckeeDate()
        
        // Should be a valid date
        XCTAssertTrue(currentDate.timeIntervalSince1970 > 0)
        
        // Should be in Truckee timezone (midnight hour)
        let calendar = Calendar.truckeeCalendar
        let components = calendar.dateComponents([.hour, .minute, .second], from: currentDate)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}