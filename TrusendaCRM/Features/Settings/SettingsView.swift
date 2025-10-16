import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showDeleteAccountConfirm = false
    @State private var confirmEmail = ""
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section("Account") {
                    if let user = authManager.currentUser {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.email)
                                .font(.headline)
                            Text("Plan: \(user.plan.capitalized)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Lead Limit")
                            Spacer()
                            Text("\(user.maxLeads)")
                                .foregroundColor(.secondary)
                        }
                        
                        if !user.isPro {
                            Button {
                                Task {
                                    await upgradeToPro()
                                }
                            } label: {
                                Label("Upgrade to Pro", systemImage: "star.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                // Tenant Info
                if let tenant = settingsViewModel.tenantInfo {
                    Section("Organization") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tenant.name)
                                .font(.headline)
                            Text("\(tenant.currentLeads) / \(tenant.maxLeads) leads")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let logoUrl = tenant.logoUrl, !logoUrl.isEmpty {
                            HStack {
                                Text("Logo")
                                Spacer()
                                Text("Configured")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                // Public Form
                if let form = settingsViewModel.publicForm {
                    Section("Public Form") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lead Submission Form")
                                .font(.headline)
                            Text(form.fullURL)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button {
                            UIPasteboard.general.string = form.fullURL
                        } label: {
                            Label("Copy Link", systemImage: "doc.on.doc")
                        }
                        
                        ShareLink(item: URL(string: form.fullURL)!) {
                            Label("Share Form", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                
                // Security
                Section("Security") {
                    Button(role: .destructive) {
                        showDeleteAccountConfirm = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                }
                
                // Sign Out
                Section {
                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                // App Info
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                await settingsViewModel.fetchTenantInfo()
                await settingsViewModel.fetchPublicForm()
            }
            .alert("Delete Account", isPresented: $showDeleteAccountConfirm) {
                TextField("Enter your email to confirm", text: $confirmEmail)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                Button("Cancel", role: .cancel) {
                    confirmEmail = ""
                }
                
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("This action cannot be undone. All your leads and data will be permanently deleted.")
            }
        }
    }
    
    private func upgradeToPro() async {
        do {
            let sessionId = try await settingsViewModel.createCheckoutSession()
            
            // Open Stripe checkout in Safari
            // In production, use SFSafariViewController or ASWebAuthenticationSession
            if let url = URL(string: "https://checkout.stripe.com/c/pay/\(sessionId)") {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        } catch {
            print("Failed to create checkout session:", error)
        }
    }
    
    private func deleteAccount() async {
        guard confirmEmail == authManager.currentUser?.email else {
            print("Email confirmation doesn't match")
            return
        }
        
        do {
            try await settingsViewModel.deleteAccount(confirmEmail: confirmEmail)
        } catch {
            print("Failed to delete account:", error)
        }
    }
}

