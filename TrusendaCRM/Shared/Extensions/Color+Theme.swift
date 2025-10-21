import SwiftUI

extension Color {
    // MARK: - Salesforce-Inspired Professional Theme
    
    // Primary Blue (Salesforce-inspired)
    static let primaryBlue = Color(red: 0, green: 0.44, blue: 0.82) // #0070D2
    static let primaryBlueLight = Color(red: 0.2, green: 0.54, blue: 0.92)
    static let primaryBlueDark = Color(red: 0, green: 0.34, blue: 0.72)
    
    // Neutral Grays (Premium)
    static let backgroundLight = Color(red: 0.96, green: 0.97, blue: 0.98) // #F4F6F9
    static let backgroundDark = Color(red: 0.11, green: 0.12, blue: 0.16) // #1C1F2A
    static let cardBackground = Color(UIColor.systemBackground)
    static let cardBackgroundSecondary = Color(UIColor.secondarySystemBackground)
    
    // Status Colors
    static let statusCold = Color(red: 0, green: 0.44, blue: 0.82) // Blue
    static let statusWarm = Color(red: 0.96, green: 0.58, blue: 0) // Orange
    static let statusHot = Color(red: 0.93, green: 0.26, blue: 0.21) // Red
    static let statusClosed = Color(red: 0.2, green: 0.78, blue: 0.35) // Green
    
    // Timeline Colors
    static let timelineImmediate = Color(red: 0.93, green: 0.26, blue: 0.21) // Red/urgent
    static let timelineHeating = Color(red: 0.96, green: 0.58, blue: 0) // Orange
    static let timelineUpcoming = Color(red: 0, green: 0.44, blue: 0.82) // Blue
    static let timelineOverdue = Color(red: 0.54, green: 0, blue: 0) // Dark red
    
    // Accent Colors
    static let accentTeal = Color(red: 0, green: 0.75, blue: 0.87) // #00BFDF
    static let successGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let errorRed = Color(red: 0.93, green: 0.26, blue: 0.21)
    static let warningOrange = Color(red: 0.96, green: 0.58, blue: 0)
    
    // Premium Success Toast Colors (Adaptive)
    static let successGreenLight = Color(red: 0.18, green: 0.80, blue: 0.44) // #2ECC71
    static let successMintLight = Color(red: 0.20, green: 0.89, blue: 0.65)
    static let successGreenDark = Color(red: 0.15, green: 0.70, blue: 0.30)
    static let successMintDark = Color(red: 0.10, green: 0.60, blue: 0.40)
}

extension View {
    // MARK: - Premium Shadow
    func premiumShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

