import SwiftUI

struct SplashScreenView: View {
    @Binding var showSplash: Bool
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var isAnimatingOut = false
    
    var body: some View {
        ZStack {
            // Premium gradient background matching login
            LinearGradient(
                colors: [
                    Color(red: 0, green: 0.37, blue: 0.83), // Salesforce blue
                    Color(red: 0, green: 0.12, blue: 0.25),
                    Color(red: 0, green: 0.2, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo container with seamless integration
                ZStack {
                    // Outer glow ring - soft atmospheric effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 85
                            )
                        )
                        .frame(width: 170, height: 170)
                        .blur(radius: 15)
                        .opacity(glowOpacity)
                        .scaleEffect(logoScale * 1.05)
                    
                    // Inner glow for depth
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 135, height: 135)
                        .blur(radius: 8)
                        .opacity(glowOpacity * 0.8)
                    
                    // White card with subtle gradient for depth
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 0.98, green: 0.99, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                        .shadow(color: Color.white.opacity(0.5), radius: 5, x: 0, y: -2) // Top highlight
                    
                    // Trusenda Logo - seamlessly integrated
                    ZStack {
                        // Subtle inner shadow for depth
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.black.opacity(0.02))
                            .frame(width: 120, height: 120)
                            .blur(radius: 3)
                        
                        // Logo with proper masking to hide JPG edges
                        Image("TrusendaLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 95, height: 95)
                            .clipShape(RoundedRectangle(cornerRadius: 22)) // Mask to match container
                            .padding(2) // Slight padding for clean edges
                    }
                    .drawingGroup() // Hardware acceleration
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Brand name
                Text("Trusenda")
                    .font(.system(size: 42, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .kerning(1.0)
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                    .opacity(logoOpacity)
                    .offset(y: textOffset)
                
                // Tagline
                VStack(spacing: 4) {
                    Text("COMMERCIAL & INDUSTRIAL")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0, green: 0.75, blue: 0.85))
                        .tracking(1.5)
                    
                    Text("REAL ESTATE CRM")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0, green: 0.75, blue: 0.85))
                        .tracking(1.5)
                }
                .opacity(logoOpacity * 0.9)
                .offset(y: textOffset - 5)
            }
        }
        .drawingGroup() // Hardware acceleration for entire view
        .onAppear {
            // Start entrance animation immediately with optimized timing
            animateEntrance()
            
            // Schedule smooth exit animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                animateExit()
            }
        }
    }
    
    // MARK: - Entrance Animation (Smooth & Fluid)
    private func animateEntrance() {
        // Stagger animations for smooth choreography
        
        // Logo scale and opacity - smooth spring with subtle "settle" effect
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Glow appears slightly delayed for depth effect
        withAnimation(.easeOut(duration: 0.6).delay(0.08)) {
            glowOpacity = 1.0
        }
        
        // Text slides up smoothly
        withAnimation(.spring(response: 0.65, dampingFraction: 0.82, blendDuration: 0).delay(0.15)) {
            textOffset = 0
        }
    }
    
    // MARK: - Exit Animation (Seamless Dissolve)
    private func animateExit() {
        isAnimatingOut = true
        
        // Seamless dissolve with slight scale for polish
        withAnimation(.easeInOut(duration: 0.4)) {
            logoOpacity = 0
            glowOpacity = 0
            logoScale = 1.05 // Subtle scale up as it fades (elegant effect)
        }
        
        // Text fades slightly faster for natural hierarchy
        withAnimation(.easeIn(duration: 0.3)) {
            textOffset = -10
        }
        
        // Dismiss after fade completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showSplash = false
        }
    }
}

