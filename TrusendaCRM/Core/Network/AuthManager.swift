import Foundation
import Combine

/// Manages authentication state and JWT token lifecycle
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let keychain = KeychainManager.shared
    private let client = APIClient.shared
    
    private init() {
        // Don't auto-authenticate on init - let checkAuthStatus handle it
        // This prevents auto-login before user sees login screen
        isAuthenticated = false
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
        // Check if we have a valid token from previous session
        guard let _ = keychain.get(.accessToken),
              !keychain.isTokenExpired() else {
            // No valid token - user needs to log in
            isAuthenticated = false
            currentUser = nil
            return
        }
        
        // We have a valid token - restore session
        do {
            try await fetchMe()
            isAuthenticated = true
            print("✅ Session restored - user still logged in")
        } catch {
            // Token invalid or network error - force login
            print("⚠️ Session restore failed - requiring login")
            keychain.clearAll()
            isAuthenticated = false
            currentUser = nil
        }
    }
}

