import Foundation

enum Endpoint {
    // Base URLs
    static let baseURL = "https://trusenda.com"
    static let functionsBase = "\(baseURL)/.netlify/functions"
    static let identityBase = "\(baseURL)/.netlify/identity"
    
    // Authentication (Netlify Identity GoTrue API)
    case login
    case signup  
    case recover
    case me
    
    // Leads (Customers)
    case customers
    case customer(id: String)
    
    // Tenant
    case tenantInfo
    case updateBranding
    case updateTimezone
    
    // Stripe
    case createCheckoutSession
    case createPortalSession
    case exportData
    
    // Public Forms
    case publicFormManage
    
    // API Keys
    case apiKeys
    case apiKey(id: String)
    
    // Account
    case deleteAccount
    
    // Follow-ups
    case leadSnooze
    case leadMarkContacted
    
    // Properties
    case properties
    case property(id: String)
    
    var url: URL? {
        switch self {
        case .login:
            return URL(string: "\(Endpoint.identityBase)/token")
        case .signup:
            return URL(string: "\(Endpoint.identityBase)/signup")
        case .recover:
            return URL(string: "\(Endpoint.identityBase)/recover")
        case .me:
            return URL(string: "\(Endpoint.functionsBase)/me")
        case .customers:
            return URL(string: "\(Endpoint.functionsBase)/customers")
        case .customer(let id):
            return URL(string: "\(Endpoint.functionsBase)/customers/\(id)")
        case .tenantInfo:
            return URL(string: "\(Endpoint.functionsBase)/tenant-info")
        case .updateBranding:
            return URL(string: "\(Endpoint.functionsBase)/update-branding")
        case .updateTimezone:
            return URL(string: "\(Endpoint.functionsBase)/update-timezone")
        case .createCheckoutSession:
            return URL(string: "\(Endpoint.functionsBase)/create-checkout-session")
        case .createPortalSession:
            return URL(string: "\(Endpoint.functionsBase)/create-portal-session")
        case .exportData:
            return URL(string: "\(Endpoint.functionsBase)/customers")
        case .publicFormManage:
            return URL(string: "\(Endpoint.functionsBase)/public-form-manage")
        case .apiKeys:
            return URL(string: "\(Endpoint.functionsBase)/api-keys")
        case .apiKey(let id):
            return URL(string: "\(Endpoint.functionsBase)/api-keys/\(id)")
        case .deleteAccount:
            return URL(string: "\(Endpoint.functionsBase)/delete-account")
        case .leadSnooze:
            return URL(string: "\(Endpoint.functionsBase)/lead-snooze")
        case .leadMarkContacted:
            return URL(string: "\(Endpoint.functionsBase)/lead-mark-contacted")
        case .properties:
            return URL(string: "\(Endpoint.functionsBase)/properties")
        case .property(let id):
            return URL(string: "\(Endpoint.functionsBase)/properties/\(id)")
        }
    }
}

