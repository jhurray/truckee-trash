import SwiftUI

private extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension Color {
    
    // MARK: - Background Colors
    
    static let appPrimaryBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.systemBackground
        default:
            return UIColor.systemBackground
        }
    })
    
    static let appSecondaryBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.secondarySystemBackground
        default:
            return UIColor.secondarySystemBackground
        }
    })
    
    static let appTertiaryBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.tertiarySystemBackground
        default:
            return UIColor.tertiarySystemBackground
        }
    })
    
    static let appCardBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.secondarySystemBackground
        default:
            return UIColor.systemBackground
        }
    })
    
    static let appSelectedCardBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.systemBlue.withAlphaComponent(0.3)
        default:
            return UIColor.systemBlue.withAlphaComponent(0.2)
        }
    })
    
    static let appOnboardingBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.black.withAlphaComponent(1)
        default:
            return UIColor.systemBlue.withAlphaComponent(0.25)
        }
    })
    
    static let appModalBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.secondarySystemBackground
        default:
            return UIColor.systemBackground
        }
    })
    
    static let appSplashBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.systemBackground
        default:
            return UIColor.systemBackground
        }
    })
    
    // MARK: - Text Colors
    
    static let appPrimaryText = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.label
        default:
            return UIColor.label
        }
    })
    
    static let appSecondaryText = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.secondaryLabel
        default:
            return UIColor.secondaryLabel
        }
    })
    
    static let appTertiaryText = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.tertiaryLabel
        default:
            return UIColor.tertiaryLabel
        }
    })
    
    static let appInverseText = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.black
        default:
            return UIColor.white
        }
    })
    
    static let appAlwaysLightText = Color(UIColor.white)
    static let appAlwaysLightTextSecondary = Color(UIColor.white.withAlphaComponent(0.7))
    
    static let appAlwaysDarkText = Color(UIColor.black)
    static let appAlwaysDarkTextSecondary = Color(UIColor.black.withAlphaComponent(0.7))
    
    // MARK: - Border Colors
    
    static let appBorder = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.separator
        default:
            return UIColor.separator
        }
    })
    
    static let appSubtleBorder = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.white.withAlphaComponent(0.1)
        default:
            return UIColor.black.withAlphaComponent(0.1)
        }
    })
    
    // MARK: - Button Colors
    
    static let appButtonBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.tertiarySystemBackground
        default:
            return UIColor.systemBackground
        }
    })
    
    static let appButtonText = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.label
        default:
            return UIColor.label
        }
    })
    
    // MARK: - Shadow Colors
    
    static let appShadow = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.black.withAlphaComponent(0.3)
        default:
            return UIColor.black.withAlphaComponent(0.1)
        }
    })
    
    static let appTextShadow = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.black.withAlphaComponent(0.6)
        default:
            return UIColor.black.withAlphaComponent(0.5)
        }
    })
    
    // MARK: - Gradient Backgrounds
    
    static let appOnboardingGradientStart = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(hex: 0x4A90E2, alpha: 0.3)
        default:
            return UIColor(hex: 0x4A90E2, alpha: 0.8)
        }
    })
    
    static let appOnboardingGradientEnd = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(hex: 0x50E3C2, alpha: 0.3)
        default:
            return UIColor(hex: 0x50E3C2, alpha: 0.8)
        }
    })
    
    static func appOnboardingGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [appOnboardingGradientStart, appOnboardingGradientEnd]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Loading States
    
    static let appLoadingBackground = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.systemBackground
        default:
            return UIColor.systemBackground
        }
    })
    
    static let appProgressTint = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.white
        default:
            return UIColor.secondaryLabel
        }
    })
}

#Preview {
    Color.appOnboardingGradient()
        .ignoresSafeArea()
}
