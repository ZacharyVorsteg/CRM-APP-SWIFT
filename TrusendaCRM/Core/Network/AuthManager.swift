import Foundation
import Combine

/// Manages authentication state and JWT token lifecycle
/// Supports both Auth0 (social login) and Netlify Identity (email/password)
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let keychain = KeychainManager.shared
    private let client = APIClient.shared
    
    // MARK: - Authentication System Detection
    
    /// Check if using Auth0 for authentication
    var isUsingAuth0: Bool {
        #if canImport(Auth0)
        return Auth0Config.isConfigured && Auth0Manager.shared.isAuthenticated
        #else
        return false
        #endif
    }
    
    /// Get current authentication provider name
    var authProvider: String {
        #if canImport(Auth0)
        if Auth0Config.isConfigured {
            return Auth0Manager.shared.user?.providerName ?? "Auth0"
        }
        #endif
        return "Netlify Identity"
    }
    
    private init() {
        // Check if we have stored tokens - if so, optimistically show authenticated state
        // This prevents flickering to login screen when user has valid session
        
        // Check Auth0 first (if configured)
        #if canImport(Auth0)
        if Auth0Config.isConfigured && Auth0Manager.shared.isAuthenticated {
            isAuthenticated = true
            #if DEBUG
            print("🔐 Found Auth0 session - initializing as authenticated")
            #endif
            return
        }
        #endif
        
        // Fall back to Netlify Identity
        let hasTokens = keychain.get(.accessToken) != nil || keychain.get(.refreshToken) != nil
        isAuthenticated = hasTokens
        
        #if DEBUG
        if hasTokens {
            print("🔐 Found stored Netlify Identity tokens - initializing as authenticated")
        }
        #endif
    }
    
    // MARK: - Biometric Login
    func loginWithBiometrics() async throws {
        // Get stored credentials
        guard let credentials = keychain.getBiometricCredentials() else {
            throw NetworkError.serverError(400, "No saved credentials for Face ID")
        }
        
        // Use stored credentials to login
        try await login(email: credentials.email, password: credentials.password, saveBiometric: false)
    }
    
    // MARK: - Login
    func login(email: String, password: String, saveBiometric: Bool = false) async throws {
        // Use Netlify Identity token endpoint (GoTrue API)
        // This matches what netlify-identity-widget uses in the web app
        guard let url = URL(string: "https://trusenda.com/.netlify/identity/token") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30 // 30 second timeout
        // IMPORTANT: Netlify Identity requires form-encoded, not JSON
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // URL-encode the body (form format)
        let bodyString = "grant_type=password&username=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = bodyString.data(using: .utf8)
        
        print("🌐 Attempting login to: \(url.absoluteString)")
        print("📧 Email: \(email)")
        print("📱 Network request details:")
        print("   - Method: POST")
        print("   - Content-Type: application/x-www-form-urlencoded")
        print("   - Timeout: 30s")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("✅ Network response received")
        print("📥 Response size: \(data.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NetworkError.unknown
        }
        
        print("📊 HTTP Status: \(httpResponse.statusCode)")
        
        // Check for errors
        if httpResponse.statusCode != 200 {
            let errorText = String(data: data, encoding: .utf8) ?? "Login failed"
            print("❌ Login error (\(httpResponse.statusCode)):", errorText)
            
            // Better error messages
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                throw NetworkError.serverError(httpResponse.statusCode, "Invalid email or password")
            } else if httpResponse.statusCode >= 500 {
                throw NetworkError.serverError(httpResponse.statusCode, "Server error. Please try again.")
            } else {
                throw NetworkError.serverError(httpResponse.statusCode, errorText)
            }
        }
        
        // Parse token response (matches AuthToken model)
        let tokenResponse = try JSONDecoder().decode(AuthToken.self, from: data)
        
        print("✅ Login successful! Token expires in \(tokenResponse.expiresIn) seconds")
        
        // Save tokens to keychain (same as web app stores in localStorage)
        keychain.saveTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            expiresIn: tokenResponse.expiresIn
        )
        
        // Fetch user info from backend (same as web app's API.me())
        try await fetchMe()
        
        // Save credentials for biometric login if requested
        if saveBiometric {
            keychain.saveBiometricCredentials(email: email, password: password)
        }
        
        isAuthenticated = true
    }
    
    // MARK: - Signup
    func signup(email: String, password: String) async throws {
        guard let url = URL(string: "https://trusenda.com/.netlify/identity/signup") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        if httpResponse.statusCode != 200 {
            let errorText = String(data: data, encoding: .utf8) ?? "Signup failed"
            throw NetworkError.serverError(httpResponse.statusCode, errorText)
        }
        
        print("✅ Signup successful! Account created.")
        
        // Auto-login after successful signup (premium UX)
        try await login(email: email, password: password)
        
        // Mark as new user to show welcome tour
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
    
    // MARK: - Logout
    func logout() {
        // Logout from Auth0 if using it
        #if canImport(Auth0)
        if Auth0Config.isConfigured && Auth0Manager.shared.isAuthenticated {
            Task { @MainActor in
                Auth0Manager.shared.logout()
            }
        }
        #endif
        
        // Clear Netlify Identity tokens
        keychain.clearAll()
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Fetch Current User
    func fetchMe() async throws {
        let user: User = try await client.get(endpoint: .me, requiresAuth: true)
        
        // Check if account was deleted
        if !user.databaseExists && user.degradedMode != true {
            throw NetworkError.unauthorized
        }
        
        currentUser = user
    }
    
    // MARK: - Get Valid Token
    func getValidToken() async throws -> String {
        // IMPROVED: Auto-refresh tokens to keep users logged in
        // Matches cloud app behavior - seamless experience
        // Users stay logged in indefinitely until they explicitly log out
        
        // Check if we have a valid token
        guard let token = keychain.get(.accessToken) else {
            throw NetworkError.unauthorized
        }
        
        // Check if token is expired (with 5-minute buffer)
        if keychain.isTokenExpired() {
            // Token expired - try to refresh automatically
            #if DEBUG
            print("🔄 Token expired, attempting auto-refresh...")
            #endif
            
            do {
                try await refreshToken()
                // Refresh successful - get new token
                guard let newToken = keychain.get(.accessToken) else {
                    throw NetworkError.unauthorized
                }
                #if DEBUG
                print("✅ Token refreshed successfully")
                #endif
                return newToken
            } catch {
                // Refresh failed - logout and require login
                #if DEBUG
                print("❌ Token refresh failed - requiring login")
                #endif
                logout()
                throw NetworkError.unauthorized
            }
        }
        
        return token
    }
    
    // MARK: - Refresh Token
    private func refreshToken() async throws {
        guard let refreshToken = keychain.get(.refreshToken) else {
            throw NetworkError.unauthorized
        }
        
        // Use Netlify Identity token endpoint (same as login)
        guard let url = URL(string: "https://trusenda.com/.netlify/identity/token") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // URL-encode the refresh token request
        let bodyString = "grant_type=refresh_token&refresh_token=\(refreshToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        if httpResponse.statusCode != 200 {
            // Refresh failed - token is invalid
            throw NetworkError.unauthorized
        }
        
        // Parse new token
        let tokenResponse = try JSONDecoder().decode(AuthToken.self, from: data)
        
        // Save new tokens
        keychain.saveTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken ?? refreshToken,
            expiresIn: tokenResponse.expiresIn
        )
        
        #if DEBUG
        print("✅ Token refreshed - new expiry in \(tokenResponse.expiresIn) seconds")
        #endif
    }
    
    // MARK: - Check Auth on App Launch
    func checkAuthStatus() async {
        // CRITICAL: Keep users logged in unless they explicitly log out
        // This matches cloud app behavior for seamless experience
        
        #if DEBUG
        print("🔍 Checking authentication status...")
        #endif
        
        // Check if we have any tokens at all
        guard keychain.get(.accessToken) != nil || keychain.get(.refreshToken) != nil else {
            // No tokens at all - user needs to log in
            #if DEBUG
            print("❌ No tokens found - requiring login")
            #endif
            isAuthenticated = false
            currentUser = nil
            return
        }
        
        // Check if access token is valid
        if let _ = keychain.get(.accessToken), !keychain.isTokenExpired() {
            // Access token is valid - restore session
            #if DEBUG
            print("✅ Valid access token found")
            #endif
            
            do {
                try await fetchMe()
                isAuthenticated = true
                #if DEBUG
                print("✅ Session restored successfully")
                #endif
                return
            } catch {
                // Failed to fetch user - token might be invalid
                #if DEBUG
                print("⚠️ Failed to fetch user with access token: \(error)")
                #endif
            }
        } else {
            #if DEBUG
            print("⚠️ Access token expired or invalid")
            #endif
        }
        
        // Access token expired or invalid - try to refresh automatically
        if keychain.get(.refreshToken) != nil {
            #if DEBUG
            print("🔄 Attempting automatic token refresh...")
            #endif
            
            do {
                try await refreshToken()
                // Refresh successful - fetch user info
                try await fetchMe()
                isAuthenticated = true
                #if DEBUG
                print("✅ Token refreshed and session restored")
                #endif
                return
            } catch {
                // Refresh failed - tokens are invalid
                #if DEBUG
                print("❌ Token refresh failed: \(error)")
                #endif
            }
        }
        
        // Both access and refresh tokens failed - require login
        #if DEBUG
        print("⚠️ All token restoration attempts failed - requiring login")
        #endif
        keychain.clearAll()
        isAuthenticated = false
        currentUser = nil
    }
}

