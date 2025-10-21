import Foundation

/// Lead model matching the React app's customer data structure
struct Lead: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var email: String?
    var phone: String?
    var company: String?
    var budget: String? // String to support ranges like "$50k-$100k"
    var sizeMin: String?
    var sizeMax: String?
    var propertyType: String? // "Office", "Retail", "Warehouse", "Industrial", "Flex"
    var transactionType: String? // "Lease" or "Purchase"
    var moveTiming: String? // "MM/YY - MM/YY" or "Flexible"
    var moveStartDate: String? // "MM/YY"
    var moveEndDate: String? // "MM/YY"
    var timelineStatus: String? // "Immediate", "Heating Up", "Upcoming", "Overdue"
    var daysUntilMove: Int?
    var status: String // "Cold", "Warm", "Hot", "Closed"
    var preferredArea: String?
    var industry: String?
    var leaseTerm: String?
    var notes: String?
    var followUpOn: String? // ISO 8601 date (YYYY-MM-DD)
    var followUpNotes: String?
    var needsAttention: Bool? // True if follow-up is due/overdue (optional - may not be in response)
    let createdAt: String // ISO 8601
    let updatedAt: String // ISO 8601
    
    // Computed property for display date
    var followUpDate: Date? {
        guard let followUpOn = followUpOn, !followUpOn.isEmpty else { return nil }
        
        // CRITICAL: Backend sends dates as "2025-10-20T00:00:00.000Z" BUT the column is DATE (not TIMESTAMP)
        // This means the date is ALWAYS at midnight UTC regardless of user's timezone
        // We must extract ONLY the date portion and interpret it in LOCAL timezone
        // Otherwise "2025-10-20" UTC becomes "2025-10-19" in EST (wrong!)
        
        // Extract YYYY-MM-DD portion from any format
        var dateString = followUpOn
        if let tIndex = dateString.firstIndex(of: "T") {
            dateString = String(dateString[..<tIndex]) // Get everything before 'T'
        }
        
        // Now parse as a LOCAL date (not UTC)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current // USE LOCAL TIMEZONE, not UTC!
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            // Return date at midnight in LOCAL timezone
            // This ensures Oct 20 in database = Oct 20 for user, regardless of timezone
            return date
        }
        
        return nil
    }
    
    var createdDate: Date? {
        // Try ISO8601 with and without milliseconds
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: createdAt) {
            return date
        }
        
        // Fallback: Try custom date formatter
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = customFormatter.date(from: createdAt) {
            return date
        }
        
        // Second fallback: Without milliseconds
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return customFormatter.date(from: createdAt)
    }
    
    // CodingKeys to match API snake_case
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, company, budget, status, notes, industry
        case sizeMin, sizeMax, propertyType, transactionType, moveTiming
        case moveStartDate, moveEndDate, timelineStatus, daysUntilMove
        case preferredArea, leaseTerm
        case followUpOn, followUpNotes
        case needsAttention = "needs_attention"
        case createdAt, updatedAt
    }
    
    // Helper: Check if follow-up is overdue
    var isOverdue: Bool {
        guard let date = followUpDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let followUpDay = calendar.startOfDay(for: date)
        return followUpDay < today
    }
    
    // Helper: Check if follow-up is today
    var isDueToday: Bool {
        guard let date = followUpDate else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    // Helper: Check if follow-up is due or overdue (matches web app logic EXACTLY)
    var isFollowUpDue: Bool {
        guard let parsedDate = followUpDate else {
            return false
        }
        
        // Get today's date at midnight (local timezone)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let followUpDay = calendar.startOfDay(for: parsedDate)
        
        // Due if follow-up date is today or earlier (same logic as web app)
        return followUpDay <= today
    }
}

// MARK: - Lead Creation Payload
struct LeadCreatePayload: Codable {
    let name: String
    let email: String?
    let phone: String?
    let company: String?
    let budget: String?
    let sizeMin: String?
    let sizeMax: String?
    let propertyType: String?
    let transactionType: String?
    let moveTiming: String?
    let moveStartDate: String?
    let moveEndDate: String?
    let timelineStatus: String?
    let daysUntilMove: Int?
    let status: String
    let preferredArea: String?
    let industry: String?
    let leaseTerm: String?
    let notes: String?
    let followUpOn: String?
    let followUpNotes: String?
}

// MARK: - Lead Update Payload
struct LeadUpdatePayload: Codable {
    var name: String?
    var email: String?
    var phone: String?
    var company: String?
    var budget: String?
    var sizeMin: String?
    var sizeMax: String?
    var propertyType: String?
    var transactionType: String?
    var moveTiming: String?
    var moveStartDate: String?
    var moveEndDate: String?
    var timelineStatus: String?
    var daysUntilMove: Int?
    var status: String?
    var preferredArea: String?
    var industry: String?
    var leaseTerm: String?
    var notes: String?
    var followUpOn: String?
    var followUpNotes: String?
    var needsAttention: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name, email, phone, company, budget, status, notes, industry
        case sizeMin, sizeMax, propertyType, transactionType, moveTiming
        case moveStartDate, moveEndDate, timelineStatus, daysUntilMove
        case preferredArea, leaseTerm
        case followUpOn, followUpNotes
        case needsAttention = "needs_attention"
    }
    
    // Custom encoder that only includes non-nil values
    // This prevents sending null values that would overwrite existing data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Only encode non-nil values
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(company, forKey: .company)
        try container.encodeIfPresent(budget, forKey: .budget)
        try container.encodeIfPresent(sizeMin, forKey: .sizeMin)
        try container.encodeIfPresent(sizeMax, forKey: .sizeMax)
        try container.encodeIfPresent(propertyType, forKey: .propertyType)
        try container.encodeIfPresent(transactionType, forKey: .transactionType)
        try container.encodeIfPresent(moveTiming, forKey: .moveTiming)
        try container.encodeIfPresent(moveStartDate, forKey: .moveStartDate)
        try container.encodeIfPresent(moveEndDate, forKey: .moveEndDate)
        try container.encodeIfPresent(timelineStatus, forKey: .timelineStatus)
        try container.encodeIfPresent(daysUntilMove, forKey: .daysUntilMove)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(preferredArea, forKey: .preferredArea)
        try container.encodeIfPresent(industry, forKey: .industry)
        try container.encodeIfPresent(leaseTerm, forKey: .leaseTerm)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(followUpOn, forKey: .followUpOn)
        try container.encodeIfPresent(followUpNotes, forKey: .followUpNotes)
        try container.encodeIfPresent(needsAttention, forKey: .needsAttention)
    }
}

