import SwiftUI
import TruckeeTrashKit
import SettingsFeature

struct MainView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingSettings = false
    
    #if DEBUG
    @State private var showingTestDatePicker = false
    #endif
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top section with pickup info
                    VStack(spacing: 24) {
                        #if DEBUG
                        if viewModel.isTestMode {
                            testModeIndicator
                        }
                        #endif
                        
                        // Main pickup display
                        if viewModel.isLoading {
                            loadingView
                        } else if let errorMessage = viewModel.errorMessage {
                            errorView(errorMessage)
                        } else {
                            pickupDisplayView
                        }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Settings button
                    settingsButton
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 32))
                }
                
                // Top toolbar (debug only)
                #if DEBUG
                VStack {
                    HStack {
                        Button(action: {
                            showingTestDatePicker = true
                        }) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title3)
                                .foregroundColor(viewModel.isTestMode ? .orange : .white.opacity(0.7))
                                .padding(8)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    
                    Spacer()
                }
                #endif
            }
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
    
    private var backgroundGradient: some View {
        Group {
            if let pickupInfo = viewModel.pickupInfo {
                switch pickupInfo.pickupType {
                case .recycling:
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .yard_waste:
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .trash_only:
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .no_pickup:
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.green.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    #if DEBUG
    private var testModeIndicator: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("TEST MODE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            if let testDate = viewModel.testDate {
                Text("• \(formatTestDate(testDate))")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.2))
        .cornerRadius(20)
    }
    #endif
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2.0)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Loading pickup info...")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
            
            Text("Oops!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            Button("Try Again") {
                viewModel.loadPickupInfo()
            }
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(25)
        }
    }
    
    private var pickupDisplayView: some View {
        VStack(spacing: 32) {
            // Big emoji
            if let pickupInfo = viewModel.pickupInfo {
                Text(pickupInfo.pickupType.emoji)
                    .font(.system(size: 120))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            // Date information
            VStack(spacing: 8) {
                if let nextPickupDate = viewModel.nextPickupDate {
                    Text(formatPickupDate(nextPickupDate))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                
                if let pickupInfo = viewModel.pickupInfo {
                    Text(pickupInfo.pickupType.userFriendlyDescription)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Time until pickup
            if let nextPickupDate = viewModel.nextPickupDate {
                timeUntilPickupView(nextPickupDate, currentDate: viewModel.currentDate)
            }
        }
    }
    
    private func timeUntilPickupView(_ pickupDate: Date, currentDate: Date) -> some View {
        let calendar = Calendar.current
        let now = currentDate
        
        let isToday = calendar.isDate(pickupDate, inSameDayAs: now)
        let isTomorrow = calendar.isDate(pickupDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        
        let timeText: String
        if isToday {
            timeText = "Today!"
        } else if isTomorrow {
            timeText = "Tomorrow"
        } else {
            let daysUntil = calendar.dateComponents([.day], from: now, to: pickupDate).day ?? 0
            timeText = "In \(daysUntil) days"
        }
        
        return Text(timeText)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.2))
            .cornerRadius(20)
    }
    
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                Text("Settings")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(25)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatPickupDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now) ?? now) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            return formatter.string(from: date)
        }
    }
    
    #if DEBUG
    private func formatTestDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return formatter.string(from: date)
    }
    
    private var testDatePickerView: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test Date Selection")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose a date to test pickup calculations.")
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
    #endif
}

// MARK: - Extensions

extension DayPickupTypeString {
    var emoji: String {
        switch self {
        case .recycling:
            return "♻️"
        case .yard_waste:
            return "🌿"
        case .trash_only:
            return "🗑️"
        case .no_pickup:
            return "❌"
        }
    }
    
    var userFriendlyDescription: String {
        switch self {
        case .recycling:
            return "Recycling + Trash Day"
        case .yard_waste:
            return "Yard Waste + Trash Day"
        case .trash_only:
            return "Trash Day"
        case .no_pickup:
            return "No Pickup Today"
        }
    }
}

#Preview {
    MainView()
}
