import Foundation
@testable import TruckeeTrashKit

public class MockAPIClient: ApiClient {
    public var currentTruckeeDate = Date()
    public var fetchResults: [Date: Result<DayPickupInfo, ApiError>] = [:]
    public var fetchCalled = false
    public var fetchedDates: [Date] = []
    
    public init() {
        super.init(baseURL: "https://mock.test")
    }
    
    public override func getCurrentTruckeeDate() -> Date {
        return currentTruckeeDate
    }
    
    public override func fetchDayPickupType(for date: Date, completion: @escaping (Result<DayPickupInfo, ApiError>) -> Void) {
        fetchCalled = true
        fetchedDates.append(date)
        
        // Find the result for this date, or default to trash_only
        let result = fetchResults[date] ?? .success(DayPickupInfo(date: formatDate(date), pickupType: .trash_only))
        
        // Simulate async behavior
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    public func setResult(for date: Date, result: Result<DayPickupInfo, ApiError>) {
        fetchResults[date] = result
    }
    
    public func reset() {
        fetchCalled = false
        fetchedDates.removeAll()
        fetchResults.removeAll()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return formatter.string(from: date)
    }
}
