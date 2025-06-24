import Foundation
import UserNotifications
import TruckeeTrashKit

public class NotificationsService: ObservableObject {
    @Published public var isAuthorized = false
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let apiClient: ApiClient
    private let notificationCenter: UserNotificationCenterProtocol
    private let userDefaults: UserDefaultsProtocol
    
    private let skipAuthCheck: Bool
    
    public init(
        apiClient: ApiClient = TruckeeTrashKit.shared.apiClient,
        notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        userDefaults: UserDefaultsProtocol = SharedUserDefaults.shared,
        skipInitialAuthCheck: Bool = false
    ) {
        self.apiClient = apiClient
        self.notificationCenter = notificationCenter
        self.userDefaults = userDefaults
        self.skipAuthCheck = skipInitialAuthCheck
        if !skipInitialAuthCheck {
            checkAuthorizationStatus()
        }
    }
    
    // MARK: - Public Methods
    
    public func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if !(self?.skipAuthCheck ?? false) {
                    self?.checkAuthorizationStatus()
                }
                completion(granted)
            }
        }
    }
    
    public func schedulePickupReminders() {
        guard isAuthorized else { return }
        
        // Cancel existing reminders - use a pattern to remove all our notifications
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let identifiersToRemove = requests.compactMap { request in
                request.identifier.hasPrefix("TruckeeTrashPickupReminder") ? request.identifier : nil
            }
            self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
        
        // Get user settings
        let selectedPickupDay = userDefaults.object(forKey: "selectedPickupDay") as? Int ?? 5
        let notificationsEnabled = userDefaults.bool(forKey: "notificationsEnabled")
        
        guard notificationsEnabled else { return }
        
        // iOS limits us to 64 pending notifications
        // Schedule notifications for the next 52 weeks (1 year) to maximize coverage
        // We'll refresh these periodically when the app is opened
        let maxWeeks = 52
        let currentDate = apiClient.getCurrentTruckeeDate()
        
        // Create a dispatch group to track all API calls
        let dispatchGroup = DispatchGroup()
        var notificationsToSchedule: [(Date, Result<DayPickupInfo, ApiError>, Int)] = []
        
        for weekOffset in 0..<maxWeeks {
            dispatchGroup.enter()
            
            let offsetDate = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: currentDate) ?? currentDate
            let pickupDate = offsetDate.nextOccurrence(of: selectedPickupDay)
            
            // Fetch pickup info for each date to create specific notification content
            apiClient.fetchDayPickupType(for: pickupDate) { result in
                DispatchQueue.main.async {
                    notificationsToSchedule.append((pickupDate, result, weekOffset))
                    dispatchGroup.leave()
                }
            }
        }
        
        // When all API calls complete, schedule the notifications
        dispatchGroup.notify(queue: .main) { [weak self] in
            // Sort by date to ensure proper ordering
            notificationsToSchedule.sort { $0.0 < $1.0 }
            
            // Schedule each notification
            for (pickupDate, result, weekOffset) in notificationsToSchedule {
                self?.scheduleNotificationForDate(pickupDate, result: result, selectedPickupDay: selectedPickupDay, weekOffset: weekOffset)
            }
            
            // Store the date we last scheduled notifications
            self?.userDefaults.set(Date(), forKey: "lastNotificationScheduleDate")
            
            print("Scheduled \(notificationsToSchedule.count) notifications for the next year")
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func scheduleNotificationForDate(_ pickupDate: Date, result: Result<DayPickupInfo, ApiError>, selectedPickupDay: Int, weekOffset: Int) {
        let notificationTime = userDefaults.object(forKey: "notificationTime") as? Date ?? {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 19 // 7 PM
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }()
        
        // Get notification preference
        let notificationPreferenceRaw = userDefaults.string(forKey: "notificationPreference") ?? "evening_before"
        let notificationPreference = NotificationPreference(rawValue: notificationPreferenceRaw) ?? .eveningBefore
        
        let content = UNMutableNotificationContent()
        content.title = "Trash Day Reminder"
        content.sound = .default
        
        // Set notification body based on pickup type and notification preference
        let dayReference = notificationPreference == .morningOf ? "Today" : "Tomorrow"
        
        switch result {
        case .success(let pickupInfo):
            switch pickupInfo.pickupType {
            case .recycling:
                content.body = "\(dayReference) is a Recycling Day. Don't forget to put out your bins!"
            case .yard_waste:
                content.body = "\(dayReference) is a Yard Waste Day. Don't forget to put out your bins!"
            case .trash_only:
                content.body = "\(dayReference) is Trash Day. Don't forget to put out your bins!"
            case .no_pickup:
                content.body = "No pickup scheduled for \(dayReference.lowercased())."
            }
        case .failure:
            content.body = "Trash day reminder! Open Truckee Trash to see details for \(dayReference.lowercased())."
        }
        
        // Get notification time components
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)
        
        // Determine when to send the notification based on preference
        var notificationDate: Date
        
        switch notificationPreference {
        case .eveningBefore:
            // Send notification the evening before pickup
            guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: pickupDate) else { return }
            var components = calendar.dateComponents([.year, .month, .day], from: dayBefore)
            components.hour = timeComponents.hour ?? 19 // Default to 7 PM
            components.minute = timeComponents.minute ?? 0
            components.second = 0
            guard let date = calendar.date(from: components) else { return }
            notificationDate = date
            
        case .morningOf:
            // Send notification the morning of pickup
            var components = calendar.dateComponents([.year, .month, .day], from: pickupDate)
            components.hour = 7 // 7 AM
            components.minute = 0
            components.second = 0
            guard let date = calendar.date(from: components) else { return }
            notificationDate = date
            
        case .none:
            return // No notifications
        }
        
        // Only schedule if the notification date is in the future
        guard notificationDate > Date() else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationDate.timeIntervalSinceNow, repeats: false)
        let identifier = "TruckeeTrashPickupReminder_\(weekOffset)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    public func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    public func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests(completionHandler: completion)
    }
    
    // Call this method periodically (e.g., when app becomes active) to refresh notifications
    public func refreshNotificationsIfNeeded() {
        guard isAuthorized && userDefaults.bool(forKey: "notificationsEnabled") else { return }
        
        // Check when we last scheduled notifications
        let lastScheduleDate = userDefaults.object(forKey: "lastNotificationScheduleDate") as? Date ?? Date.distantPast
        let daysSinceLastSchedule = Calendar.current.dateComponents([.day], from: lastScheduleDate, to: Date()).day ?? 0
        
        // Refresh if it's been more than 30 days or if we're running low on notifications
        let shouldRefreshByTime = daysSinceLastSchedule > 30
        
        getPendingNotifications { [weak self] requests in
            let pickupNotifications = requests.filter { $0.identifier.hasPrefix("TruckeeTrashPickupReminder") }
            
            // Refresh if we have less than 20 weeks of notifications remaining
            let shouldRefreshByCount = pickupNotifications.count < 20
            
            if shouldRefreshByTime || shouldRefreshByCount {
                DispatchQueue.main.async {
                    print("Refreshing notifications - Time: \(shouldRefreshByTime), Count: \(shouldRefreshByCount) (\(pickupNotifications.count) remaining)")
                    self?.schedulePickupReminders()
                }
            }
        }
    }
}
