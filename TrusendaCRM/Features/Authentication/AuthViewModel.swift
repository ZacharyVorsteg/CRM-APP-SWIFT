import Foundation

/// ViewModel for authentication screens
@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private let authManager = AuthManager.shared
    
    // MARK: - Login
    func login() async {
        guard validate() else { return }
        
        isLoading = true
        error = nil
        
        do {
            try await authManager.login(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Signup
    func signup() async {
        guard validate() else { return }
        
        isLoading = true
        error = nil
        
        do {
            try await authManager.signup(email: email, password: password)
            // Show success message - user must confirm email
            error = "Account created! Please check your email to confirm your account."
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Validation
    private func validate() -> Bool {
        if email.isEmpty {
            error = "Please enter your email"
            return false
        }
        
        if !Validation.isValidEmail(email) {
            error = "Please enter a valid email address"
            return false
        }
        
        if password.isEmpty {
            error = "Please enter your password"
            return false
        }
        
        if !Validation.isValidPassword(password) {
            error = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
    
    func clearError() {
        error = nil
    }
}

