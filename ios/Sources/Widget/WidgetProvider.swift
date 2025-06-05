import WidgetKit
import SwiftUI
import TruckeeTrashKit

struct Provider: TimelineProvider {
    private let apiClient = TruckeeTrashKit.shared.apiClient
    
    func placeholder(in context: Context) -> PickupEntry {
        PickupEntry(
            date: Date(),
            pickupData: PickupDisplayData(
                pickupType: .recycling,
                nextPickupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            ),
            errorMessage: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PickupEntry) -> ()) {
        let entry = PickupEntry(
            date: Date(),
            pickupData: PickupDisplayData(
                pickupType: .recycling,
                nextPickupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            ),
            errorMessage: nil
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PickupEntry>) -> ()) {
        // Get user's selected pickup day (default to Friday if not set)
        let selectedPickupDay = UserDefaults.standard.object(forKey: "selectedPickupDay") as? Int ?? 5
        
        let currentDate = apiClient.getCurrentTruckeeDate()
        let nextPickupDate = currentDate.nextOccurrence(of: selectedPickupDay)
        
        apiClient.fetchDayPickupType(for: nextPickupDate) { result in
            let entry: PickupEntry
            let nextUpdate: Date
            
            switch result {
            case .success(let pickupInfo):
                entry = PickupEntry(
                    date: currentDate,
                    pickupData: PickupDisplayData(
                        pickupType: pickupInfo.pickupType,
                        nextPickupDate: nextPickupDate,
                        currentDate: currentDate
                    ),
                    errorMessage: nil
                )
                
                // Update daily at 12 AM
                let calendar = Calendar.truckeeCalendar
                let nextMidnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)
                nextUpdate = nextMidnight
                
            case .failure(let error):
                entry = PickupEntry(
                    date: currentDate,
                    pickupData: nil,
                    errorMessage: error.localizedDescription
                )
                
                // Retry in 30 minutes on error
                nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? Date()
            }
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct PickupEntry: TimelineEntry {
    let date: Date
    let pickupData: PickupDisplayData?
    let errorMessage: String?
}
