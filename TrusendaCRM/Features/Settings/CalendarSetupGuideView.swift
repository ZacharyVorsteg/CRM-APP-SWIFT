import SwiftUI

struct CalendarSetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 40))
                                .foregroundColor(.primaryBlue)
                            Spacer()
                        }
                        
                        Text("Get Your Free Calendar Link")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Choose one of these free calendar tools to let leads book tours with you instantly.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Calendar Options
                    VStack(spacing: 16) {
                        CalendarOptionCard(
                            name: "Calendly",
                            icon: "📅",
                            description: "Most popular. Easy setup. 1 event type free.",
                            url: "https://calendly.com",
                            pros: ["Simple interface", "Unlimited bookings", "Google/Outlook sync"]
                        )
                        
                        CalendarOptionCard(
                            name: "Google Calendar",
                            icon: "🗓️",
                            description: "Free with Gmail. Integrates with Google Workspace.",
                            url: "https://calendar.google.com/calendar/appointments",
                            pros: ["No signup needed", "Direct Gmail integration", "Familiar interface"]
                        )
                        
                        CalendarOptionCard(
                            name: "Microsoft Outlook",
                            icon: "📨",
                            description: "Free with Microsoft account. Office 365 integration.",
                            url: "https://outlook.office365.com/owa/calendar",
                            pros: ["Works with work email", "Office 365 sync", "Teams integration"]
                        )
                        
                        CalendarOptionCard(
                            name: "Cal.com",
                            icon: "🌐",
                            description: "Open source. Unlimited event types.",
                            url: "https://cal.com",
                            pros: ["Completely free", "No branding", "Privacy-focused"]
                        )
                    }
                    .padding(.horizontal)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to Set Up (5 minutes)")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionStep(
                                number: 1,
                                title: "Pick a calendar tool",
                                description: "Choose Calendly, Google Calendar, Outlook, or Cal.com (all free)"
                            )
                            
                            InstructionStep(
                                number: 2,
                                title: "Create your booking page",
                                description: "Sign up and create a \"Property Tour\" event type (30-60 min)"
                            )
                            
                            InstructionStep(
                                number: 3,
                                title: "Copy your booking link",
                                description: "Look for \"Share\" or \"Booking Link\" - copy the full URL"
                            )
                            
                            InstructionStep(
                                number: 4,
                                title: "Paste it in Trusenda",
                                description: "Go to Settings → Instant Tour Booking → paste your URL → Save"
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why This Helps")
                            .font(.headline)
                        
                        BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "40% higher conversion - leads book while excited")
                        BenefitRow(icon: "clock.badge.checkmark", text: "No back-and-forth scheduling emails")
                        BenefitRow(icon: "calendar.badge.plus", text: "Tours auto-add to your calendar")
                        BenefitRow(icon: "dollarsign.circle", text: "100% free - no cost to you or Trusenda")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Setup Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct CalendarOptionCard: View {
    let name: String
    let icon: String
    let description: String
    let url: String
    let pros: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.title3.bold())
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(pros, id: \.self) { pro in
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(pro)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Link(destination: URL(string: url)!) {
                HStack {
                    Text("Sign Up Free")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primaryBlue)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.primaryBlue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.green)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

struct CalendarSetupGuideView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSetupGuideView()
    }
}

