//
//  Auth0Config.swift
//  TrusendaCRM
//
//  Created by AI Agent on 2025-10-23
//  Auth0 configuration for social login (Google & Apple)
//

import Foundation

/// Auth0 Configuration
/// IMPORTANT: Update these values with your Auth0 application credentials
/// These MUST match the cloud app's Auth0 configuration
struct Auth0Config {
    // MARK: - Configuration
    
    /// Auth0 Domain
    /// Reads from Secrets.plist or falls back to hardcoded value
    static var domain: String {
        if let secretsDomain = loadFromSecrets(key: "AUTH0_DOMAIN") {
            return secretsDomain
        }
        return "dev-8shke7zmn4ginkyi.us.auth0.com"
    }
    
    /// Auth0 Client ID for iOS
    /// Reads from Secrets.plist or falls back to hardcoded value
    static var clientId: String {
        if let secretsClientId = loadFromSecrets(key: "AUTH0_CLIENT_ID") {
            return secretsClientId
        }
        return "ZJMn8FKYvWk7vof5Ry6pc0l0MaHhp8a7"
    }
    
    /// Auth0 Audience (API Identifier)
    /// This should match your Auth0 API identifier
    /// Optional: If not using a custom API, set to nil
    static let audience: String? = nil  // Leave nil if not using custom API
    
    /// iOS Callback URL
    /// This must be registered in Auth0 Dashboard → Applications → Allowed Callback URLs
    /// Format: com.trusenda.crm://YOUR_DOMAIN/ios/com.trusenda.TrusendaCRM/callback
    static var callbackURL: String {
        return "com.trusenda.crm://\(domain)/ios/com.trusenda.TrusendaCRM/callback"
    }
    
    /// iOS Logout URL
    /// This must be registered in Auth0 Dashboard → Applications → Allowed Logout URLs
    static var logoutURL: String {
        return "com.trusenda.crm://\(domain)/ios/com.trusenda.TrusendaCRM/logout"
    }
    
    // MARK: - Apple Sign-In Configuration
    
    /// Apple Team ID
    static var appleTeamId: String {
        if let secretsTeamId = loadFromSecrets(key: "APPLE_TEAM_ID") {
            return secretsTeamId
        }
        return "8746VPZ8R9"
    }
    
    /// Apple Key ID
    static var appleKeyId: String {
        if let secretsKeyId = loadFromSecrets(key: "APPLE_KEY_ID") {
            return secretsKeyId
        }
        return "4H3SA37DS2"
    }
    
    /// Apple Service ID (Client ID)
    static var appleClientId: String {
        if let secretsClientId = loadFromSecrets(key: "APPLE_CLIENT_ID") {
            return secretsClientId
        }
        return "com.trusenda"
    }
    
    /// Apple Signing Key (from .p8 file)
    /// ⚠️ NEVER hardcode this - always load from Secrets.plist or keychain
    static var appleSigningKey: String? {
        return loadFromSecrets(key: "APPLE_SIGNING_KEY")
    }
    
    // MARK: - Secrets Loading
    
    /// Load value from Secrets.plist
    private static func loadFromSecrets(key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let secrets = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = secrets[key] as? String,
              !value.isEmpty else {
            return nil
        }
        return value
    }
    
    // MARK: - Validation
    
    /// Check if Auth0 is properly configured
    static var isConfigured: Bool {
        let isValid = !domain.isEmpty && !clientId.isEmpty
        
        if !isValid {
            print("⚠️ ========================================")
            print("⚠️ AUTH0 NOT CONFIGURED")
            print("⚠️ Update Auth0Config.swift or Secrets.plist")
            print("⚠️ Domain:", domain.isEmpty ? "NOT SET" : domain)
            print("⚠️ Client ID:", clientId.isEmpty ? "NOT SET" : "SET")
            print("⚠️ ========================================")
        }
        
        return isValid
    }
    
    // MARK: - Social Connection IDs
    
    /// Google OAuth2 connection name in Auth0
    static let googleConnection = "google-oauth2"
    
    /// Apple connection name in Auth0
    static let appleConnection = "apple"
    
    // MARK: - OAuth Scopes
    
    /// OAuth scopes to request
    static let scopes = "openid profile email"
    
    // MARK: - Debug Logging
    
    /// Print Auth0 configuration (for debugging)
    static func printConfiguration() {
        print("🔐 ============ AUTH0 CONFIGURATION ============")
        print("🔐 Domain:", domain)
        print("🔐 Client ID:", String(clientId.prefix(10)) + "...")
        print("🔐 Audience:", audience ?? "None (not using custom API)")
        print("🔐 Callback URL:", callbackURL)
        print("🔐 Logout URL:", logoutURL)
        print("🔐 Google Connection:", googleConnection)
        print("🔐 Apple Connection:", appleConnection)
        print("🔐 Apple Team ID:", appleTeamId)
        print("🔐 Apple Key ID:", appleKeyId)
        print("🔐 Apple Client ID:", appleClientId)
        print("🔐 Apple Signing Key:", appleSigningKey != nil ? "✅ SET" : "❌ NOT SET")
        print("🔐 Scopes:", scopes)
        print("🔐 Is Configured:", isConfigured ? "✅ YES" : "❌ NO")
        print("🔐 ==============================================")
    }
}

// MARK: - Setup Instructions
/*
 
 # Auth0 Setup Instructions for iOS
 
 ## 1. Update Configuration
 
 Replace the placeholder values above with your Auth0 credentials:
 - `domain`: Your Auth0 domain from the Auth0 Dashboard
 - `clientId`: Your Auth0 Client ID (create a separate "Native" application for iOS)
 - `audience`: Your API identifier (if using a custom API)
 
 ## 2. Update Info.plist
 
 Add the following to your Info.plist:
 
 ```xml
 <key>CFBundleURLTypes</key>
 <array>
     <dict>
         <key>CFBundleTypeRole</key>
         <string>None</string>
         <key>CFBundleURLName</key>
         <string>auth0</string>
         <key>CFBundleURLSchemes</key>
         <array>
             <string>com.trusenda.crm</string>
         </array>
     </dict>
 </array>
 ```
 
 ## 3. Configure Auth0 Dashboard
 
 In your Auth0 Dashboard → Applications → Your iOS App:
 
 **Allowed Callback URLs:**
 ```
 com.trusenda.crm://YOUR_DOMAIN/ios/com.trusenda.TrusendaCRM/callback
 ```
 
 **Allowed Logout URLs:**
 ```
 com.trusenda.crm://YOUR_DOMAIN/ios/com.trusenda.TrusendaCRM/logout
 ```
 
 **Allowed Web Origins:**
 ```
 file://
 ```
 
 ## 4. Enable Social Connections
 
 In Auth0 Dashboard → Authentication → Social:
 - Enable Google (provide Client ID and Secret)
 - Enable Apple (configure Sign in with Apple)
 
 ## 5. Install Auth0.swift Package
 
 In Xcode:
 1. File → Add Package Dependencies
 2. Enter: `https://github.com/auth0/Auth0.swift`
 3. Select version: Latest (3.x)
 4. Add to target: TrusendaCRM
 
 ## 6. Test Configuration
 
 Run this in your app to verify:
 ```swift
 Auth0Config.printConfiguration()
 ```
 
 ## 7. Cloud Parity
 
 Make sure the iOS Auth0 configuration matches your cloud app:
 - Same Auth0 tenant
 - Same API audience (if used)
 - Same social connections enabled
 
 */

