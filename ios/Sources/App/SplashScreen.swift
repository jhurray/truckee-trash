import SwiftUI
import TruckeeTrashKit

// MARK: - Animation Phase Enum
/// Defines the distinct phases of the splash screen animation.
enum SplashAnimationPhase: CaseIterable, Equatable {
    case initial
    case shrinking
    case revealing
    case finished

    /// The timing curve for each animation phase.
    var animation: Animation {
        switch self {
        case .initial:
            return .linear(duration: 0)
        case .shrinking:
            return .easeIn(duration: 0.4) // A bit quicker to feel snappy
        case .revealing:
            // This animation is the main event, where the logo scales up to reveal the app.
            // A spring animation adds a nice, subtle bounce.
            return .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)
        case .finished:
            return .linear(duration: 0)
        }
    }

    /// The duration to wait *after* a phase's animation completes before starting the next one.
    var duration: TimeInterval {
        switch self {
        case .initial: return 0.5 // Initial delay before animation starts
        case .shrinking: return 0.4 // Wait for the shrink animation to finish
        case .revealing: return 0.8 // Wait for the reveal animation to finish
        case .finished: return 0
        }
    }
}

// MARK: - Splash Screen View
/// This view is ONLY the splash screen layer. It animates and then calls a completion handler.
struct SplashScreen: View {
    /// A binding to control when the animation should start.
    let startAnimation: Bool
    /// A closure to call when the animation sequence is complete.
    let onAnimationFinished: () -> Void

    @State private var animationPhase: SplashAnimationPhase = .initial
    
    var body: some View {
        ZStack {
            // Layer 1: The dedicated background for the splash screen.
            // This will fade out with the rest of the view at the end.
            Color.appSplashBackground.ignoresSafeArea() // Using a system color for preview. Use your Color.appSplashBackground

            // Layer 2: The masking effect which reveals the content underneath.
            ZStack {
                // By using Color.clear, we are creating a "window" to see the
                // AppContentView that is layered behind this SplashScreen in the host.
                Color.clear
                
                logoImage
                    .scaleEffect(logoScaleForPhase)
                    .opacity(logoOpacityForPhase)
            }
            .mask {
                logoImage
                    .scaleEffect(logoScaleForPhase)
            }
        }
        // The .task modifier is now bound to the `startAnimation` property.
        // It will only execute when `startAnimation` changes to `true`.
        .task(id: startAnimation) {
            // Ensure we don't run the animation without the trigger.
            guard startAnimation else { return }

            for phase in SplashAnimationPhase.allCases {
                withAnimation(phase.animation) {
                    self.animationPhase = phase
                }
                if phase.duration > 0 {
                    // Hack to make it look cooler
                    if phase == .revealing {
                        try? await Task.sleep(for: .seconds(0.2))
                        onAnimationFinished()
                    } else {
                        try? await Task.sleep(for: .seconds(phase.duration))
                    }
                }
            }
        }
    }
    
    /// A computed property for the logo view to avoid repetition.
    private var logoImage: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 240, height: 240)
    }

    /// Determines the logo's scale factor for the current animation phase.
    private var logoScaleForPhase: CGFloat {
        switch animationPhase {
        case .initial: return 1.0
        case .shrinking: return 0.8
        case .revealing, .finished: return 50.0 // Scale large enough to cover any screen
        }
    }
    
    private var logoOpacityForPhase: CGFloat {
        switch animationPhase {
        case .initial: return 1
        case .shrinking: return 1
        case .revealing, .finished: return 0
        }
    }
}

// MARK: - App Content View
/// A placeholder for your app's main content view.
struct AppContentView: View {
    let onReset: () -> Void
    var body: some View {
        Color.red
            .ignoresSafeArea()
            .overlay(
                VStack {
                    Text("App Content Loaded")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                    Button("Reset Animation") {
                        onReset()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            )
    }
}


// MARK: - Preview & Hosting View
/// This view orchestrates the transition from the splash screen to the main content.
struct SplashScreenHost: View {
    @State private var showSplashScreen = true
    @State private var startAnimation = false
    @State private var viewId = 0

    var body: some View {
        ZStack {
            // Layer 1: Your main app content is always in the view hierarchy.
            AppContentView {
                // Reset all state for a clean restart of the preview.
                showSplashScreen = true
                startAnimation = false
                viewId += 1
            }

            // Layer 2: The splash screen is shown conditionally on top.
            if showSplashScreen {
                SplashScreen(startAnimation: startAnimation) {
                    // When the splash animation is done, we animate the
                    // state change that causes this view to be removed.
                    withAnimation(.easeOut(duration: 0.4)) {
                        showSplashScreen = false
                    }
                }
                // The transition modifier handles the fade-in/fade-out.
                .transition(.opacity)
            }
        }
        .id(viewId) // Change the ID to reset the view's state for the preview
        .overlay(alignment: .bottomTrailing) {
            // Only show the start button if the splash screen is visible
            // AND the animation hasn't been triggered yet.
            if showSplashScreen && !startAnimation {
                Button("Start Animation") {
                    startAnimation = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}

#Preview {
    SplashScreenHost()
}

