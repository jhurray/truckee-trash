import WidgetKit
import SwiftUI
import TruckeeTrashKit

struct TruckeeTrashWidget: Widget {
    let kind: String = "TruckeeTrashWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TruckeeTrashWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    if let pickupData = entry.pickupData {
                        WidgetGradientBackground(pickupType: pickupData.pickupType)
                    } else {
                        Color.appLoadingBackground
                    }
                }
        }
        .configurationDisplayName("Truckee Trash")
        .description("See your next pickup day at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TruckeeTrashWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if let pickupData = entry.pickupData {
                switch family {
                case .systemSmall:
                    SmallWidgetView(pickupData: pickupData)
                case .systemMedium, .systemLarge, .systemExtraLarge:
                    MediumWidgetView(pickupData: pickupData)
                default:
                    AccessoryWidgetView(pickupData: pickupData)
                }
            } else if let errorMessage = entry.errorMessage {
                ErrorWidgetView(errorMessage: errorMessage)
            } else {
                LoadingWidgetView()
            }
        }
    }
}

// MARK: - Small Widget (Just emoji)

struct SmallWidgetView: View {
    let pickupData: PickupDisplayData
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            // Big emoji
            PickupSymbolView(pickupType: pickupData.pickupType, size: 50)
                .shadow(color: Color.appTextShadow.opacity(0.5), radius: 2, x: 0, y: 1)
                .minimumScaleFactor(0.2)
            
            // Compact message
            Text(pickupData.compactMessage)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.appAlwaysLightText)
                .shadow(color: Color.appTextShadow, radius: 1, x: 0, y: 1)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AccessoryWidgetView: View {
    let pickupData: PickupDisplayData
    
    var body: some View {
        VStack(spacing: 12) {
            // Big emoji
            PickupSymbolView(pickupType: pickupData.pickupType, size: 35, forceEmoji: true)
                .shadow(color: Color.appTextShadow.opacity(0.5), radius: 2, x: 0, y: 1)
            
            // Compact message
            Text(pickupData.compactMessage)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color.appAlwaysLightText)
                .shadow(color: Color.appTextShadow, radius: 1, x: 0, y: 1)
                .minimumScaleFactor(0.7)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium Widget (Full information)

struct MediumWidgetView: View {
    let pickupData: PickupDisplayData
    
    var body: some View {
        HStack(spacing: 16) {
            Spacer()
            
            // Left side: Emoji
            VStack {
                PickupSymbolView(pickupType: pickupData.pickupType, size: 60)
                    .shadow(color: Color.appTextShadow, radius: 3, x: 0, y: 1)
            }
            .scaledToFit()
            
            // Right side: Text information
            VStack(alignment: .leading, spacing: 8) {
                Text(pickupData.primaryMessage)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.appAlwaysLightText)
                    .shadow(color: Color.appTextShadow, radius: 2, x: 0, y: 1)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                
                if let secondaryMsg = pickupData.secondaryMessage {
                    Text(secondaryMsg)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.appAlwaysLightText.opacity(0.9))
                        .shadow(color: Color.appTextShadow, radius: 2, x: 0, y: 1)
                        .minimumScaleFactor(0.5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(16)
    }
}

// MARK: - Error Widget

struct ErrorWidgetView: View {
    let errorMessage: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.appPrimaryText)
            
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(Color.appSecondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading Widget

struct LoadingWidgetView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(pickupData: .placeholder)
            default:
                MediumWidgetView(pickupData: .placeholder)
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

// MARK: - Widget Gradient Background

struct WidgetGradientBackground: View {
    let pickupType: DayPickupTypeString
    
    var body: some View {
        let colors = pickupType.widgetGradient
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: colors.start),
                Color(hex: colors.end)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Shimmer Effect

@frozen
public struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration = 1.5
    var bounce = false

    public func body(content: Content) -> some View {
        content
            .modifier(
                AnimatedMask(phase: phase)
                    .animation(
                        Animation.linear(duration: duration)
                            .repeatForever(autoreverses: bounce)
                    )
            )
            .onAppear { phase = 0.8 }
    }

    
    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
                .mask(
                    GradientMask(phase: phase)
                        .scaleEffect(3)
                )
        }
    }

    struct GradientMask: View {
        let phase: CGFloat
        let centerColor = Color.appSecondaryText
        let edgeColor = Color.appSecondaryText.opacity(0.8)

        var body: some View {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

public extension View {
    @ViewBuilder
    func shimmering(
        duration: Double = 1.5,
        bounce: Bool = false
    ) -> some View {
        modifier(Shimmer(duration: duration, bounce: bounce))
    }
}

#Preview(as: .systemMedium, widget: {
    // This part points to your widget's configuration
    TruckeeTrashWidget()
}, timeline: {
    // This part provides the data (entries) for the preview timeline.
    // We'll create a few different entries to see all our states.
    
    let date = Date()
    let nextPickupDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    // 1. A recycling week entry
    let recyclingEntry = PickupEntry(
        date: date,
        pickupData: PickupDisplayData(
            pickupType: .recycling,
            nextPickupDate: nextPickupDate
        ),
        errorMessage: nil
    )
    
    // 2. A yard waste week entry
    let yardWasteEntry = PickupEntry(
        date: date,
        pickupData: PickupDisplayData(
            pickupType: .yard_waste,
            nextPickupDate: nextPickupDate
        ),
        errorMessage: nil
    )
    
    // 3. A normal trash week entry
    let normalTrashEntry = PickupEntry(
        date: date,
        pickupData: PickupDisplayData(
            pickupType: .trash_only,
            nextPickupDate: nextPickupDate
        ),
        errorMessage: nil
    )
    
    // 4. An error state entry
    let errorEntry = PickupEntry(
        date: date,
        pickupData: nil,
        errorMessage: "Failed to connect to the server."
    )
    
    let loadingEntry = PickupEntry(
        date: date,
        pickupData: nil,
        errorMessage: nil
    )

    // Return the entries for the preview timeline. Xcode will cycle through them.
    return [recyclingEntry, yardWasteEntry, normalTrashEntry, errorEntry, loadingEntry]
})
