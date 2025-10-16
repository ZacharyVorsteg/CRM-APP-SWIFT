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
        // Check if user has valid token on init
        if keychain.get(.accessToken) != nil && !keychain.isTokenExpired() {
            isAuthenticated = true
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        let request = LoginRequest(username: email, password: password)
        
        let response: AuthToken = try await client.post(
            endpoint: .login,
            body: request,
            requiresAuth: false
        )
        
        // Save tokens to keychain
        keychain.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn
        )
        
        // Fetch user info
        try await fetchMe()
        
        isAuthenticated = true
    }
    
    // MARK: - Signup
    func signup(email: String, password: String) async throws {
        let request = SignupRequest(email: email, password: password)
        
        // Netlify Identity signup endpoint
        // Note: In production, this requires email confirmation
        let _: SuccessResponse = try await client.post(
            endpoint: .signup,
            body: request,
            requiresAuth: false
        )
        
        // After signup, user needs to confirm email
        // For now, we'll require manual login after signup
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
        // Check if token is expired
        if keychain.isTokenExpired() {
            // Try to refresh
            try await refreshToken()
        }
        
        guard let token = keychain.get(.accessToken) else {
            throw NetworkError.unauthorized
        }
        
        return token
    }
    
    // MARK: - Refresh Token
    private func refreshToken() async throws {
        guard let refreshToken = keychain.get(.refreshToken) else {
            throw NetworkError.unauthorized
        }
        
        // Build refresh request
        struct RefreshRequest: Codable {
            let grantType = "refresh_token"
            let refreshToken: String
            
            enum CodingKeys: String, CodingKey {
                case grantType = "grant_type"
                case refreshToken = "refresh_token"
            }
        }
        
        let request = RefreshRequest(refreshToken: refreshToken)
        
        do {
            let response: AuthToken = try await client.post(
                endpoint: .login,
                body: request,
                requiresAuth: false
            )
            
            // Save new tokens
            keychain.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken ?? refreshToken,
                expiresIn: response.expiresIn
            )
        } catch {
            // If refresh fails, force logout
            logout()
            throw NetworkError.unauthorized
        }
    }
    
    // MARK: - Check Auth on App Launch
    func checkAuthStatus() async {
        guard keychain.get(.accessToken) != nil else {
            isAuthenticated = false
            return
        }
        
        do {
            try await fetchMe()
            isAuthenticated = true
        } catch {
            // Token invalid, logout
            logout()
        }
    }
}

