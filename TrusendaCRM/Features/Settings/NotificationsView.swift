import SwiftUI
import UserNotifications

/// Dedicated Notifications settings view matching iOS design patterns
struct NotificationsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var emailNotificationsEnabled = true
    @State private var pushNotificationsEnabled = false
    @State private var pushNotificationsAuthorized = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        List {
            // Push Notifications Section
            Section {
                Toggle(isOn: Binding(
                    get: { pushNotificationsEnabled && pushNotificationsAuthorized },
                    set: { newValue in
                        if newValue {
                            requestPushNotificationPermission()
                        } else {
                            pushNotificationsEnabled = false
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iOS Push Notifications")
                            .font(.body)
                        Text("Instant alerts on your device")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tint(.primaryBlue)
                
                if !pushNotificationsAuthorized && pushNotificationsEnabled {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.warningOrange)
                        Text("Enable in iOS Settings → Trusenda → Notifications")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("MOBILE ALERTS")
            } footer: {
                Text("Receive follow-up reminders and new lead alerts directly on your iPhone")
            }
            
            // Email Notifications Section
            Section {
                Toggle(isOn: $emailNotificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email Notifications")
                            .font(.body)
                        Text("Traditional email alerts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tint(.primaryBlue)
                .onChange(of: emailNotificationsEnabled) { newValue in
                    Task {
                        await updateEmailPreference(newValue)
                    }
                }
                
                if emailNotificationsEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope.badge.fill")
                                .foregroundColor(.primaryBlue)
                                .font(.subheadline)
                            Text("Sent to: \(authManager.currentUser?.email ?? "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("EMAIL ALERTS")
            } footer: {
                Text("New lead captures and daily follow-up reminders via Resend")
            }
            
            // Timezone Section
            Section {
                NavigationLink {
                    TimezonePickerView(
                        selectedTimezone: Binding(
                            get: { settingsViewModel.tenantInfo?.timezone ?? "America/New_York" },
                            set: { newTimezone in
                                Task {
                                    await settingsViewModel.updateTimezone(newTimezone)
                                }
                            }
                        )
                    )
                } label: {
                    HStack {
                        Label("Timezone", systemImage: "clock")
                        Spacer()
                        Text(formatTimezone(settingsViewModel.tenantInfo?.timezone ?? "America/New_York"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("SCHEDULE")
            } footer: {
                Text("Daily follow-up emails sent at 7:00 AM in your timezone")
            }
            
            // Notification Types Info
            Section("WHAT YOU'LL RECEIVE") {
                NotificationTypeRow(
                    icon: "bell.badge.fill",
                    title: "New Lead Alerts",
                    description: "When leads are captured via webhooks or public forms",
                    color: .primaryBlue
                )
                
                NotificationTypeRow(
                    icon: "calendar.badge.clock",
                    title: "Daily Follow-Up Digest",
                    description: "7:00 AM reminder when follow-ups are due",
                    color: .primaryBlue
                )
                
                NotificationTypeRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Account Alerts",
                    description: "Plan limits, grace period, and billing updates",
                    color: .warningOrange
                )
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await checkPushNotificationStatus()
        }
        .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in iOS Settings to receive push alerts")
        }
    }
    
    private func formatTimezone(_ tz: String) -> String {
        // Extract just the city name for cleaner display
        if let city = tz.split(separator: "/").last {
            return String(city).replacingOccurrences(of: "_", with: " ")
        }
        return tz
    }
    
    private func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                pushNotificationsAuthorized = granted
                pushNotificationsEnabled = granted
                
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    print("✅ Push notifications authorized")
                } else {
                    showingPermissionAlert = true
                    print("❌ Push notifications denied")
                }
            }
        }
    }
    
    private func checkPushNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        DispatchQueue.main.async {
            pushNotificationsAuthorized = settings.authorizationStatus == .authorized
            pushNotificationsEnabled = settings.authorizationStatus == .authorized
        }
    }
    
    private func updateEmailPreference(_ enabled: Bool) async {
        // This would call an API endpoint to update email preferences
        // For now, just store locally
        UserDefaults.standard.set(enabled, forKey: "email_notifications_enabled")
        print("📧 Email notifications: \(enabled ? "enabled" : "disabled")")
    }
}

struct NotificationTypeRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

