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
            
            // Force main thread update
            await MainActor.run {
                properties = response.properties
                print("✅ Fetched \(properties.count) properties")
                print("   Properties: \(properties.map { $0.title }.joined(separator: ", "))")
            }
            
        } catch {
            print("❌ Error fetching properties:", error)
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
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
    // WEIGHTED AVERAGE: Score is against TOTAL possible (110 pts), not just available data
    // This gives an honest, accurate representation of match quality
    func calculateMatches(for property: Property, with leads: [Lead]) -> [LeadPropertyMatch] {
        var matches: [LeadPropertyMatch] = []
        
        // TOTAL POSSIBLE SCORE (all criteria)
        let MAX_TOTAL_SCORE = 110
        
        print("🔍 Calculating matches for property: \(property.title)")
        print("   Property has: type=\(property.propertyType ?? "missing"), size=\(property.sizeMin ?? "nil")-\(property.sizeMax ?? "nil"), budget=\(property.budget ?? "missing"), industry=\(property.industry ?? "missing"), city=\(property.city ?? "missing")")
        
        for lead in leads {
            var score = 0
            var reasons: [String] = []
            var missingCriteria: [String] = []
            
            // Property Type match (30 points)
            if let propType = property.propertyType, !propType.isEmpty,
               let leadType = lead.propertyType, !leadType.isEmpty {
                if propType.lowercased() == leadType.lowercased() {
                    score += 30
                    reasons.append("Property type matches (\(propType))")
                }
            } else {
                if property.propertyType == nil || property.propertyType!.isEmpty {
                    missingCriteria.append("Property type not specified")
                }
            }
            
            // Transaction Type match (20 points)
            if let propTrans = property.transactionType, !propTrans.isEmpty,
               let leadTrans = lead.transactionType, !leadTrans.isEmpty {
                if propTrans.lowercased() == leadTrans.lowercased() {
                    score += 20
                    reasons.append("Transaction type matches (\(propTrans))")
                }
            }
            
            // Size match (25 points)
            if let propMin = property.sizeMin, let propMax = property.sizeMax,
               let leadMin = lead.sizeMin, let leadMax = lead.sizeMax,
               let pMin = Int(propMin), let pMax = Int(propMax),
               let lMin = Int(leadMin), let lMax = Int(leadMax) {
                if pMin <= lMax && pMax >= lMin {
                    score += 25
                    reasons.append("Size range matches (\(formatNumber(propMin))-\(formatNumber(propMax)) SF)")
                }
            } else {
                if (property.sizeMin == nil || property.sizeMin!.isEmpty) {
                    missingCriteria.append("Size not specified")
                }
            }
            
            // Budget match (15 points)
            if let propBudget = property.budget, !propBudget.isEmpty,
               let leadBudget = lead.budget, !leadBudget.isEmpty {
                if propBudget.lowercased() == leadBudget.lowercased() {
                    score += 15
                    reasons.append("Budget aligned (\(propBudget))")
                }
            }
            
            // Industry match (10 points)
            if let propInd = property.industry, !propInd.isEmpty,
               let leadInd = lead.industry, !leadInd.isEmpty {
                if propInd.lowercased() == leadInd.lowercased() {
                    score += 10
                    reasons.append("Industry matches (\(propInd))")
                }
            } else {
                if property.industry == nil || property.industry!.isEmpty {
                    missingCriteria.append("Industry not specified")
                }
            }
            
            // Location match (10 points)
            if let city = property.city, !city.isEmpty,
               let area = lead.preferredArea, !area.isEmpty {
                if area.lowercased().contains(city.lowercased()) {
                    score += 10
                    reasons.append("Location matches (\(city))")
                }
            } else {
                if property.city == nil || property.city!.isEmpty {
                    missingCriteria.append("Location not specified")
                }
            }
            
            // HONEST PERCENTAGE: Score against TOTAL possible (110 pts)
            // This shows the true match quality, accounting for missing data
            let matchPercentage = Int((Double(score) / Double(MAX_TOTAL_SCORE)) * 100)
            
            print("   \(lead.name): \(score)/\(MAX_TOTAL_SCORE) points = \(matchPercentage)%")
            if !missingCriteria.isEmpty {
                print("      Missing: \(missingCriteria.joined(separator: ", "))")
            }
            
            // Show matches with at least 30% of total score
            // This means at least 2-3 criteria match
            if matchPercentage >= 30 && reasons.count > 0 {
                matches.append(LeadPropertyMatch(
                    id: "\(property.id)-\(lead.id)",
                    property: property,
                    lead: lead,
                    matchScore: matchPercentage,
                    matchReasons: reasons
                ))
                print("   ✅ MATCH! \(lead.name) - \(matchPercentage)% (honest score) - \(reasons.joined(separator: ", "))")
            }
        }
        
        print("🎯 Total matches found: \(matches.count)")
        
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

