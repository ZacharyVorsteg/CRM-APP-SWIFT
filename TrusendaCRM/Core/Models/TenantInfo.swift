import Foundation

/// Tenant info model matching /tenant-info endpoint
struct TenantInfo: Codable {
    let id: Int
    let name: String
    let plan: String
    let maxLeads: Int
    let currentLeads: Int
    let logoUrl: String?
    let autoTailor: Bool? // Optional - may not be set in database
    let headerTheme: String? // Optional - may not be set in database
    var timezone: String // Mutable for timezone updates
    let gracePeriodDaysRemaining: Int?
    let isInGracePeriod: Bool
    let isBlocked: Bool
    let createdAt: String?
    
    // Computed properties with defaults
    var effectiveAutoTailor: Bool {
        return autoTailor ?? false
    }
    
    var effectiveHeaderTheme: String {
        return headerTheme ?? "blue"
    }
}

/// Branding update payload
struct BrandingUpdate: Codable {
    let logoUrl: String?
    let autoTailor: Bool
    let headerTheme: String
}

