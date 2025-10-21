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
            let token = try KeychainManager.shared.getToken()
            guard let url = URL(string: "\(Endpoints.baseURL)/properties") else {
                throw NetworkError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ Properties fetch failed with status: \(httpResponse.statusCode)")
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            let decoded = try JSONDecoder().decode(PropertiesResponse.self, from: data)
            properties = decoded.properties
            
            print("✅ Fetched \(properties.count) properties")
            
        } catch {
            print("❌ Error fetching properties:", error)
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Add new property
    func addProperty(_ payload: PropertyCreatePayload) async throws {
        let token = try KeychainManager.shared.getToken()
        guard let url = URL(string: "\(Endpoints.baseURL)/properties") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Property creation failed with status: \(httpResponse.statusCode)")
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(PropertyCreateResponse.self, from: data)
        
        // Add to local list
        properties.insert(decoded.property, at: 0)
        
        // Store matches for notifications
        if !decoded.matches.isEmpty {
            print("🎯 Property matched with \(decoded.matches.count) leads")
            // Could trigger notifications here
        }
        
        print("✅ Property added: \(decoded.property.title)")
    }
    
    // Update property
    func updateProperty(id: String, updates: PropertyUpdatePayload) async throws {
        let token = try KeychainManager.shared.getToken()
        guard let url = URL(string: "\(Endpoints.baseURL)/properties/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(updates)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(PropertyResponse.self, from: data)
        
        // Update local list
        if let index = properties.firstIndex(where: { $0.id == id }) {
            properties[index] = decoded.property
        }
        
        print("✅ Property updated: \(decoded.property.title)")
    }
    
    // Delete property
    func deleteProperty(id: String) async throws {
        let token = try KeychainManager.shared.getToken()
        guard let url = URL(string: "\(Endpoints.baseURL)/properties/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
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

