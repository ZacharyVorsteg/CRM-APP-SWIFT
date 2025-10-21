import SwiftUI

struct PropertyShareSheet: View {
    let property: Property
    let matches: [LeadPropertyMatch]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLead: Lead?
    
    // Generate shareable URL
    private var propertyURL: String {
        return "https://trusenda.com/property/\(property.id)"
    }
    
    // Share message for leads
    private var shareText: String {
        var text = "🏢 Check out this property that might be perfect for you:\n\n"
        text += "\(property.title)\n"
        
        if let address = property.address {
            text += "📍 \(address)"
            if let city = property.city, let state = property.state {
                text += ", \(city), \(state)"
            }
            text += "\n\n"
        }
        
        if let propertyType = property.propertyType {
            text += "Type: \(propertyType)\n"
        }
        if let sizeMin = property.sizeMin, let sizeMax = property.sizeMax {
            text += "Size: \(formatNumber(sizeMin)) - \(formatNumber(sizeMax)) SF\n"
        }
        if let budget = property.budget {
            text += "Price: \(budget)\n"
        }
        
        text += "\n👀 View full details with photos:\n\(propertyURL)\n"
        
        return text
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
                
                if !matches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Send Directly To:")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(matches.prefix(5)) { match in
                                    Button {
                                        selectedLead = match.lead
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(match.lead.name)
                                                .font(.subheadline.bold())
                                                .foregroundColor(.primary)
                                            Text("\(match.matchScore)%")
                                                .font(.caption.bold())
                                                .foregroundColor(.successGreen)
                                        }
                                        .padding()
                                        .frame(width: 100)
                                        .background(Color.primaryBlue.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                VStack(spacing: 12) {
                    // Share URL button
                    ShareLink(item: propertyURL) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                            Text("Share Property Link")
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
                    
                    // Copy URL button
                    Button {
                        copyToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Link")
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
                    
                    // URL Preview
                    Text(propertyURL)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
                .padding()
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
            .sheet(item: $selectedLead) { lead in
                LeadShareActionSheet(lead: lead, propertyText: shareText)
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
        UIPasteboard.general.string = propertyURL
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct LeadShareActionSheet: View {
    let lead: Lead
    let propertyText: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
                
                VStack(spacing: 16) {
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
            dismiss()
        }
    }
    
    private func sendEmail(to email: String) {
        let subject = "Property Listing - Might Be a Good Fit"
        let body = propertyText
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            dismiss()
        }
    }
}

