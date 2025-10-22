import Foundation
import Combine

/// ViewModel for managing leads (customers) - matches React app's state management
@MainActor
class LeadViewModel: ObservableObject {
    @Published var leads: [Lead] = []
    @Published var filteredLeads: [Lead] = []
    @Published var displayedLeads: [Lead] = [] // For pagination display
    @Published var isLoading = false
    @Published var isLoadingMore = false
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
    
    // Pagination (client-side for now - fast and reliable)
    private var currentDisplayCount = 20
    private let pageSize = 20
    
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
            
            // Calculate follow-up count (matches web app logic)
            // Web app checks if followUpOn date is today or earlier
            followUpCount = leads.filter { $0.isFollowUpDue }.count
            
            // Apply filters
            applyFilters()
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Error fetching leads:", error)
            clearMessageAfterDelay()
        }
        
        isLoading = false
    }
    
    // MARK: - Create Lead
    func createLead(_ payload: LeadCreatePayload) async throws {
        // Check plan limits
        if leads.count >= maxLeads && !(AuthManager.shared.currentUser?.isPro ?? false) {
            throw NetworkError.serverError(400, "Plan limit reached. Upgrade to Pro for unlimited leads.")
        }
        
        let response: LeadActionResponse = try await client.post(
            endpoint: .customers,
            body: payload
        )
        
        // Add to local array
        leads.insert(response.customer, at: 0)
        applyFilters()
        
        // Don't show ViewModel success message - PremiumSuccessToast handles this
        // successMessage = "✅ Lead added successfully"
        // clearMessageAfterDelay()
    }
    
    // MARK: - Update Lead
    func updateLead(id: String, updates: LeadUpdatePayload, optimistic: Bool = false) async throws {
        #if DEBUG
        print("📝 updateLead() called for ID: \(id)")
        print("📝 Current leads count: \(leads.count)")
        print("📝 Current statusFilter: \(statusFilter ?? "none")")
        #endif
        
        // Find the lead index
        guard let index = leads.firstIndex(where: { $0.id == id }) else {
            #if DEBUG
            print("⚠️ Lead not found in local array!")
            #endif
            throw NetworkError.serverError(404, "Lead not found")
        }
        
        // Save original state for rollback
        let originalLead = leads[index]
        
        #if DEBUG
        print("💾 Original lead BEFORE update: id=\(originalLead.id), name='\(originalLead.name)', status=\(originalLead.status)")
        #endif
        
        // Optimistic update: Update UI immediately if requested
        if optimistic {
            #if DEBUG
            print("⚡️ Applying optimistic update...")
            #endif
            var updatedLead = originalLead
            
            // Apply the updates to the local copy
            if let status = updates.status { updatedLead.status = status }
            if let name = updates.name { updatedLead.name = name }
            if let email = updates.email { updatedLead.email = email }
            if let phone = updates.phone { updatedLead.phone = phone }
            if let company = updates.company { updatedLead.company = company }
            if let budget = updates.budget { updatedLead.budget = budget }
            if let sizeMin = updates.sizeMin { updatedLead.sizeMin = sizeMin }
            if let sizeMax = updates.sizeMax { updatedLead.sizeMax = sizeMax }
            if let propertyType = updates.propertyType { updatedLead.propertyType = propertyType }
            if let transactionType = updates.transactionType { updatedLead.transactionType = transactionType }
            if let notes = updates.notes { updatedLead.notes = notes }
            if let followUpOn = updates.followUpOn { updatedLead.followUpOn = followUpOn }
            if let followUpNotes = updates.followUpNotes { updatedLead.followUpNotes = followUpNotes }
            
            // Update UI immediately
            leads[index] = updatedLead
            applyFilters()
            
            #if DEBUG
            print("⚡️ Optimistic update applied to UI")
            #endif
        }
        
        do {
            // Make API call
            let response: LeadActionResponse = try await client.put(
                endpoint: .customer(id: id),
                body: updates
            )
            
            #if DEBUG
            print("📥 Response received: \(response.customer.name) - \(response.customer.status)")
            print("📥 Response customer ID: \(response.customer.id)")
            print("📥 Response full customer: name='\(response.customer.name)', email=\(response.customer.email ?? "nil"), status=\(response.customer.status)")
            #endif
            
            // Update with server response (overrides optimistic update)
            leads[index] = response.customer
            
            #if DEBUG
            print("📝 Local lead updated from server: \(leads[index].name) - \(leads[index].status)")
            print("📝 Local lead full: id=\(leads[index].id), name='\(leads[index].name)', status=\(leads[index].status)")
            #endif
            
            applyFilters()
            
            #if DEBUG
            print("📝 Filtered leads after: \(filteredLeads.count)")
            print("📝 Displayed leads after: \(displayedLeads.count)")
            #endif
            
            successMessage = "✅ Lead updated"
            clearMessageAfterDelay()
            
        } catch {
            // Rollback optimistic update on error
            if optimistic {
                #if DEBUG
                print("❌ Update failed, rolling back optimistic changes...")
                #endif
                leads[index] = originalLead
                applyFilters()
                #if DEBUG
                print("🔄 Rollback complete")
                #endif
            }
            
            // Re-throw the error
            throw error
        }
    }
    
    // MARK: - Delete Lead
    func deleteLead(id: String) async throws {
        try await client.delete(endpoint: .customer(id: id))
        
        // Remove from local array
        leads.removeAll { $0.id == id }
        applyFilters()
        
        // Don't show ViewModel success message - UI handles this with premium toasts
        // successMessage = "✅ Lead deleted"
        // clearMessageAfterDelay()
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
        // Get current lead to determine status progression
        guard let currentLead = leads.first(where: { $0.id == leadId }) else {
            throw NetworkError.serverError(404, "Lead not found")
        }
        
        let oldStatus = currentLead.status
        
        struct ContactedRequest: Codable {
            let lead_id: String
        }
        
        let request = ContactedRequest(lead_id: leadId)
        let response: ContactedResponse = try await client.post(endpoint: .leadMarkContacted, body: request)
        
        // Determine new status from response
        let newStatus = response.lead.status
        
        // Refresh leads with animation-ready update
        await fetchLeads()
        
        // Intelligent success message based on status progression
        if oldStatus != newStatus {
            switch (oldStatus, newStatus) {
            case ("Cold", "Warm"):
                successMessage = "✅ Contact made! Lead now Warm"
            case ("Warm", "Hot"):
                successMessage = "✅ Great! Lead advanced to Hot"
            default:
                successMessage = "✅ Marked as contacted"
            }
        } else {
            successMessage = "✅ Marked as contacted"
        }
        
        clearMessageAfterDelay()
    }
    
    // MARK: - Filtering
    func applyFilters() {
        var filtered = leads
        
        // Follow-ups only
        if showFollowUpsOnly {
            filtered = filtered.filter { $0.isFollowUpDue }
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
        
        // Apply pagination for performance (display first page initially)
        currentDisplayCount = pageSize
        updateDisplayedLeads()
    }
    
    // MARK: - Pagination (Client-Side for Performance)
    func loadMoreLeadsIfNeeded(currentLead: Lead) {
        // Check if we're near the end of displayed leads
        let thresholdIndex = displayedLeads.index(displayedLeads.endIndex, offsetBy: -3, limitedBy: displayedLeads.startIndex) ?? displayedLeads.startIndex
        
        if let index = displayedLeads.firstIndex(where: { $0.id == currentLead.id }),
           index >= thresholdIndex,
           displayedLeads.count < filteredLeads.count,
           !isLoadingMore {
            loadMoreLeads()
        }
    }
    
    private func loadMoreLeads() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        
        // Simulate brief loading for smooth UX
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            currentDisplayCount += pageSize
            updateDisplayedLeads()
            
            isLoadingMore = false
        }
    }
    
    func resetPagination() {
        currentDisplayCount = pageSize
        updateDisplayedLeads()
    }
    
    private func updateDisplayedLeads() {
        let endIndex = min(currentDisplayCount, filteredLeads.count)
        displayedLeads = Array(filteredLeads.prefix(endIndex))
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
            error = nil
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

