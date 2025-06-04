import SwiftUI
import TruckeeTrashKit
import SettingsFeature
import NotificationsService

@main
struct TruckeeTrashApp: App {
    @StateObject private var notificationsService = NotificationsService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationsService)
                .onAppear {
                    // Request notification permissions on app launch
                    notificationsService.requestPermission { granted in
                        if granted {
                            notificationsService.schedulePickupReminders()
                        }
                    }
                }
        }
    }
}
