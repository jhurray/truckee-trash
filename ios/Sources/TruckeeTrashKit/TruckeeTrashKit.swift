import Foundation

// Main module file for TruckeeTrashKit
// This file serves as the entry point for the framework

public final class TruckeeTrashKit {
    public static let shared = TruckeeTrashKit()
    
    private init() {}
    
    public let apiClient = ApiClient()
    
    // Version info
    public static let version = "1.0.0"
    public static let buildNumber = "1"
}