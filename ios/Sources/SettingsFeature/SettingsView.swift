import SwiftUI
import TruckeeTrashKit
import UserNotifications

extension Notification.Name {
    static let resetAppSetup = Notification.Name("resetAppSetup")
}

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("My Pickup Day", selection: $viewModel.selectedPickupDay) {
                        ForEach(Weekday.allCases, id: \.self) { weekday in
                            Text(weekday.displayName)
                                .tag(weekday.rawValue)
                        }
                    }
                    .pickerStyle(.wheel)
                } header: {
                    Text("Pickup Schedule")
                } footer: {
                    Text("Select your pickup day to see information for the next occurrence.")
                }
                
                Section {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                    
                    if viewModel.notificationsEnabled {
                        Picker("Notification Timing", selection: $viewModel.notificationPreference) {
                            ForEach(NotificationPreference.allCases, id: \.self) { preference in
                                if preference != .none {
                                    Text(preference.title)
                                        .tag(preference.rawValue)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded about your pickup day.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text("Truckee Trash helps you stay informed about pickup schedules in Truckee, California.")
                            .font(.body)
                            .foregroundColor(Color.appSecondaryText)
                        
                        HStack {
                            Text("Version:")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(Color.appSecondaryText)
                        }
                    }
                }
                
                Section {
                    Button("Reset App Setup") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                } footer: {
                    Text("This will clear all your settings and show the welcome screen again.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset App Setup", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAppSetup()
                }
            } message: {
                Text("This will clear all your settings and show the welcome screen again. Are you sure?")
            }
        }
    }
    
    private func resetAppSetup() {
        // Clear all shared user defaults
        SharedUserDefaults.hasCompletedOnboarding = false
        SharedUserDefaults.selectedPickupDay = 5 // Reset to Friday default
        SharedUserDefaults.notificationPreference = "evening_before"
        SharedUserDefaults.notificationsEnabled = false
        
        SharedUserDefaults.clearAll()
        
        // Cancel any scheduled notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Close settings and restart app flow
        dismiss()
        
        // Force app to restart by posting a notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .resetAppSetup, object: nil)
        }
    }
}


#Preview {
    SettingsView()
}
