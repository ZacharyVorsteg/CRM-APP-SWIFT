import Foundation

/// Property listing model - matches Lead criteria for intelligent matching
struct Property: Codable, Identifiable, Equatable {
    let id: String
    var title: String
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    
    // Property Details (matches Lead fields for matching)
    var propertyType: String? // "Warehouse", "Office", "Industrial", etc.
    var transactionType: String? // "Lease", "Purchase", etc.
    var size: String? // Square footage (e.g., "5000")
    var sizeMin: String? // For ranges
    var sizeMax: String? // For ranges
    var price: String? // Monthly rent or purchase price
    var budget: String? // Budget range (e.g., "$5,000 - $10,000/mo")
    var leaseTerm: String? // "1 Year", "3 Years", etc.
    var industry: String? // Best suited for which industry
    var availableDate: String? // MM/YY format
    
    // Media
    var images: [String]? // Image URLs or base64 data
    var primaryImage: String? // Main listing photo
    
    // Description
    var description: String?
    var features: String? // Key features, amenities
    
    // Metadata
    var status: String // "Available", "Under Contract", "Leased", "Sold"
    var createdAt: String // ISO 8601
    var updatedAt: String // ISO 8601
    
    // Matching
    var matchedLeadIds: [String]? // IDs of leads this property matches
    var matchScore: Int? // Calculated match score (0-100)
    
    // Computed property for display date
    var createdDate: Date? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: createdAt) {
            return date
        }
        
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = customFormatter.date(from: createdAt) {
            return date
        }
        
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return customFormatter.date(from: createdAt)
    }
    
    // CodingKeys to match API snake_case
    enum CodingKeys: String, CodingKey {
        case id, title, address, city, state, zipCode, description, features, status
        case propertyType, transactionType, size, sizeMin, sizeMax, price, budget
        case leaseTerm, industry, availableDate, images, primaryImage
        case matchedLeadIds, matchScore
        case createdAt, updatedAt
    }
}

// MARK: - Property Creation Payload
struct PropertyCreatePayload: Codable {
    let title: String
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let propertyType: String?
    let transactionType: String?
    let size: String?
    let sizeMin: String?
    let sizeMax: String?
    let price: String?
    let budget: String?
    let leaseTerm: String?
    let industry: String?
    let availableDate: String?
    let images: [String]?
    let primaryImage: String?
    let description: String?
    let features: String?
    let status: String
}

// MARK: - Property Update Payload
struct PropertyUpdatePayload: Codable {
    var title: String?
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var propertyType: String?
    var transactionType: String?
    var size: String?
    var sizeMin: String?
    var sizeMax: String?
    var price: String?
    var budget: String?
    var leaseTerm: String?
    var industry: String?
    var availableDate: String?
    var images: [String]?
    var primaryImage: String?
    var description: String?
    var features: String?
    var status: String?
    
    // Custom encoder that only includes non-nil values
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(zipCode, forKey: .zipCode)
        try container.encodeIfPresent(propertyType, forKey: .propertyType)
        try container.encodeIfPresent(transactionType, forKey: .transactionType)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(sizeMin, forKey: .sizeMin)
        try container.encodeIfPresent(sizeMax, forKey: .sizeMax)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(budget, forKey: .budget)
        try container.encodeIfPresent(leaseTerm, forKey: .leaseTerm)
        try container.encodeIfPresent(industry, forKey: .industry)
        try container.encodeIfPresent(availableDate, forKey: .availableDate)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(primaryImage, forKey: .primaryImage)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(features, forKey: .features)
        try container.encodeIfPresent(status, forKey: .status)
    }
}

// MARK: - Lead-Property Match
struct LeadPropertyMatch: Identifiable {
    let id: String
    let property: Property
    let lead: Lead
    let matchScore: Int // 0-100
    let matchReasons: [String] // ["Size matches", "Budget aligned", "Property type matches"]
    
    var matchPercentage: String {
        "\(matchScore)%"
    }
    
    var matchQuality: MatchQuality {
        switch matchScore {
        case 90...100: return .excellent
        case 75..<90: return .good
        case 60..<75: return .fair
        default: return .poor
        }
    }
    
    enum MatchQuality {
        case excellent, good, fair, poor
        
        var color: String {
            switch self {
            case .excellent: return "green"
            case .good: return "blue"
            case .fair: return "orange"
            case .poor: return "gray"
            }
        }
        
        var label: String {
            switch self {
            case .excellent: return "Excellent Match"
            case .good: return "Good Match"
            case .fair: return "Potential Match"
            case .poor: return "Low Match"
            }
        }
    }
}

