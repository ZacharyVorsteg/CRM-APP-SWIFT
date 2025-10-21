import SwiftUI

/// Welcome onboarding for new users - matches web app's tour
struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "building.2.fill",
            iconColor: .primaryBlue,
            title: "Welcome to Trusenda",
            subtitle: "Commercial & Industrial Real Estate",
            description: "Built by Realtors, for Realtors. Manage your pipeline with enterprise-grade tools."
        ),
        OnboardingPage(
            icon: "person.3.fill",
            iconColor: .successGreen,
            title: "Track Every Lead",
            description: "Capture prospects with detailed profiles: contact info, property requirements, budgets, and timelines."
        ),
        OnboardingPage(
            icon: "calendar.badge.clock",
            iconColor: .warningOrange,
            title: "Never Miss a Follow-Up",
            description: "Schedule reminders, snooze leads, and get notifications when prospects heat up."
        ),
        OnboardingPage(
            icon: "link.circle.fill",
            iconColor: .accentTeal,
            title: "Share Your Lead Form",
            description: "Generate a public form link to collect leads from your website, emails, or social media."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            iconColor: .primaryBlueDark,
            title: "Let's Get Started!",
            description: "Tap the + button to add your first lead and start closing deals."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0, green: 0.12, blue: 0.25), Color(red: 0, green: 0.2, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                            .id(index) // Force proper view identity for smooth transitions
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage) // Smooth page transitions
                
                // Buttons - Fixed height container for seamless transitions
                VStack(spacing: 16) {
                    // Main action button (consistent size)
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        if currentPage == pages.count - 1 {
                            // Last page - Get Started
                            let successGenerator = UINotificationFeedbackGenerator()
                            successGenerator.notificationOccurred(.success)
                            UserDefaults.standard.set(false, forKey: "isNewUser")
                            withAnimation {
                                showWelcome = false
                            }
                        } else {
                            // Next page
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    } label: {
                        HStack {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                .fontWeight(currentPage == pages.count - 1 ? .bold : .semibold)
                            Image(systemName: currentPage == pages.count - 1 ? "arrow.right.circle.fill" : "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 24) // Fixed height for text content
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 40)
                    
                    // Skip button placeholder (fixed height even when hidden)
                    Group {
                        if currentPage < pages.count - 1 {
                            Button {
                                UserDefaults.standard.set(false, forKey: "isNewUser")
                                withAnimation {
                                    showWelcome = false
                                }
                            } label: {
                                Text("Skip")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        } else {
                            // Invisible placeholder to maintain spacing
                            Text("Skip")
                                .foregroundColor(.clear)
                        }
                    }
                    .frame(height: 20) // Fixed height for skip button area
                }
                .padding(.bottom, 50)
                .frame(height: 130) // Fixed total height for button area
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String?
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon or Logo
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                // Inner glow
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 120, height: 120)
                
                // Use logo for first page, SF Symbol for others
                if page.icon == "building.2.fill" {
                    // Trusenda Logo - seamlessly masked
                    ZStack {
                        // White background card
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                        
                        // Logo with masking
                        Image("TrusendaLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .clipShape(RoundedRectangle(cornerRadius: 20)) // Masks JPG edges
                    }
                } else {
                    // SF Symbol icon for other pages
                    Image(systemName: page.icon)
                        .font(.system(size: 55))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.bottom, 20)
            
            // Text content - Fixed height container for consistent layout
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Subtitle area with fixed height (even when empty)
                Group {
                    if let subtitle = page.subtitle {
                        Text(subtitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accentTeal)
                            .multilineTextAlignment(.center)
                    } else {
                        // Invisible placeholder to maintain spacing
                        Text(" ")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.clear)
                    }
                }
                .frame(height: 20) // Fixed height for subtitle area
                
                Text(page.description)
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity) // Ensure full width
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryBlue, Color.primaryBlueDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.primaryBlue.opacity(0.4), radius: 8, x: 0, y: 4)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

