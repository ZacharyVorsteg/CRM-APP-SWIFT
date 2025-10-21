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
        
        // REDESIGNED SCORING (emphasizes substantive criteria)
        // Total: 100 points distributed by importance
        let MAX_TOTAL_SCORE = 100
        
        print("🔍 Calculating matches for property: \(property.title)")
        print("   Property has: type=\(property.propertyType ?? "missing"), size=\(property.sizeMin ?? "nil")-\(property.sizeMax ?? "nil"), budget=\(property.budget ?? "missing"), industry=\(property.industry ?? "missing"), city=\(property.city ?? "missing")")
        
        for lead in leads {
            var score = 0
            var reasons: [String] = []
            var missingCriteria: [String] = []
            
            // SIZE MATCH (40 points) - Most important factor
            if let propMin = property.sizeMin, let propMax = property.sizeMax,
               let leadMin = lead.sizeMin, let leadMax = lead.sizeMax,
               let pMin = Int(propMin), let pMax = Int(propMax),
               let lMin = Int(leadMin), let lMax = Int(leadMax) {
                
                // Check if ranges overlap
                if pMin <= lMax && pMax >= lMin {
                    // Calculate overlap quality for partial scoring
                    let overlapStart = max(pMin, lMin)
                    let overlapEnd = min(pMax, lMax)
                    let overlapSize = overlapEnd - overlapStart
                    let leadRangeSize = lMax - lMin
                    
                    if overlapSize >= leadRangeSize {
                        // Property fully contains lead's range - perfect match
                        score += 40
                        reasons.append("Perfect size fit (\(formatNumber(propMin))-\(formatNumber(propMax)) SF)")
                    } else {
                        // Partial overlap - score proportionally
                        let overlapPercentage = Double(overlapSize) / Double(leadRangeSize)
                        let partialScore = Int(40.0 * overlapPercentage)
                        score += partialScore
                        reasons.append("Size range overlap (\(formatNumber(propMin))-\(formatNumber(propMax)) SF)")
                    }
                }
            } else {
                if (property.sizeMin == nil || property.sizeMin!.isEmpty) {
                    missingCriteria.append("Size not specified")
                }
            }
            
            // BUDGET MATCH (35 points) - Second most important
            let budgetScore = calculateBudgetMatch(propertyBudget: property.budget, leadBudget: lead.budget)
            score += budgetScore.score
            if let reason = budgetScore.reason {
                reasons.append(reason)
            }
            if budgetScore.score == 0 && (property.budget == nil || property.budget!.isEmpty) {
                missingCriteria.append("Budget not specified")
            }
            
            // INDUSTRY MATCH (15 points) - Contextual compatibility
            let industryScore = calculateIndustryMatch(propertyIndustry: property.industry, leadIndustry: lead.industry)
            score += industryScore.score
            if let reason = industryScore.reason {
                reasons.append(reason)
            }
            if industryScore.score == 0 && (property.industry == nil || property.industry!.isEmpty) {
                missingCriteria.append("Industry not specified")
            }
            
            // PROPERTY TYPE (5 points) - Basic filter, low weight
            if let propType = property.propertyType, !propType.isEmpty,
               let leadType = lead.propertyType, !leadType.isEmpty {
                if propType.lowercased() == leadType.lowercased() {
                    score += 5
                    reasons.append("Property type: \(propType)")
                }
            }
            
            // LOCATION (5 points) - Nice to have
            if let city = property.city, !city.isEmpty,
               let area = lead.preferredArea, !area.isEmpty {
                if area.lowercased().contains(city.lowercased()) || city.lowercased().contains(area.lowercased()) {
                    score += 5
                    reasons.append("Location: \(city)")
                }
            }
            
            // NOTE: Transaction type (Lease/Sale) is NOT scored
            // It's assumed to be pre-filtered or a basic requirement
            
            let matchPercentage = Int((Double(score) / Double(MAX_TOTAL_SCORE)) * 100)
            
            print("   \(lead.name): \(score)/\(MAX_TOTAL_SCORE) points = \(matchPercentage)%")
            if !missingCriteria.isEmpty {
                print("      Missing: \(missingCriteria.joined(separator: ", "))")
            }
            
            // Only show meaningful matches (at least 40% of possible score)
            // This ensures substantive criteria are met
            if matchPercentage >= 40 && reasons.count >= 2 {
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
        
        return matches.sorted { $0.matchScore > $1.matchScore }
    }
    
    // MARK: - Smart Budget Matching
    private func calculateBudgetMatch(propertyBudget: String?, leadBudget: String?) -> (score: Int, reason: String?) {
        guard let propBudget = propertyBudget, !propBudget.isEmpty,
              let leadBudget = leadBudget, !leadBudget.isEmpty else {
            return (0, nil)
        }
        
        // Extract numeric values from budget strings (e.g., "$5,000 - $10,000/mo")
        let propRange = extractBudgetRange(from: propBudget)
        let leadRange = extractBudgetRange(from: leadBudget)
        
        // If both have numeric ranges, compare overlap
        if let (propMin, propMax) = propRange, let (leadMin, leadMax) = leadRange {
            // Check if property budget falls within or overlaps lead's budget
            if propMin <= leadMax && propMax >= leadMin {
                let overlapStart = max(propMin, leadMin)
                let overlapEnd = min(propMax, leadMax)
                let overlapAmount = overlapEnd - overlapStart
                let leadRangeSize = leadMax - leadMin
                
                let overlapPercentage = Double(overlapAmount) / Double(max(leadRangeSize, 1))
                let score = Int(35.0 * max(0.5, overlapPercentage)) // Minimum 50% of points for any overlap
                
                return (score, "Budget aligned ($\(formatBudget(propMin))-$\(formatBudget(propMax))/mo)")
            }
        }
        
        // Fallback to string comparison
        if propBudget.lowercased() == leadBudget.lowercased() {
            return (35, "Budget matches (\(propBudget))")
        }
        
        return (0, nil)
    }
    
    // Extract min and max budget from string (handles "$5,000 - $10,000/mo" format)
    private func extractBudgetRange(from budgetString: String) -> (Int, Int)? {
        // Remove currency symbols, commas, and "/mo"
        let cleaned = budgetString.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "/mo", with: "")
            .replacingOccurrences(of: "/month", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        // Split on dash or hyphen
        let parts = cleaned.components(separatedBy: CharacterSet(charactersIn: "-–—"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .compactMap { Int($0) }
        
        if parts.count == 2 {
            return (parts[0], parts[1])
        } else if parts.count == 1 {
            // Single value - use as both min and max
            return (parts[0], parts[0])
        }
        
        return nil
    }
    
    private func formatBudget(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    // MARK: - Smart Industry Matching with Umbrella Categories
    private func calculateIndustryMatch(propertyIndustry: String?, leadIndustry: String?) -> (score: Int, reason: String?) {
        guard let propInd = propertyIndustry, !propInd.isEmpty,
              let leadInd = leadIndustry, !leadInd.isEmpty else {
            return (0, nil)
        }
        
        let propLower = propInd.lowercased()
        let leadLower = leadInd.lowercased()
        
        // Exact match
        if propLower == leadLower {
            return (15, "Industry: \(propInd)")
        }
        
        // Define industry umbrella categories (similar operational needs)
        let industrialLogistics = ["construction", "contracting", "distribution", "logistics", "warehousing", "manufacturing", "wholesale"]
        let retail = ["retail", "e-commerce", "consumer goods", "fashion", "grocery"]
        let foodBeverage = ["restaurant", "food service", "catering", "brewery", "food production"]
        let automotive = ["automotive", "auto repair", "auto body", "auto parts", "dealership"]
        let healthWellness = ["healthcare", "medical", "fitness", "spa", "wellness"]
        let technology = ["technology", "software", "it services", "data center", "tech startup"]
        let professional = ["office", "professional services", "consulting", "legal", "accounting"]
        let creative = ["creative", "design", "marketing", "advertising", "media"]
        
        let categories = [
            industrialLogistics,
            retail,
            foodBeverage,
            automotive,
            healthWellness,
            technology,
            professional,
            creative
        ]
        
        // Check if both industries fall under same umbrella
        for category in categories {
            let propInCategory = category.contains { propLower.contains($0) }
            let leadInCategory = category.contains { leadLower.contains($0) }
            
            if propInCategory && leadInCategory {
                return (12, "Compatible industry (\(propInd))")
            }
        }
        
        return (0, nil)
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

