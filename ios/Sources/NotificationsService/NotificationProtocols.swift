import Foundation
import UserNotifications

// Protocol for UserNotificationCenter to enable mocking
public protocol UserNotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
}

// Make UNUserNotificationCenter conform to our protocol
extension UNUserNotificationCenter: UserNotificationCenterProtocol {}

// Protocol for UserDefaults to enable mocking
public protocol UserDefaultsProtocol {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func integer(forKey defaultName: String) -> Int
    func bool(forKey defaultName: String) -> Bool
}

// Make UserDefaults conform to our protocol
extension UserDefaults: UserDefaultsProtocol {}