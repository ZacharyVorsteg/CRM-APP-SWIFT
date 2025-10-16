import Foundation
import Combine

/// ViewModel for managing leads (customers) - matches React app's state management
@MainActor
class LeadViewModel: ObservableObject {
    @Published var leads: [Lead] = []
    @Published var filteredLeads: [Lead] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var successMessage: String?
    
    // Plan limits
    @Published var maxLeads: Int = 10
    @Published var isOverLimit = false
    @Published var isBlocked = false
    @Published var gracePeriodDays: Int?
    
    // Follow-ups
    @Published var followUpCount: Int = 0
    @Published var showFollowUpsOnly = false
    
    // Search and filters
    @Published var searchText = ""
    @Published var statusFilter: String?
    @Published var propertyTypeFilter: String?
    @Published var timelineFilter: String?
    
    private let client = APIClient.shared
    
    // MARK: - Fetch Leads
    func fetchLeads() async {
        isLoading = true
        error = nil
        
        do {
            let response: LeadsResponse = try await client.get(endpoint: .customers)
            
            leads = response.customers
            maxLeads = response.maxLeads
            isOverLimit = response.isOverLimit
            isBlocked = response.isBlocked
            gracePeriodDays = response.gracePeriodDaysRemaining
            
            // Calculate follow-up count
            followUpCount = leads.filter { $0.needsAttention }.count
            
            // Apply filters
            applyFilters()
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Create Lead
    func createLead(_ payload: LeadCreatePayload) async throws {
        // Check plan limits
        if leads.count >= maxLeads && !AuthManager.shared.currentUser?.isPro ?? false {
            throw NetworkError.serverError(400, "Plan limit reached. Upgrade to Pro for unlimited leads.")
        }
        
        let response: LeadActionResponse = try await client.post(
            endpoint: .customers,
            body: payload
        )
        
        // Add to local array
        leads.insert(response.customer, at: 0)
        applyFilters()
        
        successMessage = "✅ Lead added successfully"
        clearMessageAfterDelay()
    }
    
    // MARK: - Update Lead
    func updateLead(id: String, updates: LeadUpdatePayload) async throws {
        let response: LeadActionResponse = try await client.put(
            endpoint: .customer(id: id),
            body: updates
        )
        
        // Update in local array
        if let index = leads.firstIndex(where: { $0.id == id }) {
            leads[index] = response.customer
        }
        
        applyFilters()
        
        successMessage = "✅ Lead updated"
        clearMessageAfterDelay()
    }
    
    // MARK: - Delete Lead
    func deleteLead(id: String) async throws {
        try await client.delete(endpoint: .customer(id: id))
        
        // Remove from local array
        leads.removeAll { $0.id == id }
        applyFilters()
        
        successMessage = "✅ Lead deleted"
        clearMessageAfterDelay()
    }
    
    // MARK: - Bulk Delete
    func deleteLeads(ids: [String]) async throws {
        for id in ids {
            try await deleteLead(id: id)
        }
    }
    
    // MARK: - Follow-Up Actions
    func snoozeFollowUp(leadId: String, days: Int) async throws {
        struct SnoozeRequest: Codable {
            let lead_id: String
            let days: Int
        }
        
        let request = SnoozeRequest(lead_id: leadId, days: days)
        try await client.post(endpoint: .leadSnooze, body: request)
        
        // Refresh leads
        await fetchLeads()
        
        successMessage = "✅ Lead snoozed for \(days) day\(days > 1 ? "s" : "")"
        clearMessageAfterDelay()
    }
    
    func markContacted(leadId: String) async throws {
        struct ContactedRequest: Codable {
            let lead_id: String
        }
        
        let request = ContactedRequest(lead_id: leadId)
        try await client.post(endpoint: .leadMarkContacted, body: request)
        
        // Refresh leads
        await fetchLeads()
        
        successMessage = "✅ Marked as contacted"
        clearMessageAfterDelay()
    }
    
    // MARK: - Filtering
    func applyFilters() {
        var filtered = leads
        
        // Follow-ups only
        if showFollowUpsOnly {
            filtered = filtered.filter { $0.needsAttention }
        }
        
        // Search
        if !searchText.isEmpty {
            filtered = filtered.filter { lead in
                lead.name.localizedCaseInsensitiveContains(searchText) ||
                lead.email?.localizedCaseInsensitiveContains(searchText) ?? false ||
                lead.company?.localizedCaseInsensitiveContains(searchText) ?? false ||
                lead.notes?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        // Status filter
        if let status = statusFilter {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Property type filter
        if let propertyType = propertyTypeFilter {
            filtered = filtered.filter { $0.propertyType == propertyType }
        }
        
        // Timeline filter
        if let timeline = timelineFilter {
            filtered = filtered.filter { $0.timelineStatus == timeline }
        }
        
        filteredLeads = filtered
    }
    
    // MARK: - Sorting
    func sortLeads(by key: LeadSortKey, ascending: Bool = true) {
        filteredLeads.sort { lead1, lead2 in
            let comparison: Bool
            
            switch key {
            case .name:
                comparison = lead1.name < lead2.name
            case .createdAt:
                comparison = (lead1.createdDate ?? Date.distantPast) < (lead2.createdDate ?? Date.distantPast)
            case .status:
                comparison = lead1.status < lead2.status
            case .followUp:
                let date1 = lead1.followUpDate ?? Date.distantFuture
                let date2 = lead2.followUpDate ?? Date.distantFuture
                comparison = date1 < date2
            case .timeline:
                let days1 = lead1.daysUntilMove ?? Int.max
                let days2 = lead2.daysUntilMove ?? Int.max
                comparison = days1 < days2
            }
            
            return ascending ? comparison : !comparison
        }
    }
    
    // MARK: - Helpers
    private func clearMessageAfterDelay() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            successMessage = nil
        }
    }
    
    func clearError() {
        error = nil
    }
}

enum LeadSortKey {
    case name
    case createdAt
    case status
    case followUp
    case timeline
}

