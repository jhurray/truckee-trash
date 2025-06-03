import WidgetKit
import SwiftUI
import TruckeeTrashKit

struct TruckeeTrashWidget: Widget {
    let kind: String = "TruckeeTrashWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TruckeeTrashWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TruckeeTrashWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Truckee Trash")
        .description("See this week's pickup schedule at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TruckeeTrashWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: weekStatusIcon(entry.weekStatus?.weekStatus))
                    .foregroundColor(weekStatusColor(entry.weekStatus?.weekStatus))
                
                Text("Truckee Trash")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Main content
            if let weekStatus = entry.weekStatus {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weekStatus.weekStatus.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(weekStatusColor(weekStatus.weekStatus))
                    
                    Text(formatWeekRange(weekStatus.reportedWeek))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let specialDay = weekStatus.specialPickupDayInWeek,
                       let specialType = weekStatus.specialPickupTypeOnDate {
                        HStack(spacing: 4) {
                            Image(systemName: pickupTypeIcon(specialType))
                                .font(.caption)
                            Text("\(specialType.displayName): \(formatSpecialDate(specialDay))")
                                .font(.caption)
                        }
                        .foregroundColor(weekStatusColor(weekStatus.weekStatus))
                    }
                }
            } else if let errorMessage = entry.errorMessage {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Loading...")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Helper Methods
    
    private func weekStatusIcon(_ status: WeekStatusString?) -> String {
        guard let status = status else { return "questionmark.circle" }
        
        switch status {
        case .recycling_week:
            return "arrow.3.trianglepath"
        case .yard_waste_week:
            return "leaf.fill"
        case .normal_trash_week:
            return "trash"
        case .no_pickup_week:
            return "xmark.circle"
        }
    }
    
    private func weekStatusColor(_ status: WeekStatusString?) -> Color {
        guard let status = status else { return .gray }
        
        switch status {
        case .recycling_week:
            return .blue
        case .yard_waste_week:
            return .green
        case .normal_trash_week:
            return .gray
        case .no_pickup_week:
            return .red
        }
    }
    
    private func pickupTypeIcon(_ type: DayPickupTypeString) -> String {
        switch type {
        case .recycling:
            return "arrow.3.trianglepath"
        case .yard_waste:
            return "leaf.fill"
        case .trash_only:
            return "trash"
        case .no_pickup:
            return "xmark.circle"
        }
    }
    
    private func formatWeekRange(_ week: ReportedWeekInfo) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        guard let startDate = parseDate(week.startDate),
              let endDate = parseDate(week.endDate) else {
            return "\(week.startDate) - \(week.endDate)"
        }
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private func formatSpecialDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        
        guard let date = parseDate(dateString) else {
            return dateString
        }
        
        return formatter.string(from: date)
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return formatter.date(from: dateString)
    }
}