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
            Text(pickupData.pickupType.emoji)
                .font(.system(size: 50))
                .shadow(color: Color.appTextShadow.opacity(0.5), radius: 2, x: 0, y: 1)
                .minimumScaleFactor(0.2)
            
            // Compact message
            Text(pickupData.compactMessage)
                .font(.caption)
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
        VStack(spacing: 8) {
            // Big emoji
            Text(pickupData.pickupType.emoji)
                .font(.system(size: 25))
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
                Text(pickupData.pickupType.emoji)
                    .font(.system(size: 60))
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
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading Widget

struct LoadingWidgetView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(Color.appAlwaysLightText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview(as: .systemMedium, widget: {
    // This part points to your widget's configuration
    TruckeeTrashWidget()
}, timeline: {
    // This part provides the data (entries) for the preview timeline.
    // We'll create a few different entries to see all our states.
    
    let date = Date()
    let nextPickupDate = Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date()

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
