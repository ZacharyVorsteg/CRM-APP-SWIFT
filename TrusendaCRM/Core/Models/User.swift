import Foundation

/// User model matching /me endpoint response
struct User: Codable {
    let email: String
    let sub: String? // Netlify user ID
    let databaseExists: Bool
    let plan: String // "free" or "pro"
    let maxLeads: Int
    let gracePeriodDaysRemaining: Int?
    let isInGracePeriod: Bool
    let isBlocked: Bool
    let degradedMode: Bool? // True if backend unavailable
    let message: String? // Error message in degraded mode
    
    var isPro: Bool {
        return plan == "pro" || plan == "enterprise"
    }
    
    var isOverLimit: Bool {
        return isInGracePeriod || isBlocked
    }
}

/// Auth token response from Netlify Identity
struct AuthToken: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

/// Login request payload
struct LoginRequest: Codable {
    let grantType: String = "password"
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case username
        case password
    }
}

/// Signup request payload
struct SignupRequest: Codable {
    let email: String
    let password: String
}

