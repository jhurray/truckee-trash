import Foundation
import ActivityKit
import TruckeeTrashKit

@available(iOS 16.1, *)
public class LiveActivityService: ObservableObject {
    @Published public var currentActivity: LiveActivityState = .notStarted
    
    private var activity: Activity<TruckeeTrashLiveActivityAttributes>?
    
    public init() {
        checkForExistingActivity()
    }
    
    // MARK: - Public Methods
    
    public func startTrashDayActivity(pickupInfo: DayPickupInfo, nextPickupDate: Date, pickupDay: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        // End any existing activity first
        endCurrentActivity()
        
        let attributes = TruckeeTrashLiveActivityAttributes(pickupDay: pickupDay)
        let contentState = createContentState(
            pickupInfo: pickupInfo,
            nextPickupDate: nextPickupDate
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: Calendar.current.date(byAdding: .hour, value: 12, to: Date())),
                pushType: nil // Local only
            )
            
            self.activity = activity
            self.currentActivity = .active(activity)
            
            print("Live Activity started successfully")
            
            // Schedule periodic updates if it's today
            if isToday(nextPickupDate) {
                schedulePeriodicUpdates(pickupInfo: pickupInfo, nextPickupDate: nextPickupDate)
            }
            
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    public func updateActivity(pickupInfo: DayPickupInfo, nextPickupDate: Date) {
        guard case .active(let activity) = currentActivity else { return }
        
        let contentState = createContentState(
            pickupInfo: pickupInfo,
            nextPickupDate: nextPickupDate
        )
        
        Task {
            await activity.update(.init(state: contentState, staleDate: Calendar.current.date(byAdding: .hour, value: 12, to: Date())))
        }
    }
    
    public func endCurrentActivity() {
        guard case .active(let activity) = currentActivity else { return }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        
        self.activity = nil
        self.currentActivity = .ended
        
        print("Live Activity ended")
    }
    
    public func shouldShowLiveActivity(for pickupInfo: DayPickupInfo?, nextPickupDate: Date?) -> Bool {
        guard let pickupInfo = pickupInfo,
              let nextPickupDate = nextPickupDate,
              ActivityAuthorizationInfo().areActivitiesEnabled else {
            return false
        }
        
        // Show Live Activity if:
        // 1. It's trash day (today)
        // 2. It's the day before trash day (to remind users)
        let calendar = Calendar.current
        let now = Date()
        let isToday = calendar.isDate(nextPickupDate, inSameDayAs: now)
        let isTomorrow = calendar.isDate(nextPickupDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        
        return (isToday || isTomorrow) && pickupInfo.pickupType != .no_pickup
    }
    
    // MARK: - Private Methods
    
    private func checkForExistingActivity() {
        if let activity = Activity<TruckeeTrashLiveActivityAttributes>.activities.first {
            self.activity = activity
            self.currentActivity = .active(activity)
        }
    }
    
    private func createContentState(pickupInfo: DayPickupInfo, nextPickupDate: Date) -> TruckeeTrashLiveActivityContentState {
        let isToday = isToday(nextPickupDate)
        let timeRemaining = calculateTimeRemaining(to: nextPickupDate, isToday: isToday)
        
        return TruckeeTrashLiveActivityContentState(
            pickupType: pickupInfo.pickupType,
            isToday: isToday,
            timeRemaining: timeRemaining,
            nextPickupDate: nextPickupDate
        )
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    private func calculateTimeRemaining(to date: Date, isToday: Bool) -> String? {
        let calendar = Calendar.current
        let now = Date()
        
        if isToday {
            // Calculate hours/minutes remaining today
            let components = calendar.dateComponents([.hour, .minute], from: now, to: date)
            
            if let hours = components.hour, let minutes = components.minute {
                if hours > 0 {
                    return "\(hours)h \(minutes)m"
                } else if minutes > 0 {
                    return "\(minutes)m"
                } else {
                    return "Now"
                }
            }
        } else {
            // Calculate days remaining
            let components = calendar.dateComponents([.day], from: now, to: date)
            if let days = components.day, days > 0 {
                return days == 1 ? "1 day" : "\(days) days"
            }
        }
        
        return nil
    }
    
    private func schedulePeriodicUpdates(pickupInfo: DayPickupInfo, nextPickupDate: Date) {
        // Update every hour while active
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] timer in
            guard let self = self,
                  case .active = self.currentActivity else {
                timer.invalidate()
                return
            }
            
            // If it's past the pickup time, end the activity
            if Date() > nextPickupDate {
                self.endCurrentActivity()
                timer.invalidate()
                return
            }
            
            self.updateActivity(pickupInfo: pickupInfo, nextPickupDate: nextPickupDate)
        }
    }
}

// MARK: - Convenience Extensions

@available(iOS 16.1, *)
extension LiveActivityService {
    public func handlePickupInfoUpdate(pickupInfo: DayPickupInfo?, nextPickupDate: Date?) {
        guard let pickupInfo = pickupInfo,
              let nextPickupDate = nextPickupDate else {
            endCurrentActivity()
            return
        }
        
        let selectedPickupDay = SharedUserDefaults.selectedPickupDay
        let weekday = Weekday(rawValue: selectedPickupDay)?.displayName ?? "Friday"
        
        if shouldShowLiveActivity(for: pickupInfo, nextPickupDate: nextPickupDate) {
            if case .notStarted = currentActivity {
                startTrashDayActivity(pickupInfo: pickupInfo, nextPickupDate: nextPickupDate, pickupDay: weekday)
            } else {
                updateActivity(pickupInfo: pickupInfo, nextPickupDate: nextPickupDate)
            }
        } else {
            endCurrentActivity()
        }
    }
}
