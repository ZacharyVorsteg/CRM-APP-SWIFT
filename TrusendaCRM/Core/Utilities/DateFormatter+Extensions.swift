import Foundation

extension DateFormatter {
    /// ISO 8601 date formatter (YYYY-MM-DD)
    /// CRITICAL: Uses LOCAL timezone to match user's date selection
    /// Backend stores as DATE (date-only), so we must preserve the user's local date
    static let iso8601Date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current // LOCAL timezone - preserves user's date
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// Display date formatter (e.g., "Jan 15, 2024")
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// Short display date (e.g., "1/15/24")
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

extension Date {
    /// Convert Date to ISO 8601 string (YYYY-MM-DD) for API
    /// Matches cloud app's formatDateForAPI function
    func toISO8601String() -> String {
        return DateFormatter.iso8601Date.string(from: self)
    }
    
    /// Convert Date to display string
    /// Matches cloud app's formatDateForDisplay function
    func toDisplayString() -> String {
        return DateFormatter.displayDate.string(from: self)
    }
    
    /// Convert Date to relative string (e.g., "Today", "Tomorrow", "In 3 days")
    /// Provides better scannability for near-term dates
    func toRelativeString() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateAtMidnight = calendar.startOfDay(for: self)
        
        // Check specific relative dates
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }
        
        // Calculate days difference
        let components = calendar.dateComponents([.day], from: today, to: dateAtMidnight)
        guard let days = components.day else {
            return toDisplayString() // Fallback to full date
        }
        
        // For near-term dates (within 2 weeks), show relative
        if days < 0 {
            return "\(abs(days))d ago"
        } else if days > 0 && days <= 7 {
            return "In \(days)d"
        } else if days > 7 && days <= 14 {
            let weeks = days / 7
            return "In \(weeks)w"
        }
        
        // For dates beyond 2 weeks, show formatted date
        return toDisplayString()
    }
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is in the past (before today at midnight)
    /// Matches cloud app's date validation logic
    var isPast: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateAtMidnight = calendar.startOfDay(for: self)
        return dateAtMidnight < today
    }
    
    /// Days from now (positive = future, negative = past, 0 = today)
    func daysFromNow() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateAtMidnight = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: today, to: dateAtMidnight)
        return components.day ?? 0
    }
    
    /// Add days to current date (matches cloud app's addDaysToDate function)
    /// Returns a new Date that is 'days' days from now
    /// IMPORTANT: Uses startOfDay to avoid timezone edge cases
    static func addingDays(_ days: Int) -> Date {
        let calendar = Calendar.current
        // Use start of day (midnight) to avoid timezone issues
        // This matches cloud app's intent where dates are always at midnight
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: days, to: today) ?? today
    }
    
    /// Get minimum date for follow-up (today)
    /// Matches cloud app's validation that allows today but not past dates
    static func minimumFollowUpDate() -> Date {
        Calendar.current.startOfDay(for: Date())
    }
}

