import SwiftUI

public struct PickupSymbolView: View {
    public let pickupType: DayPickupTypeString
    public let size: CGFloat
    public let forceEmoji: Bool
    public let isWidget: Bool
    private let imageMultiplier: CGFloat = 1.5
    
    public init(
        pickupType: DayPickupTypeString,
        size: CGFloat,
        forceEmoji: Bool = false,
        isWidget: Bool = false
    ) {
        self.pickupType = pickupType
        self.size = size
        self.forceEmoji = forceEmoji
        self.isWidget = isWidget
    }

    public var body: some View {
        ZStack {
            if forceEmoji {
                // Force emoji mode
                Text(pickupType.emoji)
                    .font(.system(size: size))
            } else if !pickupType.imageName().isEmpty {
                // Try to load custom images first (main priority)
                Group {
                    if let uiImage = loadImageFromAnyBundle(named: pickupType.imageName()) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size * imageMultiplier, height: size * imageMultiplier)
                    } else if let sfSymbolName = pickupType.sfSymbolName {
                        // Fallback to SF Symbol if image not found
                        Image(systemName: sfSymbolName)
                            .font(.system(size: size * 0.8))
                            .foregroundColor(isWidget ? .white : symbolColor)
                    } else {
                        // Final fallback to emoji
                        Text(pickupType.emoji)
                            .font(.system(size: size))
                    }
                }
            } else if let sfSymbolName = pickupType.sfSymbolName {
                // Use SF Symbol if no image name
                Image(systemName: sfSymbolName)
                    .font(.system(size: size * 0.8))
                    .foregroundColor(isWidget ? .white : symbolColor)
            } else {
                // Final fallback to emoji
                Text(pickupType.emoji)
                    .font(.system(size: size))
            }
        }
        .frame(width: size, height: size)
    }
    
    private var symbolColor: Color {
        switch pickupType {
        case .recycling:
            return .blue
        case .yard_waste:
            return .green
        case .trash_only:
            return .gray
        case .no_pickup:
            return .red
        }
    }
    
    // Helper function to try loading image from multiple bundle sources
    private func loadImageFromAnyBundle(named imageName: String) -> UIImage? {
        #if DEBUG
        print("🔍 Attempting to load image: '\(imageName)'")
        print(ImageDebugHelper.debugImageLoading(imageName: imageName))
        #endif
        
        // Try main bundle first
        if let image = UIImage(named: imageName, in: Bundle.main, compatibleWith: nil) {
            #if DEBUG
            print("✅ Loaded '\(imageName)' from main bundle")
            #endif
            return image
        }
        
        // Try TruckeeTrashKit bundle
        if let image = UIImage(named: imageName, in: Bundle(for: TruckeeTrashKit.self), compatibleWith: nil) {
            #if DEBUG
            print("✅ Loaded '\(imageName)' from TruckeeTrashKit bundle")
            #endif
            return image
        }
        
        // Try current bundle (for widget extension)
        if let image = UIImage(named: imageName, in: Bundle(for: Token.self), compatibleWith: nil) {
            #if DEBUG
            print("✅ Loaded '\(imageName)' from current bundle")
            #endif
            return image
        }
        
        // Try loading from all available bundles
        for bundle in Bundle.allBundles {
            if let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) {
                #if DEBUG
                print("✅ Loaded '\(imageName)' from bundle: \(bundle.bundleIdentifier ?? "unknown")")
                #endif
                return image
            }
        }
        
        #if DEBUG
        print("❌ Failed to load image '\(imageName)' from any bundle")
        #endif
        return nil
    }
}

private final class Token {}

#if DEBUG
struct PickupSymbolView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            VStack {
                Text("Image (Default)")
                PickupSymbolView(pickupType: .recycling, size: 80)
            }
            
            VStack {
                Text("Emoji (Default)")
                PickupSymbolView(pickupType: .trash_only, size: 80)
            }
            
            VStack {
                Text("Image (Forced Emoji)")
                PickupSymbolView(pickupType: .yard_waste, size: 80, forceEmoji: true)
            }
            
            VStack {
                Text("No Pickup (Emoji)")
                PickupSymbolView(pickupType: .no_pickup, size: 80)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .previewLayout(.sizeThatFits)
    }
}
#endif

