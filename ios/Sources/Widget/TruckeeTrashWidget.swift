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
                        Color.gray
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
                case .systemMedium:
                    MediumWidgetView(pickupData: pickupData)
                default:
                    SmallWidgetView(pickupData: pickupData)
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
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Compact message
            Text(pickupData.compactMessage)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium Widget (Full information)

struct MediumWidgetView: View {
    let pickupData: PickupDisplayData
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Emoji
            VStack {
                Text(pickupData.pickupType.emoji)
                    .font(.system(size: 60))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity)
            
            // Right side: Text information
            VStack(alignment: .leading, spacing: 8) {
                Text(pickupData.primaryMessage)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    .lineLimit(2)
                
                if let secondaryMsg = pickupData.secondaryMessage {
                    Text(secondaryMsg)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.label))
            
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(Color(UIColor.secondaryLabel))
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
                .foregroundColor(Color(UIColor.label))
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

    // 1. A recycling week entry
    let recyclingEntry = PickupEntry(
        date: Date(),
        pickupData: PickupDisplayData(
            pickupType: .recycling,
            nextPickupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        ),
        errorMessage: nil
    )
    
    // 2. A yard waste week entry
    let yardWasteEntry = PickupEntry(
        date: Date(),
        pickupData: PickupDisplayData(
            pickupType: .yard_waste,
            nextPickupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        ),
        errorMessage: nil
    )
    
    // 3. A normal trash week entry
    let normalTrashEntry = PickupEntry(
        date: Date(),
        pickupData: PickupDisplayData(
            pickupType: .trash_only,
            nextPickupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        ),
        errorMessage: nil
    )
    
    // 4. An error state entry
    let errorEntry = PickupEntry(
        date: Date(),
        pickupData: nil,
        errorMessage: "Failed to connect to the server."
    )

    // Return the entries for the preview timeline. Xcode will cycle through them.
    return [recyclingEntry, yardWasteEntry, normalTrashEntry, errorEntry]
})
