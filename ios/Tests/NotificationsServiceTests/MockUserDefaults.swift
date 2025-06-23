import Foundation
@testable import NotificationsService

public class MockUserDefaults: UserDefaultsProtocol {
    private var storage: [String: Any] = [:]
    
    public init() {}
    
    public func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }
    
    public func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    public func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }
    
    public func integer(forKey defaultName: String) -> Int {
        return storage[defaultName] as? Int ?? 0
    }
    
    public func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }
    
    public func reset() {
        storage.removeAll()
    }
}