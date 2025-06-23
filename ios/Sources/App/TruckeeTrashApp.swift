import SwiftUI
import TruckeeTrashKit
import SettingsFeature
import NotificationsService

#if DEBUG
import TruckeeTrashKit
#endif

extension Notification.Name {
    static let resetAppSetup = Notification.Name("resetAppSetup")
}

@main
struct TruckeeTrashApp: App {
    @StateObject private var notificationsService = NotificationsService()
    @StateObject private var liveActivityService: LiveActivityService = {
        if #available(iOS 16.1, *) {
            return LiveActivityService()
        } else {
            // Return a mock or empty service for older iOS versions
            return LiveActivityService()
        }
    }()
    @State private var hasCompletedOnboarding = SharedUserDefaults.hasCompletedOnboarding
    @Environment(\.scenePhase) private var scenePhase
    
    @MainActor
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                if hasCompletedOnboarding {
                    MainView()
                        .environmentObject(notificationsService)
                        .environmentObject(liveActivityService)
                } else {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .resetAppSetup)) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    hasCompletedOnboarding = false
                    SharedUserDefaults.hasCompletedOnboarding = false
                }
                
                #if DEBUG
                // Clear debug test date when resetting app
                DebugTestDateHelper.clearTestDate()
                #endif
            }
            .onAppear {
                // Migrate from old UserDefaults to shared container on first launch
                SharedUserDefaults.migrateFromStandardUserDefaults()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // Refresh notifications when app becomes active to ensure they're up to date
                    notificationsService.refreshNotificationsIfNeeded()
                }
            }
        }
    }
}
