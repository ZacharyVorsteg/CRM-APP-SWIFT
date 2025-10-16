import Foundation

/// ViewModel for settings and account management
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var tenantInfo: TenantInfo?
    @Published var publicForm: PublicForm?
    @Published var apiKeys: [APIKey] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var successMessage: String?
    
    private let client = APIClient.shared
    private let authManager = AuthManager.shared
    
    // MARK: - Fetch Tenant Info
    func fetchTenantInfo() async {
        isLoading = true
        
        do {
            tenantInfo = try await client.get(endpoint: .tenantInfo)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Update Branding
    func updateBranding(logoUrl: String?, theme: String) async throws {
        let update = BrandingUpdate(
            logoUrl: logoUrl,
            autoTailor: false,
            headerTheme: theme
        )
        
        let _: SuccessResponse = try await client.post(
            endpoint: .updateBranding,
            body: update
        )
        
        successMessage = "✅ Branding updated"
        clearMessageAfterDelay()
    }
    
    // MARK: - Fetch Public Form
    func fetchPublicForm() async {
        do {
            let response: PublicFormResponse = try await client.get(endpoint: .publicFormManage)
            publicForm = response.form
        } catch {
            print("Failed to fetch public form:", error)
        }
    }
    
    // MARK: - Fetch API Keys
    func fetchAPIKeys() async {
        do {
            let response: APIKeysResponse = try await client.get(endpoint: .apiKeys)
            apiKeys = response.keys
        } catch {
            print("Failed to fetch API keys:", error)
        }
    }
    
    // MARK: - Create API Key
    func createAPIKey(label: String) async throws {
        struct CreateRequest: Codable {
            let label: String
        }
        
        let response: APIKeyCreateResponse = try await client.post(
            endpoint: .apiKeys,
            body: CreateRequest(label: label)
        )
        
        // Refresh list
        await fetchAPIKeys()
        
        successMessage = "✅ API Key created: \(response.apiKey)"
        clearMessageAfterDelay()
    }
    
    // MARK: - Delete API Key
    func deleteAPIKey(id: String) async throws {
        try await client.delete(endpoint: .apiKey(id: id))
        
        // Remove from local array
        apiKeys.removeAll { $0.id == id }
        
        successMessage = "✅ API Key deleted"
        clearMessageAfterDelay()
    }
    
    // MARK: - Upgrade to Pro
    func createCheckoutSession() async throws -> String {
        struct CheckoutRequest: Codable {
            let plan: String = "pro"
        }
        
        let response: StripeCheckoutResponse = try await client.post(
            endpoint: .createCheckoutSession,
            body: CheckoutRequest()
        )
        
        // Return session ID for opening Stripe checkout
        return response.sessionId
    }
    
    // MARK: - Delete Account
    func deleteAccount(confirmEmail: String) async throws {
        struct DeleteRequest: Codable {
            let confirmEmail: String
        }
        
        let _: SuccessResponse = try await client.post(
            endpoint: .deleteAccount,
            body: DeleteRequest(confirmEmail: confirmEmail)
        )
        
        // Logout after deletion
        authManager.logout()
    }
    
    // MARK: - Helpers
    private func clearMessageAfterDelay() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            successMessage = nil
        }
    }
    
    func clearError() {
        error = nil
    }
}

