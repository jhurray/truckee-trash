import Foundation
import Combine
import UserNotifications
import NotificationsService
import TruckeeTrashKit

extension Notification.Name {
    static let pickupDayChanged = Notification.Name("pickupDayChanged")
}

@MainActor
class SettingsViewModel: ObservableObject {
    private let notificationsService = NotificationsService()
    @Published var selectedPickupDay: Int {
        didSet {
            SharedUserDefaults.selectedPickupDay = selectedPickupDay
            scheduleNotificationsIfNeeded()
            // Notify other parts of the app that pickup day changed
            NotificationCenter.default.post(name: .pickupDayChanged, object: nil)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            SharedUserDefaults.notificationsEnabled = notificationsEnabled
            if notificationsEnabled {
                requestNotificationPermission()
            } else {
                cancelNotifications()
            }
        }
    }
    
    @Published var notificationPreference: String {
        didSet {
            SharedUserDefaults.notificationPreference = notificationPreference
            scheduleNotificationsIfNeeded()
        }
    }
    
    init() {
        // Load saved settings or use defaults
        self.selectedPickupDay = SharedUserDefaults.selectedPickupDay
        self.notificationsEnabled = SharedUserDefaults.notificationsEnabled
        self.notificationPreference = SharedUserDefaults.notificationPreference
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