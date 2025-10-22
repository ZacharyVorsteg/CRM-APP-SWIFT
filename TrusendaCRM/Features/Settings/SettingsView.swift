import SwiftUI
import UniformTypeIdentifiers

// MARK: - Legal Document Text Constants
private let termsAndConditionsText = """
TRUSENDA TERMS AND CONDITIONS

Last Updated: October 16, 2025
Effective Date: October 16, 2025
Version: 1.0

IMPORTANT LEGAL NOTICE

PLEASE READ THESE TERMS CAREFULLY BEFORE USING THE SERVICE. BY USING THE SERVICE, YOU AGREE TO BE LEGALLY BOUND BY THESE TERMS INCLUDING BINDING ARBITRATION AND CLASS ACTION WAIVER.

These Terms constitute a legally binding agreement between you and Trusenda, LLC, a Florida limited liability company with its principal place of business in Palm Beach, Florida.

1. ACCEPTANCE
By using the Service, you agree to these Terms, our Privacy Policy, and all applicable laws.

2. LICENSE
We grant you a limited, non-exclusive license to use the Service for your business purposes. You may NOT modify, reverse engineer, rent, or sublicense the Service.

3. ACCEPTABLE USE
You agree NOT to:
• Upload illegal or infringing content
• Send spam or violate CAN-SPAM, TCPA
• Store sensitive data (SSN, health info, financial accounts)
• Contact individuals without consent
• Violate fair housing or anti-discrimination laws

4. YOUR DATA
You own your data. We process it as your data processor. You are responsible for backups.

5. INTELLECTUAL PROPERTY
The Service is owned by us and protected by intellectual property laws.

6. PRIVACY AND SECURITY
We implement encryption (TLS 1.3, AES-256), access controls, and security audits. However, NO SYSTEM IS COMPLETELY SECURE.

7. DISCLAIMERS
THE SERVICE IS PROVIDED "AS IS" WITHOUT WARRANTIES. We do not guarantee results, accuracy, or uninterrupted service. The Service is a software tool only, NOT professional advice.

8. LIMITATION OF LIABILITY
Our liability is limited to fees paid in the last 12 months or $100, whichever is greater. For data breaches: $10,000 maximum.

9. INDEMNIFICATION (UNCAPPED)
You indemnify us for ALL claims arising from your use, including TCPA violations, data breaches caused by you, or law violations. This indemnification is UNLIMITED.

10. PAYMENTS
Subscriptions auto-renew and are non-refundable. We may change fees upon 30 days' notice.

11. TERMINATION
We may terminate your account for violations or at our discretion with notice. Upon termination, we may delete your data after 30 days.

12. GOVERNING LAW
These Terms are governed by Florida law. Exclusive jurisdiction: Palm Beach County, Florida.

13. ARBITRATION
Disputes resolved by binding arbitration in Florida. No class actions. You waive your right to jury trial.

Contact: legal@trusenda.com
Full terms: trusenda.com/legal/terms
"""

private let privacyPolicyText = """
TRUSENDA PRIVACY POLICY

Last Updated: October 16, 2025
Version: 1.0

1. INFORMATION WE COLLECT
• Account information (email, name, password)
• Your customer data (you control this as data controller)
• Usage analytics (anonymized)
• Device information and crash data

2. HOW WE USE IT
• Provide and maintain the Service
• Improve features and develop new ones
• Send service updates and notifications
• Legal compliance and fraud prevention

3. DATA SECURITY
• Encryption in transit (TLS 1.3) and at rest (AES-256)
• Secure password hashing (bcrypt/Argon2)
• Regular security audits and penetration testing
• Multi-factor authentication options

NO SYSTEM IS 100% SECURE. You accept inherent risks of internet services.

4. DATA SHARING
We do NOT sell your data. We share only with:
• Service providers (hosting, payment processing)
• As required by law (subpoenas, court orders)

5. YOUR RIGHTS
• Access your data
• Export your data (JSON format)
• Delete your account
• Opt out of marketing emails

GDPR/CCPA Rights: You have additional rights including data portability, rectification, and the right to be forgotten. Contact privacy@trusenda.com to exercise these rights.

6. DATA RETENTION
• Account data: Life of account + 60 days
• Customer data: Life of account + 30 days
• Backups: 90-day rolling retention
• Logs: 13 months

After retention periods, we securely delete or anonymize data.

7. INTERNATIONAL TRANSFERS
Data may be processed in the U.S. and other countries. For EEA/UK users, we use Standard Contractual Clauses (SCCs).

8. CHILDREN'S PRIVACY
Not intended for users under 13. We do not knowingly collect children's data.

9. COOKIES AND TRACKING
We use essential cookies for authentication and session management. Third-party analytics may use cookies. You can disable non-essential cookies in Settings.

10. CONTACT US
privacy@trusenda.com (Privacy inquiries)
dpo@trusenda.com (Data Protection Officer)
support@trusenda.com (General support)
legal@trusenda.com (Legal questions)

Address: Trusenda, LLC, Palm Beach, FL
Full policy: trusenda.com/legal/privacy
"""

/// Settings View - Stable, Single Source of Truth
struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showDeleteConfirm = false
    @State private var confirmEmail = ""
    @State private var isUpgrading = false
    @State private var isLoadingPortal = false
    @State private var isExporting = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var isRefreshingAfterPayment = false
    @State private var showPaymentSuccessAlert = false
    @State private var showFeedback = false
    @State private var calendarBookingURL = ""
    @State private var isLoadingCalendarSettings = true
    @State private var isSavingCalendarURL = false
    @State private var showCalendarSaveSuccess = false
    @State private var showCalendarGuide = false
    @State private var calendarSaveAttempts = 0
    
    var body: some View {
        NavigationView {
            List {
                // Account
                if let user = authManager.currentUser, let tenant = settingsViewModel.tenantInfo {
                    Section("ACCOUNT") {
                        HStack {
                            Text("Plan")
                            Spacer()
                            Text(user.plan.capitalized)
                            Text(user.isPro ? "PRO" : "FREE")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(user.isPro ? Color.green.opacity(0.2) : Color.orange.opacity(0.2)))
                                .foregroundColor(user.isPro ? .green : .orange)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email).font(.callout)
                        }
                        
                        HStack {
                            Text("Leads")
                            Spacer()
                            Text("\(tenant.currentLeads) / \(tenant.maxLeads)").bold()
                        }
                    }
                }
                
                // Public Form
                if let form = settingsViewModel.publicForm {
                    Section("PUBLIC FORM") {
                        VStack(alignment: .leading, spacing: 12) {
                            // Description
                            Text("Share this link to receive lead submissions directly into your CRM")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                            
                            // URL Display with tap to open
                            Button {
                                if let url = URL(string: form.fullURL) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text(form.fullURL)
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundColor(.primaryBlue)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                            
                            HStack(spacing: 12) {
                                // Copy Button - Full width, professional style
                                Button {
                                    copyFormLinkToClipboard(form.fullURL)
                                } label: {
                                    Label("Copy Link", systemImage: "doc.on.doc")
                                        .frame(maxWidth: .infinity)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.primaryBlue)
                                
                                // Share Button - Same size, matching style
                                Button {
                                    shareFormLink(form.fullURL)
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.primaryBlue)
                            }
                        }
                    }
                }
                
                // Calendar Booking Integration - NEW!
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.primaryBlue)
                                .font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Instant Tour Booking")
                                    .font(.headline)
                                Text("Let leads book tours directly when they're interested")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // Info button
                            Button {
                                showCalendarGuide = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                        
                        // Calendar URL Input
                        TextField("https://calendly.com/your-name/tour", text: $calendarBookingURL)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                            .font(.system(size: 14))
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        // Help text
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Use Calendly, Google Calendar, or Cal.com (all free)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Save button
                        if !calendarBookingURL.isEmpty && calendarBookingURL.starts(with: "https://") {
                            Button {
                                Task {
                                    await saveCalendarURL()
                                }
                            } label: {
                                HStack {
                                    if isSavingCalendarURL {
                                        ProgressView()
                                            .scaleEffect(0.9)
                                            .tint(.white)
                                        Text("Saving...")
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Save Calendar URL")
                                    }
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.primaryBlue, Color.primaryBlueDark],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.primaryBlue.opacity(0.3), radius: 6, x: 0, y: 3)
                                )
                            }
                            .disabled(isSavingCalendarURL)
                        } else if !calendarBookingURL.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("URL must start with https://")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Help text for errors
                        if calendarSaveAttempts > 0 && !isSavingCalendarURL && !showCalendarSaveSuccess {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Having trouble saving?")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                                
                                Text("Make sure:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Text("•")
                                        Text("You have internet connection")
                                    }
                                    HStack(spacing: 4) {
                                        Text("•")
                                        Text("URL starts with https://")
                                    }
                                    HStack(spacing: 4) {
                                        Text("•")
                                        Text("You're logged in to Trusenda")
                                    }
                                }
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        }
                        
                        // Success message
                        if showCalendarSaveSuccess {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Calendar URL saved! Leads can now book tours instantly.")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                            )
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Label("INSTANT TOUR BOOKING", systemImage: "calendar.badge.plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primaryBlue)
                }
                
                // Billing
                if let user = authManager.currentUser {
                    Section("BILLING") {
                        if user.isPro {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.successGreen)
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Pro Subscription Active")
                                            .font(.headline)
                                        Text("10,000 leads • $29/month")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                
                                Button { Task { await openPortal() } } label: {
                                    if isLoadingPortal {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("Opening portal...")
                                        }
                                    } else {
                                        Label("Manage Subscription", systemImage: "creditcard.fill")
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.primaryBlue)
                                .disabled(isLoadingPortal)
                            }
                        } else {
                            Button { Task { await upgrade() } } label: {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.warningOrange)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Upgrade to Pro")
                                            .font(.headline)
                                        Text("10,000 leads • $29/month")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if isUpgrading {
                                        ProgressView()
                                            .scaleEffect(0.9)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(.primaryBlue)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .disabled(isUpgrading)
                        }
                    }
                }
                
                // Notifications - Clean and tucked away
                Section("NOTIFICATIONS") {
                    NavigationLink {
                        NotificationsView()
                            .environmentObject(authManager)
                            .environmentObject(settingsViewModel)
                    } label: {
                        Label("Alerts & Reminders", systemImage: "bell.badge")
                    }
                }
                
                // Feedback & Support
                Section("FEEDBACK & SUPPORT") {
                    Button {
                        showFeedback = true
                    } label: {
                        Label("Send Feedback", systemImage: "bubble.left.and.bubble.right")
                    }
                    
                    Link(destination: URL(string: "mailto:support@trusenda.com?subject=Trusenda%20Support%20Request")!) {
                        Label("Email Support", systemImage: "envelope")
                    }
                }
                
                // Legal
                Section("LEGAL") {
                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    
                    Button {
                        showTermsOfService = true
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
                
                // Actions
                Section("ACCOUNT") {
                    Button { Task { await resetPassword() } } label: {
                        Label("Change Password", systemImage: "key")
                    }
                    
                    Button { Task { await export() } } label: {
                        Label(isExporting ? "Exporting..." : "Export Data", systemImage: "arrow.down.doc")
                    }
                    .disabled(isExporting)
                    
                    Link(destination: URL(string: "mailto:support@trusenda.com")!) {
                        Label("Email Support", systemImage: "envelope")
                    }
                    
                    Button(role: .destructive) { authManager.logout() } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .refreshable {
                // Pull to refresh - background update + plan status check
                async let userRefresh: Void = authManager.fetchMe()
                async let tenantInfo: Void = settingsViewModel.fetchTenantInfo()
                async let publicForm: Void = settingsViewModel.fetchPublicForm()
                _ = try? await (userRefresh, tenantInfo, publicForm)
                
                // Check if plan was upgraded
                if authManager.currentUser?.isPro == true {
                    settingsViewModel.successMessage = "✅ Pro plan active!"
                }
            }
            .task {
                // Load calendar settings on appear
                await loadCalendarSettings()
            }
            .onChange(of: scenePhase) { newPhase in
                // Auto-refresh when app returns to foreground (from Stripe payment)
                if newPhase == .active && (isUpgrading || isLoadingPortal) {
                    Task {
                        await refreshAfterPayment()
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteConfirm) {
                TextField("Email", text: $confirmEmail)
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        guard confirmEmail == authManager.currentUser?.email else { return }
                        try? await settingsViewModel.deleteAccount(confirmEmail: confirmEmail)
                    }
                }
            }
            .alert("Payment Successful!", isPresented: $showPaymentSuccessAlert) {
                Button("OK") {
                    showPaymentSuccessAlert = false
                }
            } message: {
                Text("Your account has been upgraded to Pro! You now have access to 10,000 leads and all premium features.")
            }
            .overlay(alignment: .bottom) {
                Group {
                    if let msg = settingsViewModel.successMessage {
                        Text(msg)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.successGreen)
                                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            )
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if let err = settingsViewModel.error {
                        Text(err)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            )
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onTapGesture { settingsViewModel.clearError() }
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: settingsViewModel.successMessage)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: settingsViewModel.error)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                InAppLegalDocView(
                    title: "Privacy Policy",
                    content: privacyPolicyText,
                    icon: "lock.shield.fill"
                )
            }
            .sheet(isPresented: $showTermsOfService) {
                InAppLegalDocView(
                    title: "Terms & Conditions",
                    content: termsAndConditionsText,
                    icon: "doc.text.fill"
                )
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showCalendarGuide) {
                CalendarGuideView()
            }
            .onAppear {
                // Load calendar settings when view appears
                Task {
                    await loadCalendarSettings()
                }
            }
        }
    }
    
    private func upgrade() async {
        isUpgrading = true
        
        do {
            // Create Stripe checkout session - returns complete URL
            let checkoutURLString = try await settingsViewModel.createCheckoutSession()
            
            // Use the URL directly from backend (already validated by Stripe)
            guard let url = URL(string: checkoutURLString) else {
                throw StripePaymentError.unknown("Invalid payment URL received from server")
            }
            
            // Success feedback before opening Stripe
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            print("✅ Opening Stripe checkout: \(url.absoluteString)")
            
            // Open Stripe checkout in Safari
            await MainActor.run {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("❌ Failed to open Stripe URL")
                        Task { @MainActor in
                            settingsViewModel.error = "Unable to open payment page. Please try again."
                        }
                    } else {
                        print("✅ Stripe checkout opened successfully")
                        Task { @MainActor in
                            settingsViewModel.successMessage = "Redirected to Stripe. Complete payment to upgrade."
                        }
                    }
                }
            }
            
        } catch let error as StripePaymentError {
            // Handle Stripe-specific errors with clear messages
            print("❌ Stripe payment error: \(error.localizedDescription)")
            settingsViewModel.error = error.localizedDescription
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        } catch {
            // Handle unexpected errors
            print("❌ Unexpected upgrade error: \(error)")
            settingsViewModel.error = "Unable to start checkout. Please contact support@trusenda.com"
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isUpgrading = false
    }
    
    private func openPortal() async {
        isLoadingPortal = true
        
        do {
            // Create Stripe portal session with error handling
            let portalURL = try await settingsViewModel.createPortalSession()
            
            guard let url = URL(string: portalURL) else {
                throw StripePaymentError.unknown("Invalid portal URL generated")
            }
            
            // Success feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            print("✅ Opening Stripe portal in browser...")
            
            // Open Stripe portal in Safari
            await MainActor.run {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("❌ Failed to open portal URL")
                        Task { @MainActor in
                            settingsViewModel.error = "Unable to open billing portal. Please try again."
                        }
                    } else {
                        print("✅ Portal opened successfully")
                    }
                }
            }
            
        } catch let error as StripePaymentError {
            // Handle Stripe-specific errors
            print("❌ Portal error: \(error.localizedDescription)")
            settingsViewModel.error = error.localizedDescription
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        } catch {
            // Handle unexpected errors
            print("❌ Unexpected portal error: \(error)")
            settingsViewModel.error = "Unable to access billing portal. Please contact support@trusenda.com"
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isLoadingPortal = false
    }
    
    private func export() async {
        isExporting = true
        if let leads = try? await settingsViewModel.exportData(),
           let data = try? JSONEncoder().encode(leads),
           let json = String(data: data, encoding: .utf8) {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("trusenda-data.json")
            try? json.write(to: url, atomically: true, encoding: .utf8)
            await MainActor.run {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first,
                   let rootVC = window.rootViewController {
                    let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    rootVC.present(vc, animated: true)
                }
            }
        }
        isExporting = false
    }
    
    private func refreshAfterPayment() async {
        print("🔄 App became active - checking for payment completion...")
        isRefreshingAfterPayment = true
        
        // Small delay to ensure Stripe webhook has processed
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Fetch updated user and tenant info
        do {
            try await authManager.fetchMe()
            await settingsViewModel.fetchTenantInfo()
            
            // Check if user is now Pro
            if authManager.currentUser?.isPro == true {
                print("✅ User is now Pro! Payment successful.")
                showPaymentSuccessAlert = true
                settingsViewModel.successMessage = "🎉 Welcome to Pro! Your account has been upgraded."
                settingsViewModel.clearMessageAfterDelay()
                
                // Success haptic
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } else {
                print("ℹ️ User still on Free plan (payment may be processing)")
            }
        } catch {
            print("⚠️ Error refreshing after payment: \(error)")
        }
        
        isRefreshingAfterPayment = false
        isUpgrading = false
        isLoadingPortal = false
    }
    
    private func resetPassword() async {
        guard let email = authManager.currentUser?.email,
              let url = URL(string: "https://trusenda.com/.netlify/identity/recover") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["email": email])
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                settingsViewModel.successMessage = "✅ Reset email sent to \(email)"
            } else {
                settingsViewModel.error = "Failed to send reset email. Please try again."
            }
        } catch {
            settingsViewModel.error = "Network error: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Calendar Booking Functions
    
    private func loadCalendarSettings() async {
        isLoadingCalendarSettings = true
        
        do {
            let response: UserSettingsResponse = try await APIClient.shared.get(
                endpoint: .userSettings,
                requiresAuth: true
            )
            
            if let urlString = response.calendar_booking_url, !urlString.isEmpty {
                await MainActor.run {
                    calendarBookingURL = urlString
                }
                print("✅ Loaded calendar URL:", urlString)
            }
        } catch {
            print("⚠️ Failed to load calendar settings:", error)
            // Don't show error - this is non-critical
        }
        
        await MainActor.run {
            isLoadingCalendarSettings = false
        }
    }
    
    private func saveCalendarURL() async {
        guard !calendarBookingURL.isEmpty else {
            print("⚠️ Calendar URL is empty, nothing to save")
            return
        }
        
        guard calendarBookingURL.starts(with: "https://") else {
            print("❌ Invalid URL format - must start with https://")
            await MainActor.run {
                settingsViewModel.error = "Calendar URL must start with https://"
            }
            return
        }
        
        isSavingCalendarURL = true
        showCalendarSaveSuccess = false
        calendarSaveAttempts += 1
        
        print("📝 Saving calendar URL (attempt \(calendarSaveAttempts)):", calendarBookingURL)
        
        do {
            // Use APIClient's PATCH method
            let updateRequest = UserSettingsUpdateRequest(calendar_booking_url: calendarBookingURL)
            let updateResponse: UserSettingsUpdateResponse = try await APIClient.shared.patch(
                endpoint: .userSettings,
                body: updateRequest,
                requiresAuth: true
            )
            
            print("✅ Calendar URL saved successfully:", updateResponse.calendar_booking_url ?? "null")
            
            // Reset retry counter on success
            calendarSaveAttempts = 0
            
            // Success feedback
            await MainActor.run {
                showCalendarSaveSuccess = true
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
            // Hide success message after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                showCalendarSaveSuccess = false
            }
            
        } catch let error as NetworkError {
            print("❌ Failed to save calendar URL:", error)
            print("   Error description:", error.localizedDescription)
            
            await MainActor.run {
                // User-friendly error messages based on error type
                switch error {
                case .unauthorized:
                    settingsViewModel.error = "Session expired. Please log out and log back in."
                case .timeout:
                    settingsViewModel.error = "Request timed out. Please check your internet connection."
                case .serverError(let code, let message):
                    if code == 400 {
                        settingsViewModel.error = message ?? "Invalid URL format. Please check your calendar link."
                    } else {
                        settingsViewModel.error = "Server error (\(code)). Please try again."
                    }
                case .networkError:
                    settingsViewModel.error = "Network error. Please check your internet connection."
                default:
                    settingsViewModel.error = "Failed to save calendar URL. Please try again. (Attempt \(calendarSaveAttempts))"
                }
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            
        } catch {
            print("❌ Unexpected error saving calendar URL:", error)
            print("   Error type:", String(describing: type(of: error)))
            
            await MainActor.run {
                // More helpful error messages based on attempt count
                if calendarSaveAttempts >= 3 {
                    settingsViewModel.error = "Unable to save after \(calendarSaveAttempts) attempts. Please contact support@trusenda.com"
                } else {
                    settingsViewModel.error = "Failed to save calendar URL. Please try again. (Attempt \(calendarSaveAttempts))"
                }
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
        
        await MainActor.run {
            isSavingCalendarURL = false
        }
    }
    
    // MARK: - Link Sharing Helpers
    
    /// Copy form link to clipboard - bypasses URL auto-detection
    private func copyFormLinkToClipboard(_ urlString: String) {
        // REALITY CHECK: iOS ALWAYS auto-detects URLs and adds "public.url" type
        // This causes bplist encoding in Mac Messages via Universal Clipboard
        // 
        // SOLUTION: Copy URL with surrounding text so it's NOT pure URL
        // Messages will then use the plain text representation (which includes the URL)
        
        // Create message with URL embedded (prevents it being detected as pure URL)
        let copyText = "\(urlString)"  // Just the URL for clean copy
        
        // Clear pasteboard
        UIPasteboard.general.items = []
        
        // Method 1: Try setting as pure text via items (prevents URL detection)
        UIPasteboard.general.items = [[
            UTType.plainText.identifier: copyText
        ]]
        
        // Check if iOS still added URL type
        let hasURLType = UIPasteboard.general.hasURLs
        
        // If iOS auto-added URL type, add a zero-width space to break URL detection
        if hasURLType {
            // Add invisible character to prevent URL detection while keeping URL functional
            let textWithBreaker = "\(urlString)\u{200B}"  // Zero-width space at end
            
            UIPasteboard.general.items = []
            
            // Set with zero-width space to prevent URL auto-detection
            if let data = textWithBreaker.data(using: .utf8) {
                UIPasteboard.general.items = [[
                    UTType.utf8PlainText.identifier: data
                ]]
            }
        }
        
        // Final verification
        let verifyString = UIPasteboard.general.string
        let finalTypes = UIPasteboard.general.types
        let finalHasURL = UIPasteboard.general.hasURLs
        
        // Success feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        settingsViewModel.successMessage = "✅ Link copied to clipboard!"
        settingsViewModel.clearMessageAfterDelay()
        
        // Comprehensive logging
        print("📋 ═══════════════════════════════════════")
        print("📋 COPY LINK - ANTI-BPLIST METHOD")
        print("📋 ═══════════════════════════════════════")
        print("📋 Original URL: \(urlString)")
        print("📋 Auto-detection prevented: \(hasURLType ? "Used zero-width space" : "Pure text worked")")
        print("📋 ───────────────────────────────────────")
        print("📋 FINAL VERIFICATION:")
        print("📋 Pasteboard string: \(verifyString ?? "nil")")
        print("📋 Pasteboard types: \(finalTypes)")
        print("📋 Contains URL type: \(finalHasURL ? "❌ YES (iOS still detected)" : "✅ NO (VICTORY!)")")
        print("📋 ═══════════════════════════════════════")
        
        if !finalHasURL {
            print("📋 ✅ SUCCESS! Messages will NOT use URL type!")
            print("📋 ✅ Should paste as plain text in all apps!")
        } else {
            print("📋 ⚠️ iOS still auto-detected URL")
            print("📋 ⚠️ May still show bplist in Mac Messages (Universal Clipboard)")
            print("📋 ✅ BUT: Works perfectly on same device (iPhone → iPhone Messages)")
        }
        print("📋 ═══════════════════════════════════════")
    }
    
    /// Share the public form link using native iOS share sheet
    private func shareFormLink(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL format: \(urlString)")
            settingsViewModel.error = "Invalid form URL"
            return
        }
        
        // Validate URL is properly formatted
        guard url.scheme == "https" || url.scheme == "http",
              url.host != nil else {
            print("❌ URL missing valid scheme or host: \(urlString)")
            settingsViewModel.error = "Invalid URL scheme"
            return
        }
        
        print("🔗 Preparing to share form link: \(urlString)")
        print("🔗 URL components - Scheme: \(url.scheme ?? "none"), Host: \(url.host ?? "none"), Path: \(url.path)")
        
        // Share as plain text only to avoid binary plist encoding issues
        // This ensures the URL is always copied/shared as readable text
        let shareText = "Fill out my commercial real estate lead form:\n\(urlString)"
        
        // CRITICAL: Only share the string, NOT the URL object
        // URL objects get serialized as bplist00 binary data in some apps
        let activityItems: [Any] = [shareText]
        
        // Present native share sheet
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Could not find root view controller")
            settingsViewModel.error = "Unable to open share sheet"
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Exclude some activity types that might not work well with URLs
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo
        ]
        
        // Configure for iPad (popover presentation)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = rootViewController.view
            popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                   y: rootViewController.view.bounds.midY,
                                                   width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // Add completion handler to show success/error
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            Task { @MainActor in
                if let error = error {
                    print("❌ Share failed with error: \(error.localizedDescription)")
                    self.settingsViewModel.error = "Failed to share link"
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                } else if completed {
                    print("✅ Link shared successfully via \(activityType?.rawValue ?? "unknown")")
                    self.settingsViewModel.successMessage = "✅ Link shared successfully!"
                    self.settingsViewModel.clearMessageAfterDelay()
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } else {
                    print("ℹ️ Share cancelled by user")
                }
            }
        }
        
        // Success feedback for opening sheet
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Present share sheet
        rootViewController.present(activityViewController, animated: true) {
            print("✅ Share sheet presented successfully")
            print("📋 Recipients will receive plain text: \(shareText)")
        }
    }
    
    /// Open the form link in Safari for testing
    private func openFormLink(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL format: \(urlString)")
            settingsViewModel.error = "Invalid form URL"
            return
        }
        
        // Validate URL components
        guard url.scheme == "https" || url.scheme == "http",
              url.host != nil else {
            print("❌ URL missing valid scheme or host: \(urlString)")
            settingsViewModel.error = "Malformed URL"
            return
        }
        
        print("🧪 Testing public form link: \(urlString)")
        
        // Open in Safari with completion handler
        UIApplication.shared.open(url, options: [:]) { success in
                if success {
                print("✅ Successfully opened form in Safari")
                Task { @MainActor in
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    settingsViewModel.successMessage = "✅ Link opened in Safari"
                    settingsViewModel.clearMessageAfterDelay()
                }
            } else {
                print("❌ Failed to open form in Safari")
                Task { @MainActor in
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    settingsViewModel.error = "Unable to open link. Please check your internet connection."
                }
            }
        }
    }
}

// MARK: - In-App Legal Document Viewer
struct InAppLegalDocView: View {
    let title: String
    let content: String
    let icon: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Premium header
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 32))
                            .foregroundColor(.primaryBlue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Text("Version 1.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text("Oct 16, 2025")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Full legal text
                    Text(content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Contact section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUESTIONS OR CONCERNS?")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(0.8)
                        
                        VStack(spacing: 8) {
                            ContactEmailLink(title: "Support", email: "support@trusenda.com")
                            ContactEmailLink(title: "Privacy", email: "privacy@trusenda.com")
                            ContactEmailLink(title: "Legal", email: "legal@trusenda.com")
                            ContactEmailLink(title: "Data Protection Officer", email: "dpo@trusenda.com")
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryBlue.opacity(0.05))
                    )
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Contact Email Link
struct ContactEmailLink: View {
    let title: String
    let email: String
    
    var body: some View {
        Link(destination: URL(string: "mailto:\(email)")!) {
            HStack {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.primaryBlue)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(email)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Calendar Booking Guide
struct CalendarGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 40))
                                .foregroundColor(.primaryBlue)
                            Spacer()
                        }
                        
                        Text("Instant Tour Booking")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Let leads book tours directly from property pages")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How It Works")
                            .font(.title3.bold())
                        
                        FeatureRow(
                            icon: "1.circle.fill",
                            title: "Set up your calendar",
                            description: "Create a free scheduling link using Calendly, Google Calendar, or Cal.com"
                        )
                        
                        FeatureRow(
                            icon: "2.circle.fill",
                            title: "Paste your link here",
                            description: "Copy your scheduling URL and save it in Settings"
                        )
                        
                        FeatureRow(
                            icon: "3.circle.fill",
                            title: "Leads book instantly",
                            description: "When you share a property, interested leads can book a tour immediately"
                        )
                    }
                    
                    Divider()
                    
                    // Supported platforms
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Supported Platforms (Free)")
                            .font(.title3.bold())
                        
                        PlatformCard(
                            name: "Calendly",
                            icon: "calendar.badge.plus",
                            url: "calendly.com",
                            exampleURL: "https://calendly.com/your-name/property-tour"
                        )
                        
                        PlatformCard(
                            name: "Google Calendar",
                            icon: "calendar",
                            url: "calendar.google.com",
                            exampleURL: "https://calendar.google.com/calendar/appointments/..."
                        )
                        
                        PlatformCard(
                            name: "Cal.com",
                            icon: "calendar.badge.clock",
                            url: "cal.com",
                            exampleURL: "https://cal.com/your-name/tour"
                        )
                    }
                    
                    Divider()
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pro Tips")
                            .font(.title3.bold())
                        
                        TipRow(icon: "checkmark.circle.fill", text: "Keep your calendar synced to avoid double-bookings")
                        TipRow(icon: "checkmark.circle.fill", text: "Set buffer times between appointments")
                        TipRow(icon: "checkmark.circle.fill", text: "Include property address in booking confirmations")
                        TipRow(icon: "checkmark.circle.fill", text: "Set reminder emails for both you and the lead")
                    }
                    
                    // Support
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Need Help?")
                            .font(.headline)
                        
                        Link(destination: URL(string: "mailto:support@trusenda.com?subject=Calendar%20Booking%20Setup")!) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Contact support@trusenda.com")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .font(.caption)
                            }
                            .foregroundColor(.primaryBlue)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primaryBlue.opacity(0.1))
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Setup Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Calendar Guide Helper Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.primaryBlue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PlatformCard: View {
    let name: String
    let icon: String
    let url: String
    let exampleURL: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primaryBlue)
                Text(name)
                    .font(.headline)
                Spacer()
                Link(destination: URL(string: "https://\(url)")!) {
                    Text("Visit →")
                        .font(.caption)
                        .foregroundColor(.primaryBlue)
                }
            }
            
            Text(exampleURL)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primaryBlue.opacity(0.05))
        )
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.green)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

