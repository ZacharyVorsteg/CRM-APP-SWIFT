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
    var needsAttention: Bool // True if follow-up is due/overdue
    let createdAt: String // ISO 8601
    let updatedAt: String // ISO 8601
    
    // Computed property for display date
    var followUpDate: Date? {
        guard let followUpOn = followUpOn else { return nil }
        return ISO8601DateFormatter().date(from: followUpOn + "T00:00:00Z")
    }
    
    var createdDate: Date? {
        return ISO8601DateFormatter().date(from: createdAt)
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
        return date < Date()
    }
    
    // Helper: Check if follow-up is today
    var isDueToday: Bool {
        guard let date = followUpDate else { return false }
        return Calendar.current.isDateInToday(date)
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
}

