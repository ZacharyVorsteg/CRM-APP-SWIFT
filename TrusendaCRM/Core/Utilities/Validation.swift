import Foundation

/// Input validation utilities
struct Validation {
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Name Validation
    static func isValidName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Budget Validation
    static func formatBudget(_ value: String) -> String {
        // Remove all non-digits
        let digits = value.filter { $0.isNumber }
        
        guard !digits.isEmpty, let number = Int(digits) else {
            return ""
        }
        
        // Format with thousands separator
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        return formatter.string(from: NSNumber(value: number)) ?? digits
    }
    
    // MARK: - Size Validation
    static func isValidSizeRange(min: String?, max: String?) -> Bool {
        guard let minStr = min, let maxStr = max,
              let minInt = Int(minStr), let maxInt = Int(maxStr) else {
            return true // If either is nil or empty, consider valid
        }
        
        return minInt <= maxInt
    }
    
    // MARK: - Date Validation
    static func isValidFollowUpDate(_ dateString: String?) -> Bool {
        guard let dateString = dateString else { return true }
        
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString + "T00:00:00Z") else {
            return false
        }
        
        // Date must be today or future
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: date)
        
        return selectedDate >= today
    }
    
    // MARK: - Password Validation
    static func isValidPassword(_ password: String) -> Bool {
        // Netlify Identity requires at least 6 characters
        return password.count >= 6
    }
}

