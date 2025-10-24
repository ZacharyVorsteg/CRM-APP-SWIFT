//
//  Auth0Manager.swift
//  TrusendaCRM
//
//  Created by AI Agent on 2025-10-23
//  Auth0 authentication manager with Google & Apple Sign-In
//

import Foundation
import Auth0
import SwiftUI

/// Auth0 Authentication Manager
/// Handles social login (Google & Apple) and email/password authentication
class Auth0Manager: ObservableObject {
    static let shared = Auth0Manager()
    
    // MARK: - Published Properties
    
    @Published var isAuthenticated = false
    @Published var user: Auth0User?
    @Published var accessToken: String?
    @Published var error: String?
    
    // MARK: - Private Properties
    
    private var refreshToken: String?
    
    // MARK: - Initialization
    
    private init() {
        print("🔧 Auth0Manager initialized")
        
        // Print configuration on init
        Auth0Config.printConfiguration()
        
        // Try to restore session on init
        Task {
            await restoreSession()
        }
    }
    
    // MARK: - Session Restoration
    
    /// Restore session from keychain on app launch
    @MainActor
    func restoreSession() async {
        guard Auth0Config.isConfigured else {
            print("⚠️ Auth0 not configured - skipping session restore")
            return
        }
        
        print("🔄 ========== RESTORING AUTH0 SESSION ==========")
        
        // Check for stored tokens
        if let storedToken = KeychainManager.shared.get(.accessToken) {
            print("✅ Found stored access token")
            self.accessToken = storedToken
            
            // Try to get user info
            await fetchUserProfile()
            
            if self.user != nil {
                print("✅ Session restored successfully")
                self.isAuthenticated = true
            } else {
                print("⚠️ Could not fetch user profile - token may be expired")
                // Try to refresh
                await refreshTokenIfNeeded()
            }
        } else {
            print("ℹ️ No stored access token found")
        }
        
        print("🔄 ==============================================")
    }
    
    // MARK: - Google Login
    
    /// Login with Google
    @MainActor
    func loginWithGoogle() {
        guard Auth0Config.isConfigured else {
            self.error = "Auth0 not configured. Please update Auth0Config.swift"
            print("❌ Auth0 not configured")
            return
        }
        
        print("🔐 ========== GOOGLE LOGIN ==========")
        print("🔐 Connection:", Auth0Config.googleConnection)
        print("🔐 Domain:", Auth0Config.domain)
        print("🔐 Callback:", Auth0Config.callbackURL)
        print("🔐 ===================================")
        
        Auth0
            .webAuth(clientId: Auth0Config.clientId, domain: Auth0Config.domain)
            .connection(Auth0Config.googleConnection)
            .scope(Auth0Config.scopes)
            .audience(Auth0Config.audience ?? "")
            .start { result in
                Task { @MainActor in
                    switch result {
                    case .success(let credentials):
                        print("✅ ========== GOOGLE LOGIN SUCCESS ==========")
                        print("✅ Access Token received:", credentials.accessToken.prefix(20), "...")
                        print("✅ ID Token received:", credentials.idToken.prefix(20), "...")
                        print("✅ Has Refresh Token:", credentials.refreshToken != nil)
                        print("✅ ============================================")
                        
                        await self.handleSuccessfulLogin(credentials)
                        
                    case .failure(let error):
                        print("❌ ========== GOOGLE LOGIN FAILED ==========")
                        print("❌ Error:", error.localizedDescription)
                        print("❌ Error details:", error)
                        print("❌ ===========================================")
                        
                        self.error = "Google login failed: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    // MARK: - Apple Login
    
    /// Login with Apple
    @MainActor
    func loginWithApple() {
        guard Auth0Config.isConfigured else {
            self.error = "Auth0 not configured. Please update Auth0Config.swift"
            print("❌ Auth0 not configured")
            return
        }
        
        print("🔐 ========== APPLE LOGIN ==========")
        print("🔐 Connection:", Auth0Config.appleConnection)
        print("🔐 Domain:", Auth0Config.domain)
        print("🔐 Callback:", Auth0Config.callbackURL)
        print("🔐 ===================================")
        
        Auth0
            .webAuth(clientId: Auth0Config.clientId, domain: Auth0Config.domain)
            .connection(Auth0Config.appleConnection)
            .scope(Auth0Config.scopes)
            .audience(Auth0Config.audience ?? "")
            .start { result in
                Task { @MainActor in
                    switch result {
                    case .success(let credentials):
                        print("✅ ========== APPLE LOGIN SUCCESS ==========")
                        print("✅ Access Token received:", credentials.accessToken.prefix(20), "...")
                        print("✅ ID Token received:", credentials.idToken.prefix(20), "...")
                        print("✅ Has Refresh Token:", credentials.refreshToken != nil)
                        print("✅ ===========================================")
                        
                        await self.handleSuccessfulLogin(credentials)
                        
                    case .failure(let error):
                        print("❌ ========== APPLE LOGIN FAILED ==========")
                        print("❌ Error:", error.localizedDescription)
                        print("❌ Error details:", error)
                        print("❌ ==========================================")
                        
                        self.error = "Apple login failed: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    // MARK: - Email/Password Login
    
    /// Login with email and password
    func login(email: String, password: String) async {
        guard Auth0Config.isConfigured else {
            self.error = "Auth0 not configured. Please update Auth0Config.swift"
            print("❌ Auth0 not configured")
            return
        }
        
        print("🔐 ========== EMAIL LOGIN ==========")
        print("🔐 Email:", email)
        print("🔐 Domain:", Auth0Config.domain)
        print("🔐 ==================================")
        
        do {
            let credentials = try await Auth0
                .authentication(clientId: Auth0Config.clientId, domain: Auth0Config.domain)
                .login(
                    usernameOrEmail: email,
                    password: password,
                    realmOrConnection: "Username-Password-Authentication",
                    scope: Auth0Config.scopes
                )
                .start()
            
            print("✅ Email login successful")
            await handleSuccessfulLogin(credentials)
            
        } catch {
            print("❌ Email login failed:", error.localizedDescription)
            self.error = "Login failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Handle Successful Login
    
    /// Handle successful login from any method
    private func handleSuccessfulLogin(_ credentials: Credentials) async {
        print("✅ ========== PROCESSING LOGIN ==========")
        
        // Store tokens
        self.accessToken = credentials.accessToken
        self.refreshToken = credentials.refreshToken
        
        // Save to keychain
        KeychainManager.shared.save(credentials.accessToken, for: .accessToken)
        if let refreshToken = credentials.refreshToken {
            KeychainManager.shared.save(refreshToken, for: .refreshToken)
            print("✅ Refresh token saved to keychain")
        }
        
        print("✅ Access token saved to keychain")
        print("✅ Token length:", credentials.accessToken.count, "characters")
        
        // Fetch user profile
        await fetchUserProfile()
        
        // Mark as authenticated
        if self.user != nil {
            self.isAuthenticated = true
            print("✅ User authenticated successfully")
            print("✅ ========================================")
        } else {
            print("⚠️ Could not fetch user profile")
            print("⚠️ ========================================")
        }
    }
    
    // MARK: - Fetch User Profile
    
    /// Fetch user profile from Auth0
    private func fetchUserProfile() async {
        guard let accessToken = accessToken else {
            print("❌ No access token available to fetch profile")
            return
        }
        
        print("📡 Fetching Auth0 user profile...")
        
        do {
            let profile = try await Auth0
                .authentication(clientId: Auth0Config.clientId, domain: Auth0Config.domain)
                .userInfo(withAccessToken: accessToken)
                .start()
            
            print("✅ User profile fetched successfully")
            print("✅ Email:", profile.email ?? "N/A")
            print("✅ Name:", profile.name ?? "N/A")
            print("✅ Sub (ID):", profile.sub)
            print("✅ Email Verified:", profile.emailVerified ?? false)
            
            self.user = Auth0User(
                sub: profile.sub,
                email: profile.email,
                name: profile.name,
                picture: profile.picture?.absoluteString,
                emailVerified: profile.emailVerified ?? false
            )
            
        } catch {
            print("❌ Failed to fetch user profile:", error.localizedDescription)
            print("❌ Error:", error)
        }
    }
    
    // MARK: - Logout
    
    /// Logout and clear session
    @MainActor
    func logout() {
        guard Auth0Config.isConfigured else {
            print("⚠️ Auth0 not configured - clearing local session only")
            clearLocalSession()
            return
        }
        
        print("👋 ========== LOGGING OUT ==========")
        print("👋 Clearing tokens from keychain")
        print("👋 Logging out of Auth0")
        print("👋 ===================================")
        
        // Clear local session first
        clearLocalSession()
        
        // Logout from Auth0
        Auth0
            .webAuth(clientId: Auth0Config.clientId, domain: Auth0Config.domain)
            .clearSession { result in
                switch result {
                case .success:
                    print("✅ Logged out of Auth0 successfully")
                case .failure(let error):
                    print("❌ Auth0 logout error:", error.localizedDescription)
                }
            }
    }
    
    /// Clear local session data
    private func clearLocalSession() {
        self.accessToken = nil
        self.refreshToken = nil
        self.user = nil
        self.isAuthenticated = false
        self.error = nil
        
        // Clear from keychain
        KeychainManager.shared.delete(.accessToken)
        KeychainManager.shared.delete(.refreshToken)
        
        print("✅ Local session cleared")
    }
    
    // MARK: - Token Refresh
    
    /// Refresh access token if needed
    func refreshTokenIfNeeded() async {
        guard let refreshToken = KeychainManager.shared.get(.refreshToken) else {
            print("⚠️ No refresh token available")
            return
        }
        
        guard Auth0Config.isConfigured else {
            print("⚠️ Auth0 not configured - cannot refresh token")
            return
        }
        
        print("🔄 ========== REFRESHING TOKEN ==========")
        print("🔄 Using stored refresh token")
        
        do {
            let credentials = try await Auth0
                .authentication(clientId: Auth0Config.clientId, domain: Auth0Config.domain)
                .renew(withRefreshToken: refreshToken)
                .start()
            
            print("✅ Token refreshed successfully")
            print("✅ New token length:", credentials.accessToken.count, "characters")
            
            self.accessToken = credentials.accessToken
            KeychainManager.shared.save(credentials.accessToken, for: .accessToken)
            
            // Optionally update refresh token if provided
            if let newRefreshToken = credentials.refreshToken {
                self.refreshToken = newRefreshToken
                KeychainManager.shared.save(newRefreshToken, for: .refreshToken)
                print("✅ Refresh token updated")
            }
            
            // Fetch updated user profile
            await fetchUserProfile()
            
            if self.user != nil {
                self.isAuthenticated = true
            }
            
            print("🔄 ========================================")
            
        } catch {
            print("❌ Token refresh failed:", error.localizedDescription)
            print("❌ Clearing session - user needs to log in again")
            clearLocalSession()
        }
    }
}

// MARK: - Auth0User Model

/// Auth0 user model
struct Auth0User: Codable {
    let sub: String              // Auth0 user ID (e.g., "google-oauth2|123456")
    let email: String?
    let name: String?
    let picture: String?         // Profile picture URL
    let emailVerified: Bool
    
    /// Extract provider from sub (e.g., "google-oauth2", "apple", "auth0")
    var provider: String {
        sub.components(separatedBy: "|").first ?? "unknown"
    }
    
    /// User-friendly provider name
    var providerName: String {
        switch provider {
        case "google-oauth2":
            return "Google"
        case "apple":
            return "Apple"
        case "auth0":
            return "Email"
        default:
            return provider.capitalized
        }
    }
}

// MARK: - Usage Example
/*
 
 # Usage Example
 
 ## In LoginView:
 
 ```swift
 // Google Sign-In Button
 Button {
     Auth0Manager.shared.loginWithGoogle()
 } label: {
     HStack {
         Image(systemName: "g.circle.fill")
         Text("Continue with Google")
     }
 }
 
 // Apple Sign-In Button
 Button {
     Auth0Manager.shared.loginWithApple()
 } label: {
     HStack {
         Image(systemName: "apple.logo")
         Text("Continue with Apple")
     }
 }
 ```
 
 ## Check Authentication State:
 
 ```swift
 if Auth0Manager.shared.isAuthenticated {
     // User is logged in
     Text("Welcome, \(Auth0Manager.shared.user?.email ?? "")")
 }
 ```
 
 ## Logout:
 
 ```swift
 Button("Logout") {
     Auth0Manager.shared.logout()
 }
 ```
 
 ## Token for API Calls:
 
 ```swift
 if let token = Auth0Manager.shared.accessToken {
     // Use token in Authorization header
     request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
 }
 ```
 
 */

