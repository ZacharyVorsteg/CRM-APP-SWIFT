import SwiftUI

/// Premium success notification with elegant animations, undo, and edit functionality
/// Matches user feedback: gradients, shadows, typography hierarchy, auto-dismiss, haptics
struct PremiumSuccessToast: View {
    let leadName: String
    let onUndo: () -> Void
    let onDismiss: () -> Void
    
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkRotation: Double = -90
    @State private var opacity: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 14) {
            // Large animated checkmark with scale & rotation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(checkmarkScale)
                .rotationEffect(.degrees(checkmarkRotation))
            
            // Typography hierarchy: Bold title + lighter subtitle
            VStack(alignment: .leading, spacing: 3) {
                Text("Lead added")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("successfully")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
            }
            
            Spacer()
            
            // Undo & Edit button with subtle background
            Button(action: {
                // Haptic on undo tap
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onUndo()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 11, weight: .semibold))
                    Text("UNDO & EDIT")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            // Softer green gradient (#2ECC71 to mint) - Premium depth
            LinearGradient(
                colors: [
                    adaptiveGreen,
                    adaptiveMint
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        // Multiple shadow layers for depth
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: adaptiveGreen.opacity(0.35), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 90) // Above tab bar
        .opacity(opacity)
        .onAppear {
            // Choreographed entrance animation
            // Haptic feedback on appear
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
                checkmarkScale = 1.0
                checkmarkRotation = 0
            }
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    opacity = 0
                }
                
                // Dismiss after fade animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
    }
    
    // MARK: - Dark Mode Adaptive Colors
    
    private var adaptiveGreen: Color {
        // Softer green in light mode, darker in dark mode
        colorScheme == .dark 
            ? Color(red: 0.15, green: 0.70, blue: 0.30) // Darker green
            : Color(red: 0.18, green: 0.80, blue: 0.44) // #2ECC71
    }
    
    private var adaptiveMint: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.60, blue: 0.40) // Darker mint
            : Color(red: 0.20, green: 0.89, blue: 0.65) // Lighter mint
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            PremiumSuccessToast(
                leadName: "John Doe",
                onUndo: {
                    print("Undo tapped")
                },
                onDismiss: {
                    print("Dismissed")
                }
            )
        }
    }
}

