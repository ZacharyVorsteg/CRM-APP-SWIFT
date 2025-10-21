import SwiftUI

/// App-wide constants for visual consistency
struct AppConstants {
    // MARK: - Spacing (Uniform across all screens)
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 12
    static let itemSpacing: CGFloat = 8
    static let listPadding: CGFloat = 12
    
    // MARK: - Corner Radius (Consistent cards)
    static let cardRadius: CGFloat = 12
    static let buttonRadius: CGFloat = 10
    static let badgeRadius: CGFloat = 8
    
    // MARK: - Shadows (Subtle elevation)
    static let cardShadow: (Color, CGFloat, CGFloat, CGFloat) = (Color.black.opacity(0.06), 6, 0, 2)
    static let buttonShadow: (Color, CGFloat, CGFloat, CGFloat) = (Color.black.opacity(0.08), 4, 0, 2)
    
    // MARK: - Typography Hierarchy
    static let headerSize: CGFloat = 20
    static let subheaderSize: CGFloat = 17
    static let bodySize: CGFloat = 15
    static let captionSize: CGFloat = 13
    static let smallSize: CGFloat = 11
    
    // MARK: - Animation Durations
    static let quickAnimation: Double = 0.2
    static let normalAnimation: Double = 0.3
    static let slowAnimation: Double = 0.5
}

/// View modifier for consistent card styling
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppConstants.cardRadius)
                    .fill(Color.cardBackground)
                    .shadow(
                        color: AppConstants.cardShadow.0,
                        radius: AppConstants.cardShadow.1,
                        x: AppConstants.cardShadow.2,
                        y: AppConstants.cardShadow.3
                    )
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    /// Haptic feedback helper
    func withHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}

