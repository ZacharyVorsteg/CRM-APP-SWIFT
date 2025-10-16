import Foundation
import Security

/// Secure storage for JWT tokens using iOS Keychain
class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.trusenda.crm"
    
    enum KeychainKey: String {
        case accessToken = "jwt_access_token"
        case refreshToken = "jwt_refresh_token"
        case tokenExpiry = "jwt_token_expiry"
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

