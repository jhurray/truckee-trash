import Foundation
import UserNotifications
import TruckeeTrashKit

public class NotificationsService: ObservableObject {
    @Published public var isAuthorized = false
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let apiClient = TruckeeTrashKit.shared.apiClient
    
    public init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    public func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                self?.checkAuthorizationStatus()
                completion(granted)
            }
        }
    }
    
    public func schedulePickupReminders() {
        guard isAuthorized else { return }
        
        // Cancel existing reminders
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TruckeeTrashPickupReminder"])
        
        // Get user settings
        let selectedPickupDay = UserDefaults.standard.object(forKey: "selectedPickupDay") as? Int ?? 5 // Friday
        let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        guard notificationsEnabled else { return }
        
        // Calculate next pickup date to determine specific content
        let currentDate = apiClient.getCurrentTruckeeDate()
        let nextPickupDate = currentDate.nextOccurrence(of: selectedPickupDay)
        
        // Fetch pickup info for that date to create specific notification content
        apiClient.fetchDayPickupType(for: nextPickupDate) { [weak self] result in
            DispatchQueue.main.async {
                self?.scheduleNotificationWithPickupInfo(result, selectedPickupDay: selectedPickupDay)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func scheduleNotificationWithPickupInfo(_ result: Result<DayPickupInfo, ApiError>, selectedPickupDay: Int) {
        let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 19 // 7 PM
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }()
        
        let content = UNMutableNotificationContent()
        content.title = "Trash Day Reminder"
        content.sound = .default
        
        // Set notification body based on pickup type
        switch result {
        case .success(let pickupInfo):
            switch pickupInfo.pickupType {
            case .recycling:
                content.body = "Tomorrow is Trash Day. It's also Recycling Day!"
            case .yard_waste:
                content.body = "Tomorrow is Yard Waste Day. Don't forget your yard waste!"
            case .trash_only:
                content.body = "Tomorrow is Trash Day."
            case .no_pickup:
                content.body = "No pickup scheduled for tomorrow."
            }
        case .failure:
            content.body = "Trash day reminder! Open Truckee Trash to see details for tomorrow."
        }
        
        // Get notification time components
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)
        
        // Calculate the day before pickup day
        let reminderDay = selectedPickupDay == 1 ? 7 : selectedPickupDay - 1 // Sunday if Monday pickup, otherwise previous day
        
        var dateComponents = DateComponents()
        dateComponents.weekday = reminderDay == 7 ? 1 : reminderDay + 1 // Convert to Calendar weekday format (Sunday = 1)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "TruckeeTrashPickupReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    public func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    public func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: completion)
    }
}