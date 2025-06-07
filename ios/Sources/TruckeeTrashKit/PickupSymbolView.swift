import SwiftUI

public struct PickupSymbolView: View {
    public let pickupType: DayPickupTypeString
    public let size: CGFloat
    public let forceEmoji: Bool
    public let isWidget: Bool
    private let imageMultiplier: CGFloat = 1.5
    
    public init(pickupType: DayPickupTypeString, size: CGFloat, forceEmoji: Bool = false, isWidget: Bool = false) {
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
            } else if let sfSymbolName = pickupType.sfSymbolName {
                // Use SF Symbol for widgets (always available)
                Image(systemName: sfSymbolName)
                    .font(.system(size: size * 0.8))
                    .foregroundColor(isWidget ? .white : symbolColor)
            } else {
                // Fallback to emoji
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
}

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

