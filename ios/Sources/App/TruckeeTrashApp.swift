import SwiftUI
import TruckeeTrashKit
import SettingsFeature
import NotificationsService

extension Notification.Name {
    static let resetAppSetup = Notification.Name("resetAppSetup")
}

@main
struct TruckeeTrashApp: App {
    @StateObject private var notificationsService = NotificationsService()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                if hasCompletedOnboarding {
                    MainView()
                        .environmentObject(notificationsService)
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
                }
            }
        }
    }
}
