import UIKit
import Foundation

public class ImageDebugHelper {
    public static func debugImageLoading(imageName: String) -> String {
        var debug = "Debug info for '\(imageName)':\n"
        
        // Check main bundle
        if let _ = UIImage(named: imageName, in: Bundle.main, compatibleWith: nil) {
            debug += "✅ Found in main bundle\n"
        } else {
            debug += "❌ Not found in main bundle\n"
        }
        
        // Check TruckeeTrashKit bundle
        if let _ = UIImage(named: imageName, in: Bundle(for: TruckeeTrashKit.self), compatibleWith: nil) {
            debug += "✅ Found in TruckeeTrashKit bundle\n"
        } else {
            debug += "❌ Not found in TruckeeTrashKit bundle\n"
        }
        
        // Check all bundles
        var foundInBundles: [String] = []
        for bundle in Bundle.allBundles {
            if let _ = UIImage(named: imageName, in: bundle, compatibleWith: nil) {
                foundInBundles.append(bundle.bundleIdentifier ?? "unknown")
            }
        }
        
        if foundInBundles.isEmpty {
            debug += "❌ Not found in any bundle\n"
        } else {
            debug += "✅ Found in bundles: \(foundInBundles.joined(separator: ", "))\n"
        }
        
        // List main bundle contents
        if let resourcePath = Bundle.main.resourcePath {
            debug += "\nMain bundle resources: \n"
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                let imageFiles = files.filter { $0.contains(imageName) || $0.hasSuffix(".png") || $0.hasSuffix(".jpg") }
                for file in imageFiles.prefix(10) {
                    debug += "  - \(file)\n"
                }
            } catch {
                debug += "  Error reading bundle: \(error)\n"
            }
        }
        
        return debug
    }
}