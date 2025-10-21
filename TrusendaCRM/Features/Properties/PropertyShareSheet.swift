import SwiftUI

struct PropertyShareSheet: View {
    let property: Property
    let matches: [LeadPropertyMatch]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLead: Lead?
    
    private var shareText: String {
        var text = "🏢 Property Listing\n\n"
        text += "\(property.title)\n"
        
        if let address = property.address {
            text += "\(address)\n"
        }
        if let city = property.city, let state = property.state {
            text += "\(city), \(state) \(property.zipCode ?? "")\n"
        }
        
        text += "\n📋 Details:\n"
        
        if let propertyType = property.propertyType {
            text += "• Type: \(propertyType)\n"
        }
        if let transactionType = property.transactionType {
            text += "• Transaction: \(transactionType)\n"
        }
        if let sizeMin = property.sizeMin, let sizeMax = property.sizeMax {
            text += "• Size: \(formatNumber(sizeMin)) - \(formatNumber(sizeMax)) SF\n"
        }
        if let budget = property.budget {
            text += "• Price: \(budget)\n"
        }
        if let leaseTerm = property.leaseTerm {
            text += "• Lease Term: \(leaseTerm)\n"
        }
        if let industry = property.industry {
            text += "• Best For: \(industry)\n"
        }
        
        if let description = property.description {
            text += "\n📝 Description:\n\(description)\n"
        }
        
        if let features = property.features {
            text += "\n✨ Key Features:\n\(features)\n"
        }
        
        if !matches.isEmpty {
            text += "\n🎯 Matched Leads (\(matches.count)):\n"
            for match in matches.prefix(3) {
                text += "• \(match.lead.name)"
                if let company = match.lead.company {
                    text += " - \(company)"
                }
                text += " (\(match.matchScore)% match)\n"
            }
        }
        
        text += "\n✅ Status: \(property.status)"
        
        return text
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Preview card
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Share Preview")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(shareText)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primaryBlue.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .padding()
                }
                
                // Matched Leads - Share Directly
                if !matches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Send Directly To:")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ForEach(matches.prefix(5)) { match in
                            Button {
                                selectedLead = match.lead
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(match.lead.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                        if let company = match.lead.company {
                                            Text(company)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(match.matchScore)%")
                                        .font(.caption.bold())
                                        .foregroundColor(.successGreen)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.primaryBlue.opacity(0.05))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Share buttons
                VStack(spacing: 12) {
                    ShareLink(item: shareText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share via...")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    Button {
                        copyToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy to Clipboard")
                        }
                        .font(.headline)
                        .foregroundColor(.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primaryBlue.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
            .sheet(item: $selectedLead) { lead in
                LeadShareActionSheet(lead: lead, propertyText: shareText)
            }
            }
            .navigationTitle("Share Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
        }
    }
    
    private func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? value
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = shareText
        
        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Lead Share Action Sheet
struct LeadShareActionSheet: View {
    let lead: Lead
    let propertyText: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Lead info header
                VStack(spacing: 8) {
                    Text(lead.name)
                        .font(.title2.bold())
                    if let company = lead.company {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Share options
                VStack(spacing: 16) {
                    // Text message (if phone exists)
                    if let phone = lead.phone, !phone.isEmpty {
                        Button {
                            sendSMS(to: phone)
                        } label: {
                            HStack {
                                Image(systemName: "message.fill")
                                    .font(.title3)
                                Text("Send Text Message")
                                Spacer()
                                Text(phone)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.successGreen.opacity(0.1))
                            .foregroundColor(.successGreen)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Email (if email exists)
                    if let email = lead.email, !email.isEmpty {
                        Button {
                            sendEmail(to: email)
                        } label: {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.title3)
                                Text("Send Email")
                                Spacer()
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.primaryBlue.opacity(0.1))
                            .foregroundColor(.primaryBlue)
                            .cornerRadius(12)
                        }
                    }
                    
                    // General share
                    ShareLink(item: propertyText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            Text("Share via Other App")
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Send To \(lead.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
        }
    }
    
    private func sendSMS(to phone: String) {
        let cleanPhone = phone.filter { $0.isNumber }
        let urlString = "sms:\(cleanPhone)&body=\(propertyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(to email: String) {
        let subject = "Property Listing - Might Be a Good Fit"
        let body = propertyText
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}


