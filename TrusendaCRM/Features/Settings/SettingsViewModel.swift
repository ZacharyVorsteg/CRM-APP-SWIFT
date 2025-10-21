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
            print("❌ Error fetching tenant info:", error)
            clearMessageAfterDelay()
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
    
    // MARK: - Update Timezone
    func updateTimezone(_ timezone: String) async {
        do {
            let update = ["timezone": timezone]
            let _: SuccessResponse = try await client.post(
                endpoint: .updateTimezone,
                body: update
            )
            
            // Update local tenant info
            if var info = tenantInfo {
                info.timezone = timezone
                tenantInfo = info
            }
            
            successMessage = "✅ Timezone updated to \(timezone)"
            clearMessageAfterDelay()
            
            print("✅ Timezone updated to \(timezone)")
        } catch {
            self.error = "Failed to update timezone"
            print("❌ Error updating timezone:", error)
            clearMessageAfterDelay()
        }
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
    
    // MARK: - Upgrade to Pro (Stripe Checkout)
    func createCheckoutSession() async throws -> String {
        struct CheckoutRequest: Codable {
            let plan: String
            
            init() {
                self.plan = "pro"
            }
        }
        
        do {
            print("🔵 Creating Stripe checkout session...")
            
            let response: StripeCheckoutResponse = try await client.post(
                endpoint: .createCheckoutSession,
                body: CheckoutRequest()
            )
            
            print("✅ Stripe session created: \(response.sessionId)")
            print("✅ Stripe checkout URL: \(response.url)")
            
            // Return the actual checkout URL (not just session ID)
            return response.url
            
        } catch let error as NetworkError {
            print("❌ Stripe checkout error: \(error.localizedDescription)")
            
            // User-friendly error messages
            switch error {
            case .unauthorized:
                throw StripePaymentError.notAuthenticated
            case .timeout:
                throw StripePaymentError.timeout
            case .serverError(let code, _):
                if code == 404 {
                    throw StripePaymentError.noStripeAccount
                } else {
                    throw StripePaymentError.serverError
                }
            default:
                throw StripePaymentError.unknown(error.localizedDescription)
            }
        } catch {
            print("❌ Unexpected checkout error: \(error)")
            throw StripePaymentError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Manage Subscription (Stripe Portal)
    func createPortalSession() async throws -> String {
        struct PortalResponse: Codable {
            let url: String
        }
        
        struct EmptyRequest: Codable {}
        
        do {
            print("🔵 Creating Stripe portal session...")
            
            let response: PortalResponse = try await client.post(
                endpoint: .createPortalSession,
                body: EmptyRequest()
            )
            
            print("✅ Portal session created: \(response.url)")
            
            return response.url
            
        } catch let error as NetworkError {
            print("❌ Portal session error: \(error.localizedDescription)")
            
            // User-friendly error messages
            switch error {
            case .unauthorized:
                throw StripePaymentError.notAuthenticated
            case .timeout:
                throw StripePaymentError.timeout
            case .serverError(404, _):
                throw StripePaymentError.noSubscription
            case .serverError(_, _):
                throw StripePaymentError.serverError
            default:
                throw StripePaymentError.unknown(error.localizedDescription)
            }
        } catch {
            print("❌ Unexpected portal error: \(error)")
            throw StripePaymentError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Export Data
    func exportData() async throws -> [Lead] {
        let response: LeadsResponse = try await client.get(endpoint: .customers)
        return response.customers
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
    func clearMessageAfterDelay() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)  // 2.5 seconds
            successMessage = nil
            error = nil
        }
    }
    
    func clearError() {
        error = nil
    }
}

// MARK: - Stripe Payment Error Types
enum StripePaymentError: LocalizedError {
    case notAuthenticated
    case noStripeAccount
    case noSubscription
    case timeout
    case serverError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please log in to upgrade your plan"
        case .noStripeAccount:
            return "Unable to process payment. Please contact support@trusenda.com"
        case .noSubscription:
            return "No active subscription found. Please upgrade to Pro first."
        case .timeout:
            return "Request timed out. Please check your connection and try again."
        case .serverError:
            return "Payment service temporarily unavailable. Please try again in a few moments."
        case .unknown(let message):
            return "Error: \(message). Please contact support if this persists."
        }
    }
}

