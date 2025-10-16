import Foundation

/// Response from /customers endpoint
struct LeadsResponse: Codable {
    let customers: [Lead]
    let isOverLimit: Bool
    let currentCount: Int
    let maxLeads: Int
    let plan: String
    let gracePeriodDaysRemaining: Int?
    let isInGracePeriod: Bool
    let isBlocked: Bool
}

/// Response from creating/updating a lead
struct LeadActionResponse: Codable {
    let customer: Lead
}

/// Response from Stripe checkout session
struct StripeCheckoutResponse: Codable {
    let sessionId: String
}

/// Public form model
struct PublicForm: Codable {
    let id: String
    let slug: String
    let title: String
    let isActive: Bool
    
    var fullURL: String {
        return "https://trusenda.com/submit/\(slug)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, slug, title
        case isActive = "is_active"
    }
}

struct PublicFormResponse: Codable {
    let form: PublicForm
}

/// API key model
struct APIKey: Codable, Identifiable {
    let id: String
    let label: String
    let keyHash: String? // Only returned on creation
    let createdAt: String
    let lastUsedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, label
        case keyHash = "key_hash"
        case createdAt = "created_at"
        case lastUsedAt = "last_used_at"
    }
}

struct APIKeysResponse: Codable {
    let keys: [APIKey]
}

struct APIKeyCreateResponse: Codable {
    let apiKey: String
    let keyHash: String
}

/// Generic success response
struct SuccessResponse: Codable {
    let success: Bool
    let message: String?
}

/// Error response from API
struct ErrorResponse: Codable {
    let error: String
    let details: String?
}

