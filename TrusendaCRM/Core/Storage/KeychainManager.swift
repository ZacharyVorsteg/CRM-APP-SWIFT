import Foundation
import Security

// MARK: - Draft Manager
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

/// Secure storage for JWT tokens using iOS Keychain
class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.trusenda.crm"
    
    enum KeychainKey: String {
        case accessToken = "jwt_access_token"
        case refreshToken = "jwt_refresh_token"
        case tokenExpiry = "jwt_token_expiry"
        case savedEmail = "saved_email_for_biometric"
        case savedPassword = "saved_password_for_biometric"
        case biometricEnabled = "biometric_login_enabled"
    }
    
    private init() {}
    
    // MARK: - Save
    func save(_ value: String, for key: KeychainKey) {
        let data = Data(value.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("❌ Keychain save failed for \(key.rawValue): \(status)")
        }
    }
    
    // MARK: - Retrieve
    func get(_ key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    // MARK: - Delete
    func delete(_ key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Clear All
    func clearAll() {
        delete(.accessToken)
        delete(.refreshToken)
        delete(.tokenExpiry)
        // Note: Don't clear biometric credentials - they persist for convenience
    }
    
    // MARK: - Biometric Credentials
    func saveBiometricCredentials(email: String, password: String) {
        save(email, for: .savedEmail)
        save(password, for: .savedPassword)
        save("true", for: .biometricEnabled)
        print("✅ Biometric credentials saved securely")
    }
    
    func getBiometricCredentials() -> (email: String, password: String)? {
        guard let email = get(.savedEmail),
              let password = get(.savedPassword),
              get(.biometricEnabled) == "true" else {
            return nil
        }
        return (email, password)
    }
    
    func clearBiometricCredentials() {
        delete(.savedEmail)
        delete(.savedPassword)
        delete(.biometricEnabled)
        print("🗑️ Biometric credentials cleared")
    }
    
    func isBiometricEnabled() -> Bool {
        return get(.biometricEnabled) == "true"
    }
    
    // MARK: - Token Helpers
    func saveTokens(accessToken: String, refreshToken: String?, expiresIn: Int) {
        save(accessToken, for: .accessToken)
        
        if let refreshToken = refreshToken {
            save(refreshToken, for: .refreshToken)
        }
        
        // Calculate expiry timestamp
        let expiry = Date().addingTimeInterval(TimeInterval(expiresIn))
        save(String(expiry.timeIntervalSince1970), for: .tokenExpiry)
    }
    
    func isTokenExpired() -> Bool {
        guard let expiryString = get(.tokenExpiry),
              let expiryTimestamp = Double(expiryString) else {
            return true // Assume expired if no expiry found
        }
        
        let expiryDate = Date(timeIntervalSince1970: expiryTimestamp)
        
        // Consider token expired 5 minutes before actual expiry (buffer)
        let bufferDate = expiryDate.addingTimeInterval(-5 * 60)
        
        return Date() >= bufferDate
    }
}

