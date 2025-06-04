import SwiftUI
import TruckeeTrashKit
import SettingsFeature
import NotificationsService

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @EnvironmentObject private var notificationsService: NotificationsService
    @State private var showingSettings = false
    
    #if DEBUG
    @State private var showingTestDatePicker = false
    #endif
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Main content
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else {
                    pickupInfoView
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Truckee Trash")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
                
                #if DEBUG
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingTestDatePicker = true
                    }) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(viewModel.isTestMode ? .orange : .blue)
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            #if DEBUG
            .sheet(isPresented: $showingTestDatePicker) {
                testDatePickerView
            }
            #endif
            .onAppear {
                viewModel.loadPickupInfo()
            }
            .refreshable {
                viewModel.loadPickupInfo()
            }
        }
        .ignoresSafeArea()
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            #if DEBUG
            if viewModel.isTestMode {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("TEST MODE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            #endif
            
            Text("Next Pickup Day")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let nextPickupDate = viewModel.nextPickupDate {
                Text(formatPickupDate(nextPickupDate))
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            #if DEBUG
            if let testDate = viewModel.testDate {
                Text("Testing from: \(formatTestDate(testDate))")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            #endif
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading pickup information...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                viewModel.loadPickupInfo()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var pickupInfoView: some View {
        VStack(spacing: 24) {
            // Main pickup info card
            if let pickupInfo = viewModel.pickupInfo {
                pickupCard(pickupInfo)
            }
            
            // Additional info
            infoSection
        }
    }
    
    private func pickupCard(_ pickupInfo: DayPickupInfo) -> some View {
        VStack(spacing: 16) {
            // Pickup type icon and title
            HStack(spacing: 12) {
                Image(systemName: pickupTypeIcon(pickupInfo.pickupType))
                    .font(.system(size: 32))
                    .foregroundColor(pickupTypeColor(pickupInfo.pickupType))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pickupInfo.pickupType.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(pickupInfo.pickupType.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Time until pickup
            if let nextPickupDate = viewModel.nextPickupDate {
                timeUntilPickupView(nextPickupDate)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(pickupTypeColor(pickupInfo.pickupType).opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(pickupTypeColor(pickupInfo.pickupType), lineWidth: 2)
        )
    }
    
    private func timeUntilPickupView(_ pickupDate: Date) -> some View {
        let daysUntil = Calendar.truckeeCalendar.dateComponents([.day], from: Date(), to: pickupDate).day ?? 0
        
        return HStack {
            Image(systemName: "clock")
                .foregroundColor(.secondary)
            
            Text(timeUntilPickupText(daysUntil))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pickup Schedule")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("Regular trash: Monday - Friday")
                        .font(.body)
                }
                
                HStack {
                    Image(systemName: "arrow.3.trianglepath")
                        .foregroundColor(.blue)
                    Text("Recycling: Every other Friday")
                        .font(.body)
                }
                
                HStack {
                    Image(systemName: "leaf")
                        .foregroundColor(.green)
                    Text("Yard waste: Seasonal Fridays")
                        .font(.body)
                }
            }
            .padding(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Helper Methods
    
    private func formatPickupDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        
        let calendar = Calendar.truckeeCalendar
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return formatter.string(from: date)
        }
    }
    
    private func timeUntilPickupText(_ daysUntil: Int) -> String {
        switch daysUntil {
        case 0:
            return "Pickup is today!"
        case 1:
            return "Pickup is tomorrow"
        case 2...6:
            return "Pickup in \(daysUntil) days"
        default:
            return "Pickup in \(daysUntil) days"
        }
    }
    
    private func pickupTypeIcon(_ type: DayPickupTypeString) -> String {
        switch type {
        case .recycling:
            return "arrow.3.trianglepath"
        case .yard_waste:
            return "leaf.fill"
        case .trash_only:
            return "trash"
        case .no_pickup:
            return "xmark.circle"
        }
    }
    
    private func pickupTypeColor(_ type: DayPickupTypeString) -> Color {
        switch type {
        case .recycling:
            return .blue
        case .yard_waste:
            return .green
        case .trash_only:
            return .gray
        case .no_pickup:
            return .red
        }
    }
    
    #if DEBUG
    private var testDatePickerView: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test Date Selection")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose a date to test pickup calculations from that specific date.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                DatePicker(
                    "Test Date",
                    selection: Binding(
                        get: { viewModel.testDate ?? Date() },
                        set: { viewModel.setTestDate($0) }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                
                if viewModel.isTestMode {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text("Test mode is active. The app will calculate pickup dates from your selected test date.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("Clear Test Date") {
                        viewModel.clearTestDate()
                        showingTestDatePicker = false
                    }
                    .buttonStyle(.bordered)
                    .disabled(!viewModel.isTestMode)
                    
                    Button("Done") {
                        showingTestDatePicker = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Test Date")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatTestDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return formatter.string(from: date)
    }
    #endif
}

#Preview {
    ContentView()
}
