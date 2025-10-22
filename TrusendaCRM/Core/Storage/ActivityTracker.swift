import Foundation

/// Activity type for CRM events
enum ActivityType: String, Codable {
    case leadCreated = "lead_created"
    case leadUpdated = "lead_updated"
    case leadDeleted = "lead_deleted"
    case leadStatusChanged = "lead_status_changed"
    case leadContacted = "lead_contacted"
    case followUpScheduled = "follow_up_scheduled"
    
    case propertyCreated = "property_created"
    case propertyUpdated = "property_updated"
    case propertyDeleted = "property_deleted"
    case propertyMatched = "property_matched"
    
    var icon: String {
        switch self {
        case .leadCreated: return "plus.circle.fill"
        case .leadUpdated: return "pencil.circle.fill"
        case .leadDeleted: return "trash.circle.fill"
        case .leadStatusChanged: return "arrow.triangle.2.circlepath"
        case .leadContacted: return "checkmark.circle.fill"
        case .followUpScheduled: return "calendar.badge.plus"
        case .propertyCreated: return "building.2.circle.fill"
        case .propertyUpdated: return "building.2.circle"
        case .propertyDeleted: return "building.2.crop.circle.badge.minus"
        case .propertyMatched: return "person.2.crop.square.stack.fill"
        }
    }
    
    var color: String {
        switch self {
        case .leadCreated, .propertyCreated: return "green"
        case .leadUpdated, .propertyUpdated: return "blue"
        case .leadDeleted, .propertyDeleted: return "red"
        case .leadStatusChanged: return "purple"
        case .leadContacted: return "blue"
        case .followUpScheduled: return "orange"
        case .propertyMatched: return "green"
        }
    }
}

/// Activity record for CRM events
struct ActivityRecord: Codable, Identifiable {
    let id: String
    let type: ActivityType
    let itemId: String // Lead or Property ID
    let itemName: String // Lead name or Property title
    let details: String // Additional context
    let timestamp: Date
    let metadata: [String: String]? // Optional additional data
    
    init(type: ActivityType, itemId: String, itemName: String, details: String, metadata: [String: String]? = nil) {
        self.id = UUID().uuidString
        self.type = type
        self.itemId = itemId
        self.itemName = itemName
        self.details = details
        self.timestamp = Date()
        self.metadata = metadata
    }
}

/// Activity Tracker - Logs all CRM events for Recent Activity view
/// Stores activities in UserDefaults with automatic cleanup
final class ActivityTracker {
    static let shared = ActivityTracker()
    
    private let userDefaults = UserDefaults.standard
    private let activitiesKey = "crm_activities"
    private let maxActivities = 100 // Keep last 100 activities
    private let maxAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    private init() {
        // Clean old activities on init
        cleanOldActivities()
    }
    
    // MARK: - Lead Activities
    
    func logLeadCreated(lead: Lead) {
        let activity = ActivityRecord(
            type: .leadCreated,
            itemId: lead.id,
            itemName: lead.name,
            details: lead.company ?? "New lead added",
            metadata: ["status": lead.status]
        )
        saveActivity(activity)
    }
    
    func logLeadUpdated(lead: Lead, fieldChanged: String? = nil) {
        let details = fieldChanged != nil ? "\(fieldChanged!) updated" : "Lead information updated"
        let activity = ActivityRecord(
            type: .leadUpdated,
            itemId: lead.id,
            itemName: lead.name,
            details: details,
            metadata: ["status": lead.status, "field": fieldChanged ?? "multiple"]
        )
        saveActivity(activity)
    }
    
    func logLeadDeleted(leadId: String, leadName: String) {
        let activity = ActivityRecord(
            type: .leadDeleted,
            itemId: leadId,
            itemName: leadName,
            details: "Lead removed from CRM"
        )
        saveActivity(activity)
    }
    
    func logStatusChange(lead: Lead, from oldStatus: String, to newStatus: String) {
        let activity = ActivityRecord(
            type: .leadStatusChanged,
            itemId: lead.id,
            itemName: lead.name,
            details: "\(oldStatus) → \(newStatus)",
            metadata: ["from": oldStatus, "to": newStatus]
        )
        saveActivity(activity)
    }
    
    func logLeadContacted(lead: Lead, newStatus: String? = nil) {
        var details = "Marked as contacted"
        if let status = newStatus {
            details += " (now \(status))"
        }
        let activity = ActivityRecord(
            type: .leadContacted,
            itemId: lead.id,
            itemName: lead.name,
            details: details,
            metadata: ["status": lead.status]
        )
        saveActivity(activity)
    }
    
    func logFollowUpScheduled(lead: Lead, date: Date, notes: String?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: date)
        
        var details = "Follow-up scheduled for \(dateString)"
        if let notes = notes, !notes.isEmpty {
            details = notes
        }
        
        let activity = ActivityRecord(
            type: .followUpScheduled,
            itemId: lead.id,
            itemName: lead.name,
            details: details,
            metadata: ["date": dateString]
        )
        saveActivity(activity)
    }
    
    // MARK: - Property Activities
    
    func logPropertyCreated(property: Property, matchCount: Int = 0) {
        var details = "Property listed"
        if matchCount > 0 {
            details += " • Matched with \(matchCount) lead\(matchCount == 1 ? "" : "s")"
        }
        
        let activity = ActivityRecord(
            type: .propertyCreated,
            itemId: property.id,
            itemName: property.title,
            details: details,
            metadata: [
                "status": property.status,
                "type": property.propertyType ?? "Unknown",
                "matches": "\(matchCount)"
            ]
        )
        saveActivity(activity)
    }
    
    func logPropertyUpdated(property: Property) {
        let activity = ActivityRecord(
            type: .propertyUpdated,
            itemId: property.id,
            itemName: property.title,
            details: "Property details updated",
            metadata: ["status": property.status]
        )
        saveActivity(activity)
    }
    
    func logPropertyDeleted(propertyId: String, title: String) {
        let activity = ActivityRecord(
            type: .propertyDeleted,
            itemId: propertyId,
            itemName: title,
            details: "Property removed"
        )
        saveActivity(activity)
    }
    
    func logPropertyMatched(property: Property, matchCount: Int) {
        let activity = ActivityRecord(
            type: .propertyMatched,
            itemId: property.id,
            itemName: property.title,
            details: "Matched with \(matchCount) lead\(matchCount == 1 ? "" : "s")",
            metadata: ["matches": "\(matchCount)"]
        )
        saveActivity(activity)
    }
    
    // MARK: - Retrieval
    
    func getRecentActivities(limit: Int = 50) -> [ActivityRecord] {
        guard let data = userDefaults.data(forKey: activitiesKey),
              let activities = try? JSONDecoder().decode([ActivityRecord].self, from: data) else {
            return []
        }
        
        // Return most recent first
        return Array(activities
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(limit))
    }
    
    func getActivities(for itemId: String) -> [ActivityRecord] {
        let allActivities = getRecentActivities(limit: maxActivities)
        return allActivities.filter { $0.itemId == itemId }
    }
    
    func getActivities(ofType type: ActivityType) -> [ActivityRecord] {
        let allActivities = getRecentActivities(limit: maxActivities)
        return allActivities.filter { $0.type == type }
    }
    
    // MARK: - Private Methods
    
    private func saveActivity(_ activity: ActivityRecord) {
        var activities = getRecentActivities(limit: maxActivities)
        
        // Add new activity
        activities.insert(activity, at: 0)
        
        // Trim to max
        if activities.count > maxActivities {
            activities = Array(activities.prefix(maxActivities))
        }
        
        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(activities) {
            userDefaults.set(data, forKey: activitiesKey)
        }
        
        #if DEBUG
        print("📝 Activity logged: \(activity.type.rawValue) - \(activity.itemName)")
        #endif
    }
    
    private func cleanOldActivities() {
        var activities = getRecentActivities(limit: maxActivities)
        let cutoffDate = Date().addingTimeInterval(-maxAge)
        
        // Remove activities older than 7 days
        activities.removeAll { $0.timestamp < cutoffDate }
        
        // Save cleaned list
        if let data = try? JSONEncoder().encode(activities) {
            userDefaults.set(data, forKey: activitiesKey)
        }
    }
    
    /// Clear all activities (for testing/reset)
    func clearAll() {
        userDefaults.removeObject(forKey: activitiesKey)
        #if DEBUG
        print("🗑️ All activities cleared")
        #endif
    }
    
    /// Get statistics
    func getStats() -> (total: Int, today: Int, thisWeek: Int) {
        let activities = getRecentActivities(limit: maxActivities)
        let calendar = Calendar.current
        let now = Date()
        
        let today = activities.filter { calendar.isDateInToday($0.timestamp) }.count
        let weekAgo = now.addingTimeInterval(-7 * 24 * 60 * 60)
        let thisWeek = activities.filter { $0.timestamp > weekAgo }.count
        
        return (activities.count, today, thisWeek)
    }
}

