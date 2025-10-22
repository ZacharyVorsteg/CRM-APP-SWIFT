import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showSignup = false
    @State private var showForgotPassword = false
    @State private var showBiometricPrompt = false
    @State private var animateIcons = false
    @State private var animateLogo = false
    @State private var shakeError = false
    @State private var enableFaceID = false
    @State private var attemptingBiometric = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    // Biometric availability
    private var biometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private var biometricType: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Biometric"
        }
        
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric"
        }
    }
    
    private var hasSavedCredentials: Bool {
        KeychainManager.shared.isBiometricEnabled()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium multi-layer gradient background with depth
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0, green: 0.37, blue: 0.83), // Salesforce blue
                            Color(red: 0, green: 0.25, blue: 0.55),
                            Color(red: 0, green: 0.12, blue: 0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle building motif overlay for real estate context
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.03),
                            Color.clear,
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 40)
                        
                        // Logo and branding with animations
                        VStack(spacing: 16) {
                            // Animated logo container
                            ZStack {
                                // Pulsing outer glow
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(animateLogo ? 0.3 : 0.2))
                                    .frame(width: 120, height: 120)
                                    .blur(radius: 12)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateLogo)
                                
                                // Premium gradient card
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white, Color(red: 0.95, green: 0.96, blue: 0.97)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 110, height: 110)
                                    .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.8), Color.white.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                
                                // Your logo with scale animation - seamlessly masked
                                Image("TrusendaLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 18)) // Mask to hide JPG edges
                                    .scaleEffect(animateLogo ? 1.0 : 0.95)
                            }
                            .padding(.bottom, 4)
                            
                            // Brand name with shadow
                            Text("Trusenda")
                                .font(.system(size: 42, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .kerning(0.5)
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            // Tagline with italic gray
                            VStack(spacing: 4) {
                                Text("COMMERCIAL & INDUSTRIAL")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(red: 0, green: 0.75, blue: 0.85))
                                    .tracking(1.2)
                                
                                Text("REAL ESTATE CRM")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(red: 0, green: 0.75, blue: 0.85))
                                    .tracking(1.2)
                                
                                Text("Built by Realtors, for Realtors")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .italic()
                                    .padding(.top, 2)
                            }
                            
                            // Enhanced value propositions with animations
                            VStack(spacing: 12) {
                                // Security badge with green check
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16, weight: .semibold))
                                        .scaleEffect(animateIcons ? 1.0 : 0.8)
                                    Text("Secure & Encrypted")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white.opacity(0.95))
                                }
                                
                                // Honest productivity teasers
                                HStack(spacing: 16) {
                                    // Pipeline management
                                    HStack(spacing: 6) {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(.accentTeal)
                                            .font(.system(size: 13))
                                            .scaleEffect(animateIcons ? 1.0 : 0.8)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Manage")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                            Text("Pipeline")
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 1, height: 30)
                                    
                                    // Sync metric
                                    HStack(spacing: 6) {
                                        Image(systemName: "icloud.and.arrow.up.fill")
                                            .foregroundColor(.accentTeal)
                                            .font(.system(size: 13))
                                            .scaleEffect(animateIcons ? 1.0 : 0.8)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Cloud")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                            Text("Synced")
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                            }
                            .padding(.top, 12)
                        }
                        .padding(.bottom, 28)
                        .opacity(animateLogo ? 1 : 0)
                        .offset(y: animateLogo ? 0 : -20)
                        
                        // Secure Login indicator with shield
                        HStack(spacing: 8) {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(.accentTeal)
                                .font(.system(size: 14))
                            Text("Secure Login")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white.opacity(0.95))
                        }
                        .padding(.bottom, 8)
                        .opacity(animateLogo ? 1 : 0)
                        
                        // Premium login form card
                        VStack(spacing: 20) {
                            // Email field with enhanced styling
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.primaryBlue)
                                        .font(.system(size: 12))
                                    Text("Email")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                                
                                TextField("your@email.com", text: $viewModel.email)
                                    .foregroundColor(.black) // FIX: Explicit black text
                                    .accentColor(.primaryBlue) // Blue cursor
                                    .textFieldStyle(PremiumTextFieldStyle(
                                        isFocused: focusedField == .email,
                                        hasError: !viewModel.email.isEmpty && !Validation.isValidEmail(viewModel.email)
                                    ))
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                    .onChange(of: viewModel.email) { _ in
                                        // Auto-clear error on re-type
                                        if viewModel.error != nil {
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                viewModel.error = nil
                                            }
                                        }
                                    }
                                    .onSubmit {
                                        // Auto-focus password after email
                                        if Validation.isValidEmail(viewModel.email) {
                                            focusedField = .password
                                        }
                                    }
                                
                                // Real-time validation with high contrast
                                if !viewModel.email.isEmpty {
                                    if Validation.isValidEmail(viewModel.email) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.system(size: 12, weight: .bold))
                                            Text("Valid email")
                                                .font(.caption.bold())
                                                .foregroundColor(.green)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.green.opacity(0.15))
                                        )
                                    } else {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12, weight: .bold))
                                            Text("Invalid email format")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(red: 1.0, green: 0.23, blue: 0.19))
                                                .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                                        )
                                    }
                                }
                            }
                            
                            // Password field with enhanced styling
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.primaryBlue)
                                        .font(.system(size: 12))
                                    Text("Password")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                                
                                SecureField("Enter password", text: $viewModel.password)
                                    .foregroundColor(.black) // FIX: Explicit black text for dots
                                    .accentColor(.primaryBlue) // Blue cursor
                                    .textFieldStyle(PremiumTextFieldStyle(
                                        isFocused: focusedField == .password,
                                        hasError: false
                                    ))
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .onChange(of: viewModel.password) { _ in
                                        // Auto-clear error on re-type
                                        if viewModel.error != nil {
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                viewModel.error = nil
                                            }
                                        }
                                    }
                            }
                            
                            // Forgot Password - emphasized for better recovery
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                showForgotPassword = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Forgot password?")
                                        .font(.subheadline.weight(.bold))
                                }
                                .foregroundColor(.accentTeal)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentTeal.opacity(0.1))
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, -4)
                            
                            // High-contrast error message with animation
                            if let error = viewModel.error {
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                    Text(error)
                                        .font(.footnote.bold())
                                        .foregroundColor(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30 iOS red
                                        )
                                        .shadow(color: Color.red.opacity(0.5), radius: 8, x: 0, y: 4)
                                )
                                .modifier(ShakeEffect(shakes: shakeError ? 3 : 0))
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                            
                            // Enable Face ID checkbox (if biometrics available)
                            if biometricsAvailable && !viewModel.email.isEmpty && !viewModel.password.isEmpty {
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        enableFaceID.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: enableFaceID ? "checkmark.square.fill" : "square")
                                            .foregroundColor(enableFaceID ? .accentTeal : .white.opacity(0.6))
                                            .font(.system(size: 18))
                                        Text("Enable \(biometricType) for quick sign in")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 8)
                            }
                            
                            // Premium Login button with gradient
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task {
                                    await viewModel.login(enableBiometric: enableFaceID)
                                    if viewModel.error != nil {
                                        // Error haptic feedback
                                        let errorGenerator = UINotificationFeedbackGenerator()
                                        errorGenerator.notificationOccurred(.error)
                                        
                                        // Shake animation
                                        withAnimation(.default) {
                                            shakeError = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            shakeError = false
                                        }
                                    }
                                }
                            } label: {
                                if viewModel.isLoading {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Signing In...")
                                            .fontWeight(.bold)
                                    }
                                } else {
                                    HStack(spacing: 8) {
                                        Text("Sign In")
                                            .fontWeight(.bold)
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .buttonStyle(PremiumGradientButtonStyle())
                            .disabled(viewModel.isLoading)
                            
                            // Face ID Quick Login (if credentials saved)
                            if hasSavedCredentials && biometricsAvailable {
                                Button {
                                    authenticateWithBiometrics()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: biometricType == "Face ID" ? "faceid" : "touchid")
                                            .font(.system(size: 16))
                                        Text("Sign in with \(biometricType)")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .foregroundColor(.accentTeal)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.accentTeal.opacity(0.15))
                                    )
                                }
                                .disabled(attemptingBiometric)
                                .padding(.top, 8)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.vertical, 8)
                            
                            // Prominent Sign Up button
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                showSignup = true
                            } label: {
                                VStack(spacing: 8) {
                                    HStack(spacing: 6) {
                                        Text("Don't have an account?")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Text("Create Account")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.accentTeal)
                                        Image(systemName: "arrow.right.circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.accentTeal)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.accentTeal.opacity(0.15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.accentTeal.opacity(0.5), lineWidth: 1.5)
                                            )
                                    )
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.12))
                                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .padding(.horizontal, 20)
                        .opacity(animateLogo ? 1 : 0)
                        .offset(y: animateLogo ? 0 : 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Staggered fade-in animations
                withAnimation(.easeOut(duration: 0.6)) {
                    animateLogo = true
                }
                
                withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                    animateIcons = true
                }
                
                // Auto-focus email field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    focusedField = .email
                }
            }
            .sheet(isPresented: $showSignup) {
                SignUpView()
            }
            .alert("Reset Password", isPresented: $showForgotPassword) {
                Button("Cancel", role: .cancel) { }
                Button("Send Reset Email") {
                    viewModel.error = "✅ Password reset email sent! Check your inbox."
                }
            } message: {
                Text("We'll send a password reset link to your email address")
            }
        }
    }
    
    // MARK: - Biometric Authentication
    func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func biometricName() -> String {
        let context = LAContext()
        return context.biometryType == .faceID ? "Face ID" : "Touch ID"
    }
    
    func biometricIcon() -> String {
        let context = LAContext()
        return context.biometryType == .faceID ? "faceid" : "touchid"
    }
    
    func authenticateWithBiometrics() {
        attemptingBiometric = true
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("❌ Biometrics not available:", error?.localizedDescription ?? "Unknown")
            viewModel.error = "Biometric authentication not available"
            attemptingBiometric = false
            return
        }
        
        let reason = "Sign in to Trusenda CRM quickly and securely"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
            DispatchQueue.main.async {
                if success {
                    // Biometric auth succeeded - login with saved credentials
                    Task {
                        do {
                            try await AuthManager.shared.loginWithBiometrics()
                            // Success haptic
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            print("✅ Signed in with \(biometricType)")
                        } catch {
                            viewModel.error = "Failed to sign in. Please try again."
                            let errorGenerator = UINotificationFeedbackGenerator()
                            errorGenerator.notificationOccurred(.error)
                        }
                        attemptingBiometric = false
                    }
                } else {
                    // Biometric auth failed or cancelled
                    if let error = authError as? LAError {
                        switch error.code {
                        case .userCancel, .appCancel, .systemCancel:
                            print("ℹ️ Biometric authentication cancelled")
                        case .userFallback:
                            print("ℹ️ User chose to enter password")
                            focusedField = .email
                        default:
                            viewModel.error = "Biometric authentication failed. Please use your password."
                        }
                    }
                    attemptingBiometric = false
                }
            }
        }
    }
}

// MARK: - Premium Text Field Style
struct PremiumTextFieldStyle: TextFieldStyle {
    let isFocused: Bool
    let hasError: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: isFocused ? Color.primaryBlue.opacity(0.3) : Color.black.opacity(0.08), radius: isFocused ? 12 : 6, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                hasError ? Color.red : (isFocused ? Color.primaryBlue : Color.clear),
                                lineWidth: 2
                            )
                    )
            )
            .font(.system(size: 16, weight: .medium))
            // Color is set on TextField itself, not here
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Premium Gradient Button Style
struct PremiumGradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.primaryBlue,
                                Color(red: 0, green: 0.35, blue: 0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color.primaryBlue.opacity(0.5),
                        radius: configuration.isPressed ? 8 : 16,
                        x: 0,
                        y: configuration.isPressed ? 2 : 6
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Shake Effect Modifier
struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: 10 * sin(shakes * .pi * 2), y: 0)
        )
    }
}

// MARK: - Sign Up View (With Legal Acceptance)
struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var agreedToTerms = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showLegalSummary = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Same premium gradient
                LinearGradient(
                    colors: [
                        Color(red: 0, green: 0.37, blue: 0.83),
                        Color(red: 0, green: 0.12, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .frame(width: 90, height: 90)
                                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                            
                            Image("TrusendaLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        }
                        .padding(.top, 60)
                        
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Join thousands of real estate professionals")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.bottom, 20)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white.opacity(0.9))
                                
                                TextField("", text: $viewModel.email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white.opacity(0.9))
                                
                                SecureField("", text: $viewModel.password)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .textContentType(.newPassword)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: viewModel.password.count >= 6 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(viewModel.password.count >= 6 ? .successGreen : .warningOrange)
                                    Text("Minimum 6 characters")
                                        .font(.caption)
                                        .foregroundColor(viewModel.password.count >= 6 ? .successGreen : .white.opacity(0.6))
                                }
                            }
                            
                            // Legal Agreement Section
                            LegalAgreementCheckbox(
                                agreedToTerms: $agreedToTerms,
                                showTerms: $showTerms,
                                showPrivacy: $showPrivacy,
                                showLegalSummary: $showLegalSummary
                            )
                            
                            if let error = viewModel.error {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(error.contains("created") ? .green : .red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button {
                                Task {
                                    await viewModel.signup()
                                    // Log acceptance after successful signup (stored locally)
                                    if viewModel.error == nil {
                                        logLegalAcceptance(email: viewModel.email)
                                    }
                                }
                            } label: {
                                if viewModel.isLoading {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Creating Account...")
                                            .fontWeight(.bold)
                                    }
                                } else {
                                    HStack(spacing: 8) {
                                        Text("Create Account")
                                            .fontWeight(.bold)
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                }
                            }
                            .buttonStyle(PremiumGradientButtonStyle())
                            .disabled(viewModel.isLoading || !agreedToTerms || viewModel.password.count < 6)
                            .opacity((viewModel.isLoading || !agreedToTerms || viewModel.password.count < 6) ? 0.6 : 1.0)
                            
                            if !agreedToTerms {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Please accept the terms to continue")
                                        .font(.caption)
                                }
                                .foregroundColor(.warningOrange)
                                .padding(.top, -4)
                            } else if viewModel.password.count < 6 {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Password must be at least 6 characters")
                                        .font(.caption)
                                }
                                .foregroundColor(.warningOrange)
                                .padding(.top, -4)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.12))
                                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            }.foregroundColor(.white))
            .sheet(isPresented: $showTerms) {
                SimpleLegalDocView(title: "Terms & Conditions", content: termsContent)
            }
            .sheet(isPresented: $showPrivacy) {
                SimpleLegalDocView(title: "Privacy Policy", content: privacyContent)
            }
            .sheet(isPresented: $showLegalSummary) {
                SimpleLegalSummaryView(
                    showTerms: $showTerms,
                    showPrivacy: $showPrivacy,
                    showSummary: $showLegalSummary
                )
            }
        }
    }
    
    // Helper to log acceptance locally
    private func logLegalAcceptance(email: String) {
        let timestamp = Date().ISO8601Format()
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let record = ["email": email, "timestamp": timestamp, "device": deviceId]
        
        var acceptances = UserDefaults.standard.array(forKey: "legalAcceptances") as? [[String: String]] ?? []
        acceptances.append(record)
        UserDefaults.standard.set(acceptances, forKey: "legalAcceptances")
        print("✅ Legal acceptance logged for \(email)")
    }
    
    // Simplified terms content (abbreviated for app size)
    private var termsContent: String {
        """
        TRUSENDA TERMS AND CONDITIONS
        
        Last Updated: October 16, 2025
        Version: 1.0
        
        IMPORTANT LEGAL NOTICE
        
        BY USING THIS SERVICE, YOU AGREE TO BE LEGALLY BOUND BY THESE TERMS INCLUDING BINDING ARBITRATION AND CLASS ACTION WAIVER.
        
        1. ACCEPTANCE
        By creating an account, you agree to these Terms, our Privacy Policy, and all applicable laws.
        
        2. LICENSE
        We grant you a limited, non-exclusive license to use the Service for your business purposes.
        
        3. ACCEPTABLE USE
        You agree NOT to:
        • Upload illegal or infringing content
        • Send spam or violate CAN-SPAM, TCPA
        • Store sensitive data (SSN, health info, financial accounts)
        • Contact individuals without consent
        
        4. YOUR DATA
        You own your data. We process it as your data processor.  You are responsible for backups.
        
        5. DISCLAIMER
        THE SERVICE IS PROVIDED "AS IS" WITHOUT WARRANTIES. We do not guarantee results, accuracy, or uninterrupted service.
        
        6. LIMITATION OF LIABILITY
        Our liability is limited to fees paid in the last 12 months or $100, whichever is greater.
        
        7. INDEMNIFICATION (UNCAPPED)
        You indemnify us for claims arising from your use, including TCPA violations, data breaches caused by you, or law violations.
        
        8. PAYMENTS
        Subscriptions auto-renew and are non-refundable.
        
        9. TERMINATION
        We may terminate your account for violations or at our discretion with notice.
        
        10. ARBITRATION
        Disputes resolved by binding arbitration in Florida. No class actions.
        
        Contact: legal@trusenda.com
        Full terms available at: trusenda.com/legal
        """
    }
    
    private var privacyContent: String {
        """
        TRUSENDA PRIVACY POLICY
        
        Last Updated: October 16, 2025
        Version: 1.0
        
        1. INFORMATION WE COLLECT
        • Account info (email, name, password)
        • Your customer data (you control this)
        • Usage analytics (anonymized)
        
        2. HOW WE USE IT
        • Provide the Service
        • Improve features
        • Send service updates
        • Legal compliance
        
        3. DATA SECURITY
        • Encryption (TLS 1.3, AES-256)
        • Secure password hashing
        • Regular security audits
        
        NO SYSTEM IS 100% SECURE. You accept inherent risks.
        
        4. DATA SHARING
        We do NOT sell your data. We share only with:
        • Service providers (hosting, payment processing)
        • As required by law
        
        5. YOUR RIGHTS
        • Access your data
        • Export your data
        • Delete your account
        • Opt out of marketing
        
        GDPR/CCPA: You have additional rights. Contact privacy@trusenda.com
        
        6. DATA RETENTION
        • Account data: Life of account + 60 days
        • Customer data: Life of account + 30 days
        • Backups: 90 days
        
        7. INTERNATIONAL TRANSFERS
        Data processed in the U.S. For EEA users, we use Standard Contractual Clauses.
        
        8. CHILDREN
        Not intended for users under 13.
        
        9. CONTACT
        privacy@trusenda.com
        dpo@trusenda.com (Data Protection Officer)
        
        Full policy: trusenda.com/legal/privacy
        """
    }
}

// MARK: - Legal Agreement Checkbox Component
struct LegalAgreementCheckbox: View {
    @Binding var agreedToTerms: Bool
    @Binding var showTerms: Bool
    @Binding var showPrivacy: Bool
    @Binding var showLegalSummary: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .background(Color.white.opacity(0.3))
                .padding(.vertical, 4)
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    agreedToTerms.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    CheckboxView(isChecked: agreedToTerms)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("I agree to the Terms & Conditions and Privacy Policy")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        LegalLinksRow(
                            showTerms: $showTerms,
                            showPrivacy: $showPrivacy,
                            showSummary: $showLegalSummary
                        )
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Checkbox View
struct CheckboxView: View {
    let isChecked: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(isChecked ? Color.accentTeal : Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.accentTeal)
            }
        }
    }
}

// MARK: - Legal Links Row
struct LegalLinksRow: View {
    @Binding var showTerms: Bool
    @Binding var showPrivacy: Bool
    @Binding var showSummary: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Button { showTerms = true } label: {
                Text("Read Terms")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.accentTeal)
                    .underline()
            }
            
            Text("•")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            Button { showPrivacy = true } label: {
                Text("Read Privacy")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.accentTeal)
                    .underline()
            }
            
            Text("•")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            Button { showSummary = true } label: {
                Text("Summary")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.accentTeal)
                    .underline()
            }
        }
    }
}

// MARK: - Simple Legal Document View
struct SimpleLegalDocView: View {
    let title: String
    let content: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Simple Legal Summary View
struct SimpleLegalSummaryView: View {
    @Binding var showTerms: Bool
    @Binding var showPrivacy: Bool
    @Binding var showSummary: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Legal Agreement Summary")
                        .font(.title2.bold())
                    
                    Text("By signing up, you agree to:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        BulletPoint(text: "Binding arbitration (no jury trials)")
                        BulletPoint(text: "Limited liability ($100 or fees paid)")
                        BulletPoint(text: "Unlimited indemnification for your violations")
                        BulletPoint(text: "No storing of sensitive data (SSN, health info)")
                        BulletPoint(text: "Compliance with CAN-SPAM and TCPA")
                        BulletPoint(text: "Auto-renewing, non-refundable subscriptions")
                    }
                    
                    HStack(spacing: 16) {
                        Button("Read Full Terms") {
                            dismiss()
                            showTerms = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Read Privacy Policy") {
                            dismiss()
                            showPrivacy = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Legal Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Bullet Point View
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 16, weight: .bold))
            Text(text)
                .font(.system(size: 15))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Custom Text Field Style (for signup)
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .font(.system(size: 16))
    }
}
