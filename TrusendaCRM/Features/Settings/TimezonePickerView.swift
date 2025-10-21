import SwiftUI

/// Timezone picker matching cloud web app
struct TimezonePickerView: View {
    @Binding var selectedTimezone: String
    @Environment(\.dismiss) private var dismiss
    
    // US Timezones (matching web app)
    private let usTimezones: [(name: String, value: String)] = [
        ("Eastern Time (ET)", "America/New_York"),
        ("Central Time (CT)", "America/Chicago"),
        ("Mountain Time (MT)", "America/Denver"),
        ("Pacific Time (PT)", "America/Los_Angeles"),
        ("Alaska Time (AKT)", "America/Anchorage"),
        ("Hawaii Time (HST)", "Pacific/Honolulu")
    ]
    
    // International Timezones (matching web app)
    private let internationalTimezones: [(name: String, value: String)] = [
        ("London (GMT/BST)", "Europe/London"),
        ("Paris (CET/CEST)", "Europe/Paris"),
        ("Tokyo (JST)", "Asia/Tokyo"),
        ("Sydney (AEDT/AEST)", "Australia/Sydney"),
        ("Dubai (GST)", "Asia/Dubai"),
        ("Singapore (SGT)", "Asia/Singapore"),
        ("Hong Kong (HKT)", "Asia/Hong_Kong"),
        ("Mumbai (IST)", "Asia/Kolkata")
    ]
    
    var body: some View {
        List {
            Section("UNITED STATES") {
                ForEach(usTimezones, id: \.value) { timezone in
                    TimezoneRow(
                        name: timezone.name,
                        value: timezone.value,
                        isSelected: selectedTimezone == timezone.value
                    ) {
                        selectedTimezone = timezone.value
                        // Success haptic
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        // Dismiss after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                }
            }
            
            Section("INTERNATIONAL") {
                ForEach(internationalTimezones, id: \.value) { timezone in
                    TimezoneRow(
                        name: timezone.name,
                        value: timezone.value,
                        isSelected: selectedTimezone == timezone.value
                    ) {
                        selectedTimezone = timezone.value
                        // Success haptic
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        // Dismiss after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.primaryBlue)
                        Text("Daily Follow-Up Reminders")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    Text("Your daily follow-up emails will be sent at 7:00 AM in your selected timezone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Select Timezone")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TimezoneRow: View {
    let name: String
    let value: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryBlue)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

