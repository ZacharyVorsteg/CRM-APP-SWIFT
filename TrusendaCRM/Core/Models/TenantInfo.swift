import Foundation

/// Tenant info model matching /tenant-info endpoint
struct TenantInfo: Codable {
    let id: Int
    let name: String
    let plan: String
    let maxLeads: Int
    let currentLeads: Int
    let logoUrl: String?
    let autoTailor: Bool
    let headerTheme: String // "blue" or "dark"
    let timezone: String
    let gracePeriodDaysRemaining: Int?
    let isInGracePeriod: Bool
    let isBlocked: Bool
    let createdAt: String?
}

/// Branding update payload
struct BrandingUpdate: Codable {
    let logoUrl: String?
    let autoTailor: Bool
    let headerTheme: String
}

