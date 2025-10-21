import SwiftUI

// MARK: - Follow-Up Sheet Data
struct FollowUpSheetData: Identifiable {
    let id = UUID()
    let lead: Lead
    let days: Int
}

// MARK: - Quick Follow-Up Notes View
struct QuickFollowUpNotesView: View {
    let lead: Lead
    let daysFromNow: Int
    @Binding var notes: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    private var dayLabel: String {
        switch daysFromNow {
        case 1: return "Tomorrow"
        case 3: return "In 3 Days"
        case 7: return "In 1 Week"
        default: return "In \(daysFromNow) Days"
        }
    }
    
    private var followUpDate: Date {
        // Match cloud app logic EXACTLY
        // Cloud uses: date.setDate(date.getDate() + days)
        // Using the new Date helper that matches cloud's addDaysToDate function
        return Date.addingDays(daysFromNow)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with lead info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Follow up with")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(lead.name)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    if let company = lead.company {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Date display with debug info
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.primaryBlue)
                        Text(dayLabel)
                            .fontWeight(.semibold)
                        Text("(\(followUpDate.toDisplayString()))")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primaryBlue.opacity(0.05))
                )
                
                // Task/Notes input
                VStack(alignment: .leading, spacing: 8) {
                    Text("What do you need to do?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Example: \"Send proposal\", \"Call about warehouse\", \"Follow up on budget\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if notes.isEmpty {
                                    Text("Enter your task or notes here...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.leading, 12)
                                        .padding(.top, 16)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.body.weight(.medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    Button("Schedule") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        onSave()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primaryBlue)
                            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding()
            }
            .navigationTitle("Schedule Follow-Up")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

