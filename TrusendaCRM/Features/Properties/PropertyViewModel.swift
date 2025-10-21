import Foundation

@MainActor
class PropertyViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var matches: [LeadPropertyMatch] = []
    
    private let apiClient = APIClient.shared
    
    // Fetch all properties
    func fetchProperties() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: PropertiesResponse = try await apiClient.get(endpoint: .properties)
            properties = response.properties
            
            print("✅ Fetched \(properties.count) properties")
            
        } catch {
            print("❌ Error fetching properties:", error)
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Add new property
    func addProperty(_ payload: PropertyCreatePayload) async throws {
        let response: PropertyCreateResponse = try await apiClient.post(
            endpoint: .properties,
            body: payload
        )
        
        // Add to local list
        properties.insert(response.property, at: 0)
        
        // Store matches for notifications
        if !response.matches.isEmpty {
            print("🎯 Property matched with \(response.matches.count) leads")
            // Could trigger notifications here
        }
        
        print("✅ Property added: \(response.property.title)")
    }
    
    // Update property
    func updateProperty(id: String, updates: PropertyUpdatePayload) async throws {
        let response: PropertyResponse = try await apiClient.put(
            endpoint: .property(id: id),
            body: updates
        )
        
        // Update local list
        if let index = properties.firstIndex(where: { $0.id == id }) {
            properties[index] = response.property
        }
        
        print("✅ Property updated: \(response.property.title)")
    }
    
    // Delete property
    func deleteProperty(id: String) async throws {
        try await apiClient.delete(endpoint: .property(id: id))
        
        // Remove from local list
        properties.removeAll { $0.id == id }
        
        print("✅ Property deleted")
    }
    
    // Calculate matches for a property with leads
    func calculateMatches(for property: Property, with leads: [Lead]) -> [LeadPropertyMatch] {
        var matches: [LeadPropertyMatch] = []
        
        for lead in leads {
            var score = 0
            var reasons: [String] = []
            
            // Property Type match (30 points)
            if let propType = property.propertyType,
               let leadType = lead.propertyType,
               propType.lowercased() == leadType.lowercased() {
                score += 30
                reasons.append("Property type matches")
            }
            
            // Transaction Type match (20 points)
            if let propTrans = property.transactionType,
               let leadTrans = lead.transactionType,
               propTrans.lowercased() == leadTrans.lowercased() {
                score += 20
                reasons.append("Transaction type matches")
            }
            
            // Size match (25 points)
            if let propMin = property.sizeMin, let propMax = property.sizeMax,
               let leadMin = lead.sizeMin, let leadMax = lead.sizeMax,
               let pMin = Int(propMin), let pMax = Int(propMax),
               let lMin = Int(leadMin), let lMax = Int(leadMax) {
                // Check overlap
                if pMin <= lMax && pMax >= lMin {
                    score += 25
                    reasons.append("Size range matches")
                }
            }
            
            // Industry match (15 points)
            if let propInd = property.industry,
               let leadInd = lead.industry,
               propInd.lowercased() == leadInd.lowercased() {
                score += 15
                reasons.append("Industry matches")
            }
            
            // Location match (10 points)
            if let city = property.city,
               let area = lead.preferredArea,
               area.lowercased().contains(city.lowercased()) {
                score += 10
                reasons.append("Location matches")
            }
            
            // Only meaningful matches (50%+)
            if score >= 50 {
                matches.append(LeadPropertyMatch(
                    id: "\(property.id)-\(lead.id)",
                    property: property,
                    lead: lead,
                    matchScore: score,
                    matchReasons: reasons
                ))
            }
        }
        
        // Sort by score (best matches first)
        return matches.sorted { $0.matchScore > $1.matchScore }
    }
}

// MARK: - API Response Models
struct PropertiesResponse: Codable {
    let properties: [Property]
    let total: Int
}

struct PropertyResponse: Codable {
    let property: Property
}

struct PropertyCreateResponse: Codable {
    let property: Property
    let matches: [PropertyMatchInfo]
}

struct PropertyMatchInfo: Codable {
    let leadId: String
    let leadName: String
    let propertyId: String
    let propertyTitle: String
    let score: Int
    let reasons: [String]
}

