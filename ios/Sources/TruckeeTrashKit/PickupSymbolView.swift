import SwiftUI

public struct PickupSymbolView: View {
    public let pickupType: DayPickupTypeString
    public let size: CGFloat
    public let forceEmoji: Bool
    private let imageMultiplier: CGFloat = 1.5
    
    public init(pickupType: DayPickupTypeString, size: CGFloat, forceEmoji: Bool = false) {
        self.pickupType = pickupType
        self.size = size
        self.forceEmoji = forceEmoji
    }

    public var body: some View {
        ZStack {
            if !pickupType.imageName.isEmpty && !forceEmoji {
                Image(pickupType.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * imageMultiplier, height: size * imageMultiplier)
            } else {
                Text(pickupType.emoji)
                    .font(.system(size: size))
            }
        }
        .frame(width: size, height: size)
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

