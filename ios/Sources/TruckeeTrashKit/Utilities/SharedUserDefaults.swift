import Foundation

public class SharedUserDefaults {
    
    // MARK: - App Group Configuration
    
    /// The App Group identifier - you'll need to set this up in Xcode
    /// Format: group.com.yourcompany.truckeetrash
    private static let appGroupIdentifier = "group.app.truckeetrash"
    
    /// Shared UserDefaults container accessible by both app and widget
    public static let shared: UserDefaults = {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            fatalError("Failed to create shared UserDefaults with App Group: \(appGroupIdentifier)")
        }
        return sharedDefaults
    }()
    
    // MARK: - Convenience Properties
    
    /// User's selected pickup day (1-5, Monday-Friday)
    public static var selectedPickupDay: Int {
        get {
            let value = shared.object(forKey: "selectedPickupDay") as? Int
            return value ?? 5 // Default to Friday
        }
        set {
            shared.set(newValue, forKey: "selectedPickupDay")
        }
    }
    
    /// Whether notifications are enabled
    public static var notificationsEnabled: Bool {
        get { shared.bool(forKey: "notificationsEnabled") }
        set { shared.set(newValue, forKey: "notificationsEnabled") }
    }
    
    /// Notification preference setting
    public static var notificationPreference: String {
        get { shared.string(forKey: "notificationPreference") ?? "evening_before" }
        set { shared.set(newValue, forKey: "notificationPreference") }
    }
    
    /// Whether onboarding has been completed
    public static var hasCompletedOnboarding: Bool {
        get { shared.bool(forKey: "hasCompletedOnboarding") }
        set { shared.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    
    #if DEBUG
    /// Debug test date
    public static var debugTestDate: Date? {
        get { shared.object(forKey: "debugTestDate") as? Date }
        set {
            if let date = newValue {
                shared.set(date, forKey: "debugTestDate")
                shared.set(true, forKey: "debugTestModeEnabled")
            } else {
                shared.removeObject(forKey: "debugTestDate")
                shared.removeObject(forKey: "debugTestModeEnabled")
            }
        }
    }
    
    /// Whether debug test mode is enabled
    public static var debugTestModeEnabled: Bool {
        get { shared.bool(forKey: "debugTestModeEnabled") }
    }
    #endif
    
    // MARK: - Migration Helper
    
    /// Migrate existing UserDefaults.standard data to shared container
    public static func migrateFromStandardUserDefaults() {
        let standardDefaults = UserDefaults.standard
        let keys = ["selectedPickupDay", "notificationsEnabled", "notificationPreference", "hasCompletedOnboarding"]
        
        for key in keys {
            if let value = standardDefaults.object(forKey: key) {
                shared.set(value, forKey: key)
                print("✅ Migrated \(key) to shared UserDefaults")
            }
        }
        
        #if DEBUG
        // Migrate debug keys
        if let debugDate = standardDefaults.object(forKey: "debugTestDate") {
            shared.set(debugDate, forKey: "debugTestDate")
        }
        if standardDefaults.object(forKey: "debugTestModeEnabled") != nil {
            shared.set(standardDefaults.bool(forKey: "debugTestModeEnabled"), forKey: "debugTestModeEnabled")
        }
        #endif
    }
    
    public static func clearAll() {
        let keys = ["selectedPickupDay", "notificationsEnabled", "notificationPreference", "hasCompletedOnboarding"]
        
        for key in keys {
            shared.removeObject(forKey: key)
        }
        
        #if DEBUG
        shared.removeObject(forKey: "debugTestDate")
        shared.removeObject(forKey: "debugTestModeEnabled")
        #endif
    }
}