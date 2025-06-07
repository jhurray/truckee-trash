import SwiftUI
import TruckeeTrashKit
import SettingsFeature

struct MainView: View {
    @StateObject private var viewModel: ContentViewModel
    @State private var showingSettings = false
    
    #if DEBUG
    @State private var showingTestDatePicker = false
    #endif
    
    init() {
        // This initializer will be used by the app and is guaranteed to run on the main actor.
        self._viewModel = StateObject(wrappedValue: ContentViewModel())
    }

    init(viewModel: ContentViewModel) {
        // This initializer is for previews, allowing injection of a mock view model.
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @MainActor
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
                                .foregroundColor(viewModel.isTestMode ? .orange : .appAlwaysLightTextSecondary)
                                .padding(8)
                                .background(Color.appShadow.opacity(0.3))
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
                        gradient: Gradient(colors: [Color(hex: "#007AFF"), Color(hex: "#0051D5")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .yard_waste:
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#34C759"), Color(hex: "#248A3D")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .trash_only:
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#48484A"), Color(hex: "#1C1C1E")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .no_pickup:
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#FF3B30"), Color(hex: "#D70015")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            } else {
                Color.appOnboardingGradient()
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
        .background(Color.appShadow.opacity(0.6))
        .cornerRadius(20)
    }
    #endif
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2.0)
                .progressViewStyle(CircularProgressViewStyle(tint: Color.appProgressTint))
            
            Text("Loading pickup info...")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(Color.appSecondaryText.opacity(0.9))
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.appAlwaysLightText.opacity(0.9))
            
            Text("Oops!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.appAlwaysLightText)
            
            Text(message)
                .font(.title3)
                .foregroundColor(Color.appAlwaysLightText.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            Button("Try Again") {
                viewModel.loadPickupInfo()
            }
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(Color.appButtonText)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.appButtonBackground)
            .cornerRadius(25)
            .shadow(color: Color.appShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    private var pickupDisplayView: some View {
        VStack(spacing: 32) {
            // Big emoji
            if let pickupInfo = viewModel.pickupInfo {
                Text(pickupInfo.pickupType.emoji)
                    .font(.system(size: 120))
                    .shadow(color: Color.appShadow, radius: 4, x: 0, y: 2)
            }
            
            // Main message based on timing
            if let nextPickupDate = viewModel.nextPickupDate, let pickupInfo = viewModel.pickupInfo {
                let calendar = Calendar.current
                let now = viewModel.currentDate
                let isToday = calendar.isDate(nextPickupDate, inSameDayAs: now)
                let isTomorrow = calendar.isDate(nextPickupDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
                
                VStack(spacing: 12) {
                    // Primary message
                    Text(primaryMessage(isToday: isToday, isTomorrow: isTomorrow, pickupInfo: pickupInfo))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appAlwaysLightText)
                        .multilineTextAlignment(.center)
                    
                    // Secondary message
                    if let secondaryMsg = secondaryMessage(isToday: isToday, isTomorrow: isTomorrow, date: nextPickupDate) {
                        Text(secondaryMsg)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Color.appAlwaysLightText.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
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
            .foregroundColor(Color.appButtonText)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.appButtonBackground)
            .cornerRadius(25)
            .shadow(color: Color.appShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Methods
    
    private func primaryMessage(isToday: Bool, isTomorrow: Bool, pickupInfo: DayPickupInfo) -> String {
        let serviceType = pickupInfo.pickupType.userFriendlyDescription
        
        if isToday {
            return "Today is \(serviceType)!"
        } else if isTomorrow {
            return "Tomorrow is \(serviceType)"
        } else {
            return "\(serviceType)"
        }
    }
    
    private func secondaryMessage(isToday: Bool, isTomorrow: Bool, date: Date) -> String? {
        if isToday || isTomorrow {
            return nil // No secondary message for today/tomorrow
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            return formatter.string(from: date)
        }
    }
    
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

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#if DEBUG

func dateString(for dayOffset: Int) -> String {
    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
    return formatter.string(from: date)
}

#Preview {
    struct PreviewWrapper: View {
        enum PreviewPickUpType: String, CaseIterable {
            case recycling
            case yard_waste
            case trash_only
            case no_pickup
            case error
            case loading
            
            @MainActor
            func mainView(for dayOffset: Int) -> some View {
                switch self {
                case .recycling:
                    return MainView(viewModel: .init(pickupInfo: .init(date: dateString(for: dayOffset), pickupType: .recycling)))
                case .yard_waste:
                    return MainView(viewModel: .init(pickupInfo: .init(date: dateString(for: dayOffset), pickupType: .yard_waste)))
                case .trash_only:
                    return MainView(viewModel: .init(pickupInfo: .init(date: dateString(for: dayOffset), pickupType: .trash_only)))
                case .no_pickup:
                    return MainView(viewModel: .init(pickupInfo: .init(date: dateString(for: dayOffset), pickupType: .no_pickup)))
                case .error:
                    return MainView(viewModel: .init(pickupInfo: nil, errorMessage: "Could not connect to the server."))
                case .loading: 
                    return MainView(viewModel: .init(pickupInfo: nil, isLoading: true))
                }
            }
        }
        
        @State var pickUpType: PreviewPickUpType = .recycling
        
        var body: some View {
            pickUpType.mainView(for: 0)
        }
    }
    
    return PreviewWrapper()
}
#endif
