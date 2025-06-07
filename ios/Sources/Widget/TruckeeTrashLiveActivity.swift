import SwiftUI
import ActivityKit
import WidgetKit
import TruckeeTrashKit

@available(iOS 16.1, *)
struct TruckeeTrashLiveActivity: Widget {
    let kind: String = "TruckeeTrashLiveActivity"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TruckeeTrashLiveActivityAttributes.self) { context in
            // Lock screen view
            TruckeeTrashLiveActivityLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island views
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        PickupSymbolView(pickupType: context.state.pickupType, size: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.pickupDisplayData.primaryMessage)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.appPrimaryText)
                                .lineLimit(1)
                            
                            if let timeRemaining = context.state.timeRemaining {
                                Text(timeRemaining)
                                    .font(.caption)
                                    .foregroundColor(Color.appSecondaryText)
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.attributes.pickupDay)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.appSecondaryText)
                        
                        Text("Pickup Day")
                            .font(.caption2)
                            .foregroundColor(Color.appTertiaryText)
                    }
                    .padding(.trailing, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.pickupType.userFriendlyDescription)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.appPrimaryText)
                        Spacer()
                        if context.state.isToday {
                            Text("TODAY")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                // Compact leading (when collapsed on left)
                PickupSymbolView(pickupType: context.state.pickupType, size: 20, forceEmoji: true)
            } compactTrailing: {
                // Compact trailing (when collapsed on right)
                if context.state.isToday {
                    Text("Today")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                } else if let timeRemaining = context.state.timeRemaining {
                    Text(timeRemaining)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.appSecondaryText)
                }
            } minimal: {
                // Minimal view (just the icon)
                PickupSymbolView(pickupType: context.state.pickupType, size: 16, forceEmoji: true)
            }
        }
        .configurationDisplayName("Trash Day")
        .description("See your pickup information in Live Activities.")
        .supportedFamilies([WidgetFamily.systemMedium])
    }
}

@available(iOS 16.1, *)
struct TruckeeTrashLiveActivityLockScreenView: View {
    let context: ActivityViewContext<TruckeeTrashLiveActivityAttributes>
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Pickup symbol
            VStack {
                PickupSymbolView(pickupType: context.state.pickupType, size: 60)
                    .shadow(color: Color.appTextShadow.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .frame(width: 80)
            
            // Right side: Information
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(context.state.pickupDisplayData.primaryMessage)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appAlwaysLightText)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if context.state.isToday {
                        Text("TODAY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(4)
                    }
                }
                
                if let timeRemaining = context.state.timeRemaining {
                    Text("Time remaining: \(timeRemaining)")
                        .font(.subheadline)
                        .foregroundColor(Color.appAlwaysLightText.opacity(0.8))
                }
                
                Text("\(context.attributes.pickupDay) • \(context.state.pickupType.userFriendlyDescription)")
                    .font(.caption)
                    .foregroundColor(Color.appAlwaysLightText.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            WidgetGradientBackground(pickupType: context.state.pickupType)
                .opacity(0.9)
        )
        .cornerRadius(16)
    }
}

// MARK: - Preview

@available(iOS 16.1, *)
#Preview("Live Activity", as: .content, using: TruckeeTrashLiveActivityAttributes(pickupDay: "Friday")) {
    TruckeeTrashLiveActivity()
} contentStates: {
    // Today's pickup
    TruckeeTrashLiveActivityContentState(
        pickupType: .recycling,
        isToday: true,
        timeRemaining: "3 hours",
        nextPickupDate: Date()
    )
    
    // Tomorrow's pickup
    TruckeeTrashLiveActivityContentState(
        pickupType: .yard_waste,
        isToday: false,
        timeRemaining: "1 day",
        nextPickupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    )
}
