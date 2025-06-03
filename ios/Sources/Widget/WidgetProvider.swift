import WidgetKit
import SwiftUI
import TruckeeTrashKit

struct Provider: TimelineProvider {
    private let apiClient = TruckeeTrashKit.shared.apiClient
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            weekStatus: RelevantWeekStatusInfo(
                reportedWeek: ReportedWeekInfo(startDate: "2025-06-02", endDate: "2025-06-06"),
                weekStatus: .yard_waste_week,
                specialPickupDayInWeek: "2025-06-06",
                specialPickupTypeOnDate: .yard_waste
            ),
            errorMessage: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            weekStatus: RelevantWeekStatusInfo(
                reportedWeek: ReportedWeekInfo(startDate: "2025-06-02", endDate: "2025-06-06"),
                weekStatus: .yard_waste_week,
                specialPickupDayInWeek: "2025-06-06",
                specialPickupTypeOnDate: .yard_waste
            ),
            errorMessage: nil
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = apiClient.getCurrentTruckeeDate()
        
        apiClient.fetchRelevantWeekStatus(currentDate: currentDate) { result in
            let entry: SimpleEntry
            let nextUpdate: Date
            
            switch result {
            case .success(let weekStatus):
                entry = SimpleEntry(
                    date: currentDate,
                    weekStatus: weekStatus,
                    errorMessage: nil
                )
                
                // Update at the end of the current week or daily, whichever is sooner
                if let endDate = parseDate(weekStatus.reportedWeek.endDate) {
                    let calendar = Calendar.truckeeCalendar
                    let endOfWeek = calendar.date(byAdding: .day, value: 1, to: endDate) ?? Date()
                    let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
                    nextUpdate = min(endOfWeek, tomorrow)
                } else {
                    nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
                }
                
            case .failure(let error):
                entry = SimpleEntry(
                    date: currentDate,
                    weekStatus: nil,
                    errorMessage: error.localizedDescription
                )
                
                // Retry in 1 hour on error
                nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? Date()
            }
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return formatter.date(from: dateString)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weekStatus: RelevantWeekStatusInfo?
    let errorMessage: String?
}