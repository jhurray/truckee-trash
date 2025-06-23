import Foundation
import UserNotifications
@testable import NotificationsService

public class MockNotificationCenter: UserNotificationCenterProtocol {
    public var requestAuthorizationCalled = false
    public var authorizationGranted = true
    public var authorizationError: Error?
    public var authorizationStatus: UNAuthorizationStatus = .authorized
    
    public var getNotificationSettingsCalled = false
    public var addNotificationCalled = false
    public var removePendingCalled = false
    public var removeAllCalled = false
    public var getPendingCalled = false
    
    public var pendingRequests: [UNNotificationRequest] = []
    public var addedRequests: [UNNotificationRequest] = []
    public var removedIdentifiers: [String] = []
    
    public func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        requestAuthorizationCalled = true
        completionHandler(authorizationGranted, authorizationError)
    }
    
    public func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        getNotificationSettingsCalled = true
        // For business logic testing, we shouldn't need the actual settings object
        // The tests can directly set the NotificationsService.isAuthorized property
        // This method should not be called in simplified tests
        fatalError("Use direct property setting for business logic tests instead of getNotificationSettings")
    }
    
    public func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        addNotificationCalled = true
        addedRequests.append(request)
        pendingRequests.append(request)
        completionHandler?(nil)
    }
    
    public func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removePendingCalled = true
        removedIdentifiers.append(contentsOf: identifiers)
        pendingRequests.removeAll { request in
            identifiers.contains(request.identifier)
        }
    }
    
    public func removeAllPendingNotificationRequests() {
        removeAllCalled = true
        pendingRequests.removeAll()
    }
    
    public func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        getPendingCalled = true
        completionHandler(pendingRequests)
    }
    
    public func reset() {
        requestAuthorizationCalled = false
        getNotificationSettingsCalled = false
        addNotificationCalled = false
        removePendingCalled = false
        removeAllCalled = false
        getPendingCalled = false
        pendingRequests.removeAll()
        addedRequests.removeAll()
        removedIdentifiers.removeAll()
    }
}

