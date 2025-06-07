import Foundation
import Combine
import UserNotifications
import NotificationsService

extension Notification.Name {
    static let pickupDayChanged = Notification.Name("pickupDayChanged")
}

@MainActor
class SettingsViewModel: ObservableObject {
    private let notificationsService = NotificationsService()
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
        notificationsService.schedulePickupReminders()
    }
    
    private func cancelNotifications() {
        notificationsService.cancelAllNotifications()
    }
}