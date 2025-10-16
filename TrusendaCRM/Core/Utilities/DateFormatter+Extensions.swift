import Foundation

extension DateFormatter {
    /// ISO 8601 date formatter (YYYY-MM-DD)
    static let iso8601Date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
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
    /// Convert Date to ISO 8601 string (YYYY-MM-DD)
    func toISO8601String() -> String {
        return DateFormatter.iso8601Date.string(from: self)
    }
    
    /// Convert Date to display string
    func toDisplayString() -> String {
        return DateFormatter.displayDate.string(from: self)
    }
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is in the past
    var isPast: Bool {
        self < Date()
    }
    
    /// Days from now
    func daysFromNow() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: self)
        return components.day ?? 0
    }
}

