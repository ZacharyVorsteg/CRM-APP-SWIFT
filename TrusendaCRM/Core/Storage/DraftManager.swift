import Foundation

/// Manages draft lead data for auto-save and recovery
/// Handles interruptions (calls, background, app termination) to prevent data loss
class DraftManager {
    static let shared = DraftManager()
    
    private let defaults = UserDefaults.standard
    private let draftKey = "com.trusenda.leadDraft"
    
    private init() {}
    
    // MARK: - Draft Operations
    
    /// Save lead draft to UserDefaults
    func saveDraft(_ draft: LeadDraft) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(draft)
            defaults.set(data, forKey: draftKey)
            defaults.synchronize() // Force immediate save
            print("💾 Draft saved: \(draft.name)")
        } catch {
            print("❌ Failed to save draft: \(error)")
        }
    }
    
    /// Load draft from UserDefaults
    func loadDraft() -> LeadDraft? {
        guard let data = defaults.data(forKey: draftKey) else {
            print("ℹ️ No draft found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let draft = try decoder.decode(LeadDraft.self, from: data)
            print("📥 Draft loaded: \(draft.name)")
            return draft
        } catch {
            print("❌ Failed to load draft: \(error)")
            return nil
        }
    }
    
    /// Clear saved draft
    func clearDraft() {
        defaults.removeObject(forKey: draftKey)
        defaults.synchronize()
        print("🗑️ Draft cleared")
    }
    
    /// Check if draft exists
    func hasDraft() -> Bool {
        return defaults.data(forKey: draftKey) != nil
    }
}

// MARK: - Lead Draft Model
struct LeadDraft: Codable {
    let name: String
    let email: String
    let phone: String
    let company: String
    let budget: String
    let sizeRange: String
    let sizeMin: String
    let sizeMax: String
    let propertyType: String
    let transactionType: String
    let status: String
    let preferredArea: String
    let industry: String
    let leaseTerm: String
    let notes: String
    let savedAt: Date
    
    init(
        name: String,
        email: String,
        phone: String,
        company: String,
        budget: String,
        sizeRange: String,
        sizeMin: String,
        sizeMax: String,
        propertyType: String,
        transactionType: String,
        status: String,
        preferredArea: String,
        industry: String,
        leaseTerm: String,
        notes: String
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.company = company
        self.budget = budget
        self.sizeRange = sizeRange
        self.sizeMin = sizeMin
        self.sizeMax = sizeMax
        self.propertyType = propertyType
        self.transactionType = transactionType
        self.status = status
        self.preferredArea = preferredArea
        self.industry = industry
        self.leaseTerm = leaseTerm
        self.notes = notes
        self.savedAt = Date()
    }
    
    /// Check if draft has meaningful content (not just default values)
    var hasContent: Bool {
        return !name.isEmpty || 
               !email.isEmpty || 
               !phone.isEmpty || 
               !company.isEmpty || 
               !notes.isEmpty
    }
    
    /// Time since draft was saved
    var timeSinceSaved: TimeInterval {
        return Date().timeIntervalSince(savedAt)
    }
}

