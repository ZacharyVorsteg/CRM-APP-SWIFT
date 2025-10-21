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
    // PARTIAL MATCHING: Works even with incomplete data
    func calculateMatches(for property: Property, with leads: [Lead]) -> [LeadPropertyMatch] {
        var matches: [LeadPropertyMatch] = []
        
        print("🔍 Calculating matches for property: \(property.title)")
        print("   Property has: type=\(property.propertyType ?? "nil"), size=\(property.sizeMin ?? "nil")-\(property.sizeMax ?? "nil"), budget=\(property.budget ?? "nil")")
        
        for lead in leads {
            var score = 0
            var maxPossibleScore = 0 // Track what's possible with available data
            var reasons: [String] = []
            
            // Property Type match (30 points) - only if BOTH have values
            if let propType = property.propertyType, !propType.isEmpty,
               let leadType = lead.propertyType, !leadType.isEmpty {
                maxPossibleScore += 30
                if propType.lowercased() == leadType.lowercased() {
                    score += 30
                    reasons.append("Property type matches (\(propType))")
                }
            }
            
            // Transaction Type match (20 points) - only if BOTH have values
            if let propTrans = property.transactionType, !propTrans.isEmpty,
               let leadTrans = lead.transactionType, !leadTrans.isEmpty {
                maxPossibleScore += 20
                if propTrans.lowercased() == leadTrans.lowercased() {
                    score += 20
                    reasons.append("Transaction type matches (\(propTrans))")
                }
            }
            
            // Size match (25 points) - only if BOTH have values
            if let propMin = property.sizeMin, let propMax = property.sizeMax,
               let leadMin = lead.sizeMin, let leadMax = lead.sizeMax,
               let pMin = Int(propMin), let pMax = Int(propMax),
               let lMin = Int(leadMin), let lMax = Int(leadMax) {
                maxPossibleScore += 25
                // Check overlap
                if pMin <= lMax && pMax >= lMin {
                    score += 25
                    reasons.append("Size range matches (\(formatNumber(propMin))-\(formatNumber(propMax)) SF)")
                }
            }
            
            // Budget/Price match (15 points) - if either budget or price is set
            if let propBudget = property.budget, !propBudget.isEmpty,
               let leadBudget = lead.budget, !leadBudget.isEmpty {
                maxPossibleScore += 15
                if propBudget.lowercased() == leadBudget.lowercased() {
                    score += 15
                    reasons.append("Budget aligned (\(propBudget))")
                }
            }
            
            // Industry match (10 points) - only if BOTH have values
            if let propInd = property.industry, !propInd.isEmpty,
               let leadInd = lead.industry, !leadInd.isEmpty {
                maxPossibleScore += 10
                if propInd.lowercased() == leadInd.lowercased() {
                    score += 10
                    reasons.append("Industry matches (\(propInd))")
                }
            }
            
            // Location match (10 points) - only if BOTH have values
            if let city = property.city, !city.isEmpty,
               let area = lead.preferredArea, !area.isEmpty {
                maxPossibleScore += 10
                if area.lowercased().contains(city.lowercased()) {
                    score += 10
                    reasons.append("Location matches (\(city))")
                }
            }
            
            // Calculate percentage based on what's actually comparable
            let matchPercentage = maxPossibleScore > 0 ? Int((Double(score) / Double(maxPossibleScore)) * 100) : 0
            
            print("   \(lead.name): \(score)/\(maxPossibleScore) points = \(matchPercentage)%")
            
            // Partial match threshold: 40% of available criteria
            // This allows matches even with limited data
            if matchPercentage >= 40 && reasons.count > 0 {
                matches.append(LeadPropertyMatch(
                    id: "\(property.id)-\(lead.id)",
                    property: property,
                    lead: lead,
                    matchScore: matchPercentage,
                    matchReasons: reasons
                ))
                print("   ✅ MATCH! \(lead.name) - \(matchPercentage)% - \(reasons.joined(separator: ", "))")
            }
        }
        
        print("🎯 Total matches found: \(matches.count)")
        
        // Sort by score (best matches first)
        return matches.sorted { $0.matchScore > $1.matchScore }
    }
    
    private func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? value
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

