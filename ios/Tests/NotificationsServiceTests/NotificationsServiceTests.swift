import XCTest
import UserNotifications
@testable import NotificationsService
@testable import TruckeeTrashKit

@MainActor
final class NotificationsServiceTests: XCTestCase {
    
    var notificationService: NotificationsService!
    var mockNotificationCenter: MockNotificationCenter!
    var mockUserDefaults: MockUserDefaults!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockNotificationCenter = MockNotificationCenter()
        mockUserDefaults = MockUserDefaults()
        mockAPIClient = MockAPIClient()
        
        // Set up default user preferences
        mockUserDefaults.set(5, forKey: "selectedPickupDay") // Friday
        mockUserDefaults.set(true, forKey: "notificationsEnabled")
        mockUserDefaults.set("evening_before", forKey: "notificationPreference")
        
        notificationService = NotificationsService(
            apiClient: mockAPIClient,
            notificationCenter: mockNotificationCenter,
            userDefaults: mockUserDefaults,
            skipInitialAuthCheck: true
        )
        
        // Set up authorization state directly for business logic testing
        notificationService.isAuthorized = true
        notificationService.authorizationStatus = .authorized
    }
    
    override func tearDown() {
        notificationService = nil
        mockNotificationCenter = nil
        mockUserDefaults = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    // MARK: - Authorization Tests
    
    func testRequestPermissionSuccess() {
        mockNotificationCenter.authorizationGranted = true
        
        let expectation = XCTestExpectation(description: "Permission granted")
        
        notificationService.requestPermission { granted in
            XCTAssertTrue(granted)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockNotificationCenter.requestAuthorizationCalled)
        XCTAssertTrue(notificationService.isAuthorized)
    }
    
    func testRequestPermissionDenied() {
        mockNotificationCenter.authorizationGranted = false
        
        let expectation = XCTestExpectation(description: "Permission denied")
        
        notificationService.requestPermission { granted in
            XCTAssertFalse(granted)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockNotificationCenter.requestAuthorizationCalled)
        XCTAssertFalse(notificationService.isAuthorized)
    }
    
    // MARK: - Notification Scheduling Tests
    
    func testSchedulePickupRemindersWithoutAuthorization() {
        mockNotificationCenter.authorizationStatus = .denied
        notificationService.isAuthorized = false
        
        notificationService.schedulePickupReminders()
        
        // Should not attempt to schedule notifications
        XCTAssertFalse(mockNotificationCenter.getPendingCalled)
        XCTAssertFalse(mockAPIClient.fetchCalled)
    }
    
    func testSchedulePickupRemindersWithNotificationsDisabled() {
        mockUserDefaults.set(false, forKey: "notificationsEnabled")
        
        notificationService.schedulePickupReminders()
        
        // Should cancel existing notifications but not schedule new ones
        XCTAssertTrue(mockNotificationCenter.getPendingCalled)
        XCTAssertFalse(mockAPIClient.fetchCalled)
    }
    
    func testSchedulePickupRemindersSuccess() {
        let expectation = XCTestExpectation(description: "Notifications scheduled")
        
        // Set up mock API responses
        let currentDate = Date()
        mockAPIClient.currentTruckeeDate = currentDate
        
        // Setup results for multiple weeks
        for weekOffset in 0..<52 {
            let offsetDate = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: currentDate)!
            let pickupDate = offsetDate.nextOccurrence(of: 5) // Friday
            let pickupInfo = DayPickupInfo(date: "2023-01-01", pickupType: weekOffset % 2 == 0 ? .trash_only : .recycling)
            mockAPIClient.setResult(for: pickupDate, result: .success(pickupInfo))
        }
        
        notificationService.schedulePickupReminders()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Should have scheduled notifications (52 would be 1 year, but let's check what's actually scheduled)
            XCTAssertGreaterThan(self.mockNotificationCenter.addedRequests.count, 0)
            XCTAssertTrue(self.mockAPIClient.fetchCalled)
            XCTAssertGreaterThan(self.mockAPIClient.fetchedDates.count, 0)
            
            // Check that last schedule date was stored
            XCTAssertNotNil(self.mockUserDefaults.object(forKey: "lastNotificationScheduleDate"))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Notification Content Tests
    
    func testNotificationContentForEveningBefore() {
        let expectation = XCTestExpectation(description: "Evening notification content")
        
        // Verify preconditions
        XCTAssertTrue(notificationService.isAuthorized, "Service should be authorized")
        XCTAssertTrue(mockUserDefaults.bool(forKey: "notificationsEnabled"), "Notifications should be enabled")
        
        mockUserDefaults.set("evening_before", forKey: "notificationPreference")
        
        let currentDate = Date()
        let pickupDate = currentDate.nextOccurrence(of: 5) // Friday
        let pickupInfo = DayPickupInfo(date: "2023-01-01", pickupType: .recycling)
        mockAPIClient.setResult(for: pickupDate, result: .success(pickupInfo))
        mockAPIClient.currentTruckeeDate = currentDate
        
        notificationService.schedulePickupReminders()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertGreaterThan(self.mockNotificationCenter.addedRequests.count, 0, "Should have scheduled at least one notification")
            
            if let addedRequest = self.mockNotificationCenter.addedRequests.first {
                XCTAssertEqual(addedRequest.content.title, "Trash Day Reminder")
                XCTAssertFalse(addedRequest.content.body.isEmpty, "Body should not be empty")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNotificationContentForMorningOf() {
        let expectation = XCTestExpectation(description: "Morning notification content")
        
        mockUserDefaults.set("morning_of", forKey: "notificationPreference")
        
        let currentDate = Date()
        let pickupDate = currentDate.nextOccurrence(of: 5) // Friday
        let pickupInfo = DayPickupInfo(date: "2023-01-01", pickupType: .yard_waste)
        mockAPIClient.setResult(for: pickupDate, result: .success(pickupInfo))
        mockAPIClient.currentTruckeeDate = currentDate
        
        notificationService.schedulePickupReminders()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let addedRequest = self.mockNotificationCenter.addedRequests.first
            XCTAssertNotNil(addedRequest)
            XCTAssertEqual(addedRequest?.content.title, "Trash Day Reminder")
            XCTAssertEqual(addedRequest?.content.body, "Today is Yard Waste Day. Don't forget your yard waste!")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNotificationContentForAPIFailure() {
        let expectation = XCTestExpectation(description: "API failure notification content")
        
        let currentDate = Date()
        let pickupDate = currentDate.nextOccurrence(of: 5) // Friday
        mockAPIClient.setResult(for: pickupDate, result: .failure(.networkError(NSError(domain: "test", code: -1, userInfo: nil))))
        mockAPIClient.currentTruckeeDate = currentDate
        
        notificationService.schedulePickupReminders()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let addedRequest = self.mockNotificationCenter.addedRequests.first
            XCTAssertNotNil(addedRequest)
            XCTAssertEqual(addedRequest?.content.title, "Trash Day Reminder")
            XCTAssertEqual(addedRequest?.content.body, "Trash day reminder! Open Truckee Trash to see details for tomorrow.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Refresh Logic Tests
    
    func testRefreshNotificationsWhenLowCount() {
        // Set up existing notifications (less than 20)
        for i in 0..<10 {
            let identifier = "TruckeeTrashPickupReminder_\(i)"
            let content = UNMutableNotificationContent()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            mockNotificationCenter.pendingRequests.append(request)
        }
        
        let expectation = XCTestExpectation(description: "Notifications refreshed due to low count")
        
        notificationService.refreshNotificationsIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Should trigger a refresh
            XCTAssertTrue(self.mockAPIClient.fetchCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRefreshNotificationsWhenOld() {
        // Set last schedule date to 35 days ago
        let oldDate = Calendar.current.date(byAdding: .day, value: -35, to: Date())!
        mockUserDefaults.set(oldDate, forKey: "lastNotificationScheduleDate")
        
        // Set up sufficient notifications (more than 20)
        for i in 0..<25 {
            let identifier = "TruckeeTrashPickupReminder_\(i)"
            let content = UNMutableNotificationContent()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            mockNotificationCenter.pendingRequests.append(request)
        }
        
        let expectation = XCTestExpectation(description: "Notifications refreshed due to age")
        
        notificationService.refreshNotificationsIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Should trigger a refresh due to age
            XCTAssertTrue(self.mockAPIClient.fetchCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNoRefreshWhenNotNeeded() {
        // Set recent schedule date
        mockUserDefaults.set(Date(), forKey: "lastNotificationScheduleDate")
        
        // Set up sufficient notifications (more than 20)
        for i in 0..<25 {
            let identifier = "TruckeeTrashPickupReminder_\(i)"
            let content = UNMutableNotificationContent()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            mockNotificationCenter.pendingRequests.append(request)
        }
        
        let expectation = XCTestExpectation(description: "No refresh needed")
        
        notificationService.refreshNotificationsIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Should not trigger a refresh
            XCTAssertFalse(self.mockAPIClient.fetchCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Notification Cancellation Tests
    
    func testCancelAllNotifications() {
        // Add some existing notifications
        for i in 0..<5 {
            let identifier = "TestNotification_\(i)"
            let content = UNMutableNotificationContent()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            mockNotificationCenter.pendingRequests.append(request)
        }
        
        notificationService.cancelAllNotifications()
        
        XCTAssertTrue(mockNotificationCenter.removeAllCalled)
        XCTAssertEqual(mockNotificationCenter.pendingRequests.count, 0)
    }
    
    func testGetPendingNotifications() {
        // Add some notifications
        for i in 0..<3 {
            let identifier = "TestNotification_\(i)"
            let content = UNMutableNotificationContent()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            mockNotificationCenter.pendingRequests.append(request)
        }
        
        let expectation = XCTestExpectation(description: "Get pending notifications")
        
        notificationService.getPendingNotifications { requests in
            XCTAssertEqual(requests.count, 3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockNotificationCenter.getPendingCalled)
    }
}