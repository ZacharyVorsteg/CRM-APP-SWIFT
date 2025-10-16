import Foundation

/// Utility class for formatting phone numbers
struct PhoneFormatter {
    /// Format phone number to (XXX) XXX-XXXX
    static func format(_ phone: String) -> String {
        // Remove all non-digit characters
        let digits = phone.filter { $0.isNumber }
        
        // Format based on length
        guard digits.count == 10 else {
            return phone // Return original if not 10 digits
        }
        
        let areaCode = digits.prefix(3)
        let firstThree = digits.dropFirst(3).prefix(3)
        let lastFour = digits.dropFirst(6)
        
        return "(\(areaCode)) \(firstThree)-\(lastFour)"
    }
    
    /// Remove formatting from phone number
    static func unformat(_ phone: String) -> String {
        return phone.filter { $0.isNumber }
    }
    
    /// Validate if phone number is valid (10 digits)
    static func isValid(_ phone: String) -> Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count == 10
    }
}

