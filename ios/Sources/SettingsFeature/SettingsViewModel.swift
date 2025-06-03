import Foundation
import Combine
import UserNotifications

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedPickupDay: Int {
        didSet {
            UserDefaults.standard.set(selectedPickupDay, forKey: "selectedPickupDay")
            scheduleNotificationsIfNeeded()
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
    
    @Published var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
            scheduleNotificationsIfNeeded()
        }
    }
    
    init() {
        // Load saved settings or use defaults
        self.selectedPickupDay = UserDefaults.standard.object(forKey: "selectedPickupDay") as? Int ?? 5 // Friday
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        // Default notification time: 7:00 PM
        if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            self.notificationTime = savedTime
        } else {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 19 // 7 PM
            components.minute = 0
            self.notificationTime = calendar.date(from: components) ?? Date()
            UserDefaults.standard.set(self.notificationTime, forKey: "notificationTime")
        }
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
        content.body = "Trash day reminder! Open Truckee Trash to see details for tomorrow."
        content.sound = .default
        
        // Get notification time components
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)
        
        // Calculate the day before pickup day
        let reminderDay = selectedPickupDay == 1 ? 7 : selectedPickupDay - 1 // Sunday if Monday pickup, otherwise previous day
        
        var dateComponents = DateComponents()
        dateComponents.weekday = reminderDay == 7 ? 1 : reminderDay + 1 // Convert to Calendar weekday format
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
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