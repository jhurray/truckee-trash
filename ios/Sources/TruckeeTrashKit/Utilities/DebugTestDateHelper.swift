import Foundation

#if DEBUG
public class DebugTestDateHelper {
    
    /// Gets the current test date if debug mode is enabled, otherwise returns the current date
    public static func getCurrentDate() -> Date {
        if SharedUserDefaults.debugTestModeEnabled,
           let testDate = SharedUserDefaults.debugTestDate {
            return testDate
        }
        return Date()
    }
    
    /// Checks if debug test mode is currently enabled
    public static var isTestModeEnabled: Bool {
        return SharedUserDefaults.debugTestModeEnabled
    }
    
    /// Gets the test date if available
    public static var testDate: Date? {
        guard isTestModeEnabled else { return nil }
        return SharedUserDefaults.debugTestDate
    }
    
    /// Clears debug test date (typically called when app goes to production)
    public static func clearTestDate() {
        SharedUserDefaults.debugTestDate = nil
    }
}
#endif