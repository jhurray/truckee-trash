import SwiftUI
import UserNotifications
import TruckeeTrashKit

struct OnboardingView: View {
    @State private var selectedPickupDay: Int?
    @State private var notificationPreference: NotificationPreference?
    @State private var currentStep: OnboardingStep = .pickupDay
    @State private var isRequestingPermissions = false
    
    let onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                Color.appOnboardingGradient()
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator
                    
                    Spacer()
                    
                    // Main content
                    VStack(spacing: 40) {
                        switch currentStep {
                        case .pickupDay:
                            pickupDayStep
                        case .notifications:
                            notificationStep
                        case .completing:
                            completingStep
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Bottom buttons
                    bottomButtons
                        .padding(.horizontal, 32)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 32))
                }
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(index <= currentStep.rawValue ? Color.blue : Color.appBorder.opacity(0.3))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 20)
    }
    
    private var pickupDayStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("🗑️")
                    .font(.system(size: 80))
                
                Text("Welcome to Truckee Trash!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("What day of the week is your trash pickup?")
                    .font(.title2)
                    .foregroundColor(Color.appSecondaryText)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    Button(action: {
                        selectedPickupDay = weekday.rawValue
                        withAnimation(.easeInOut(duration: 0.2)) {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                    }) {
                        HStack {
                            Text(weekday.displayName)
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if selectedPickupDay == weekday.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            } else {
                                Circle()
                                    .stroke(Color.appBorder.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPickupDay == weekday.rawValue ? Color.appSelectedCardBackground : Color.appCardBackground)
                                .shadow(color: Color.appShadow, radius: 2, x: 0, y: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var notificationStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("🔔")
                    .font(.system(size: 80))
                
                Text("Stay Informed")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("When would you like to be reminded about trash day?")
                    .font(.title2)
                    .foregroundColor(Color.appSecondaryText)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(NotificationPreference.allCases, id: \.self) { preference in
                    Button(action: {
                        notificationPreference = preference
                        withAnimation(.easeInOut(duration: 0.2)) {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preference.title)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Text(preference.description)
                                    .font(.body)
                                    .foregroundColor(Color.appSecondaryText)
                            }
                            
                            Spacer()
                            
                            if notificationPreference == preference {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            } else {
                                Circle()
                                    .stroke(Color.appBorder.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(notificationPreference == preference ? Color.appSelectedCardBackground : Color.appCardBackground)
                                .shadow(color: Color.appShadow, radius: 2, x: 0, y: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var completingStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("✅")
                    .font(.system(size: 80))
                
                Text("All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("We're setting up your trash day reminders...")
                    .font(.title2)
                    .foregroundColor(Color.appSecondaryText)
                    .multilineTextAlignment(.center)
            }
            
            ProgressView()
                .scaleEffect(1.5)
        }
    }
    
    private var bottomButtonDisabled: Bool {
        switch currentStep {
        case .pickupDay:
            return selectedPickupDay == nil
        case .notifications:
            return isRequestingPermissions || notificationPreference == nil
        case .completing:
            return true
        }
    }
    
    private var bottomButtons: some View {
        VStack(spacing: 16) {
            switch currentStep {
            case .pickupDay:
                Button(action: nextStep) {
                    Text("Continue")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.appInverseText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(bottomButtonDisabled ? Color.appBorder : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(bottomButtonDisabled)
                
            case .notifications:
                Button(action: nextStep) {
                    Text(isRequestingPermissions ? "Setting up..." : "Finish Setup")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.appInverseText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(bottomButtonDisabled ? Color.appBorder : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(bottomButtonDisabled)
                
            case .completing:
                EmptyView()
            }
        }
    }
    
    private func nextStep() {
        guard !bottomButtonDisabled else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        switch currentStep {
        case .pickupDay:
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .notifications
            }
            
        case .notifications:
            finishOnboarding()
            
        case .completing:
            break
        }
    }
    
    private func finishOnboarding() {
        guard let notificationPreference else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .completing
        }
        
        // Save pickup day
        UserDefaults.standard.set(selectedPickupDay, forKey: "selectedPickupDay")
        UserDefaults.standard.set(notificationPreference.rawValue, forKey: "notificationPreference")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        if notificationPreference != .none {
            isRequestingPermissions = true
            
            // Request notification permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
                    
                    if granted {
                        scheduleNotifications()
                    }
                    
                    // Complete onboarding after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onComplete()
                    }
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: "notificationsEnabled")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
        }
    }
    
    private func scheduleNotifications() {
        // Implementation would go here - similar to existing notification scheduling
        // This would use the notificationPreference to determine timing
    }
}


#Preview {
    OnboardingView(onComplete: {})
}
