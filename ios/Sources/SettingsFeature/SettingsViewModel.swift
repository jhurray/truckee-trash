import Foundation
import Combine
import UserNotifications

extension Notification.Name {
    static let pickupDayChanged = Notification.Name("pickupDayChanged")
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedPickupDay: Int {
        didSet {
            UserDefaults.standard.set(selectedPickupDay, forKey: "selectedPickupDay")
            scheduleNotificationsIfNeeded()
            // Notify other parts of the app that pickup day changed
            NotificationCenter.default.post(name: .pickupDayChanged, object: nil)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                requestNotificationPermission()
            } else {
                cancelNotifications()
            }
        }
    }
    
    @Published var notificationPreference: String {
        didSet {
            UserDefaults.standard.set(notificationPreference, forKey: "notificationPreference")
            scheduleNotificationsIfNeeded()
        }
    }
    
    init() {
        // Load saved settings or use defaults
        self.selectedPickupDay = UserDefaults.standard.object(forKey: "selectedPickupDay") as? Int ?? 5 // Friday
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.notificationPreference = UserDefaults.standard.string(forKey: "notificationPreference") ?? "evening_before"
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleNotificationsIfNeeded()
                } else {
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    private func scheduleNotificationsIfNeeded() {
        guard notificationsEnabled else { return }
        
        // Cancel existing notifications
        cancelNotifications()
        
        // Schedule new notification
        let content = UNMutableNotificationContent()
        content.title = "Trash Day Reminder"
        content.sound = .default
        
        var dateComponents = DateComponents()
        
        switch notificationPreference {
        case "evening_before":
            content.body = "Don't forget! Trash pickup is tomorrow."
            // Schedule for 7 PM the day before pickup
            let reminderDay = selectedPickupDay == 1 ? 7 : selectedPickupDay - 1
            dateComponents.weekday = reminderDay == 7 ? 1 : reminderDay + 1
            dateComponents.hour = 19 // 7 PM
            dateComponents.minute = 0
            
        case "morning_of":
            content.body = "Good morning! Today is trash pickup day."
            // Schedule for 7 AM on pickup day
            dateComponents.weekday = selectedPickupDay == 7 ? 1 : selectedPickupDay + 1
            dateComponents.hour = 7 // 7 AM
            dateComponents.minute = 0
            
        default:
            return // No notifications
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "TruckeeTrashPickupReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TruckeeTrashPickupReminder"])
    }
}