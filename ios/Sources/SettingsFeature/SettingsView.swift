import SwiftUI
import TruckeeTrashKit

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                    Text("Select your preferred pickup day to see information for the next occurrence of that day. Notifications will be sent the evening before your selected day.")
                }
                
                Section {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                    
                    if viewModel.notificationsEnabled {
                        DatePicker(
                            "Notification Time",
                            selection: $viewModel.notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded the evening before your pickup day.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text("Truckee Trash helps you stay informed about pickup schedules in Truckee, California.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Version:")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                    }
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
        }
    }
}

// MARK: - Weekday Enum

enum Weekday: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    
    var displayName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        }
    }
}

#Preview {
    SettingsView()
}